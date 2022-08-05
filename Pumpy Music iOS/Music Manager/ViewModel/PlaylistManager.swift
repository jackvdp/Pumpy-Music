//
//  PlaylistChange.swift
//  Pumpy Music iOS
//
//  Created by Jack Vanderpump on 17/08/2020.
//  Copyright © 2020 Jack Vanderpump. All rights reserved.
//

import Foundation
import MediaPlayer
import SwiftUI
import Scheduler
import PumpyLibrary

class PlaylistManager: ObservableObject {
    
    let musicPlayerController = MPMusicPlayerController.applicationQueuePlayer
    @Published var playlistLabel = String()
    @Published var playlistURL = String()
    var timer: Timer?
    var backgroundPlaylistTimer: Timer?
    let blockedTracksManager: BlockedTracksManager
    let settingsManager: SettingsManager
    let tokenManager: TokenManager
    var crossfader: Crossfade?
    
    init(blockedTracksManager: BlockedTracksManager,
         settingsManager: SettingsManager,
         tokenManager: TokenManager) {
        self.blockedTracksManager = blockedTracksManager
        self.settingsManager = settingsManager
        self.tokenManager = tokenManager
        setUpBGTimer()
    }
    
    deinit {
        print("deiniting")
    }
    
    func playPlaylistNow(playlist: String, secondaryPlaylists: [SecondaryPlaylist] = []) {
        if playlist != K.stopMusic {
            if MusicContent.getListOfPlaylistNames().contains(playlist) {
                let items = getItemsFromAlarm(playlist: playlist, secondaryPlaylists: secondaryPlaylists)
                let items150 = Array(items.prefix(150))
                setQueueWithItems(items: items150)
                displayPlaylistInfo(playlist: playlist)
            }
        } else {
            stopMusic()
        }
    }
    
    func playPlaylistNext(playlist: String, secondaryPlaylists: [SecondaryPlaylist] = []) {
        if musicPlayerController.playbackState == .playing {
            startTimer(playlist: playlist, secondaryPlaylists: secondaryPlaylists)
        } else {
            playPlaylistNow(playlist: playlist, secondaryPlaylists: secondaryPlaylists)
        }
    }
    
//    func prependPlaylist(playlist: String) {
//        if musicPlayerController.playbackState == .playing {
//            let items = getItemsFromPlaylist(name: playlist)
//            prependItems(items)
//            displayPlaylistInfo(playlist: playlist)
//        } else {
//            playPlaylistNow(playlist: playlist)
//        }
//    }
    
//    func prependItems(_ items: [MPMediaItem]) {
//        let collection = MPMediaItemCollection(items: items)
//        let descriptor =  MPMusicPlayerMediaItemQueueDescriptor(itemCollection: collection)
//        musicPlayerController.prepend(descriptor)
//        musicPlayerController.shuffleMode = .off
//        musicPlayerController.repeatMode = .all
//    }
    
    func getItemsFromAlarm(playlist: String, secondaryPlaylists: [SecondaryPlaylist]) -> [MPMediaItem] {
        if secondaryPlaylists.isEmpty {
            return getItemsFromPlaylist(name: playlist)
        } else {
            return combineItems(playlist: playlist, secondaryPlaylists: secondaryPlaylists)
        }
    }
    
    func getItemsFromPlaylist(name: String) -> [MPMediaItem] {
        let query = MPMediaQuery.songs()
        let filter = MPMediaPropertyPredicate(value: name,
                                              forProperty: MPMediaPlaylistPropertyName,
                                              comparisonType: .equalTo)
        query.addFilterPredicate(filter)
        guard var items = query.items else { return [] }
        items.removeAll(where: { item in
            blockedTracksManager.blockedTracks
                .contains(where: { $0.playbackID == item.playbackStoreID})
        })
        items = checkExplicit(items: items)
        return items.shuffled().removingDuplicates()
    }
    
    private func checkExplicit(items: [MPMediaItem]) -> [MPMediaItem] {
        var items = items
        if settingsManager.settings.banExplicit {
            items.removeAll(where: { item in
                item.isExplicitItem
            })
        }
        return items
    }
    
    private func combineItems(playlist: String, secondaryPlaylists: [SecondaryPlaylist]) -> [MPMediaItem] {
        var combinedItems = getItemsFromPlaylist(name: playlist)
        var secItems: [(items: [MPMediaItem], ratio: Int)] = secondaryPlaylists.map { playlist in
            (getItemsFromPlaylist(name: playlist.name), playlist.ratio)
        }
        for i in 1...combinedItems.count {
            for x in 0...secItems.count-1 {
                if i % secItems[x].ratio == 0 {
                    if secItems[x].items.count > 0 {
                        let item = secItems[x].items.removeFirst()
                        combinedItems.insert(item, at: i-1)
                    }
                }
            }
        }
        return combinedItems.removingDuplicates()
    }
    
    private func setQueueWithItems(items: [MPMediaItem]) {
        let collection = MPMediaItemCollection(items: items)
        musicPlayerController.setQueue(with: collection)
        musicPlayerController.shuffleMode = .off
        musicPlayerController.repeatMode = .all
        MusicCoreFunctions.prepareToPlayAndPlay()
    }
    
    private func displayPlaylistInfo(playlist: String) {
        playlistLabel = "Playlist: \(playlist)"
        getPlaylistURL(playlist)
    }
    
    private func getPlaylistURL(_ playlist: String) {
        if let token = tokenManager.appleMusicToken, let store = tokenManager.appleMusicStoreFront {
            let amAPI = AppleMusicAPI(token: token, storeFront: store)
            amAPI.getPlaylistURL(playlist: playlist) { urlString in
                DispatchQueue.main.async {
                    self.playlistURL = urlString
                }
            }
        }
    }
    
    // MARK: - Time Change Playlist
    
    private func startTimer(playlist: String, secondaryPlaylists: [SecondaryPlaylist] = []) {
        guard timer == nil else { return }
        
        timer = Timer.scheduledTimer(
            timeInterval: TimeInterval(0.25),
            target      : self,
            selector    : #selector(playlistQueue),
            userInfo    : ["playlist" : playlist,
                           "secondaryPlaylist" : secondaryPlaylists],
            repeats     : true)
    }
    
    @objc private func playlistQueue(timer: Timer) {
        let playbackTime = musicPlayerController.currentPlaybackTime
        let playbackDuration = musicPlayerController.nowPlayingItem?.playbackDuration ?? 0
        guard let context = timer.userInfo as? [String: Any] else { return }
        let playlist = context["playlist"] as? String
        let secondaryplaylist = context["secondaryPlaylist"] as? [SecondaryPlaylist]
        if (playbackDuration - playbackTime) < 20 {
            if let p = playlist {
                if crossfader == nil {
                    crossfader = Crossfade(changePlaylist: {
                        self.playPlaylistNow(playlist: p, secondaryPlaylists: secondaryplaylist ?? [])
                    }, completionHandler: {
                        self.crossfader = nil
                    })
                }
            }
            stopTimer()
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func stopMusic() {
        musicPlayerController.stop()
        stopTimer()
        exit(0)
    }
    
}

// MARK: - Playlist Changer in BG


extension PlaylistManager {
    
    func setUpBGTimer() {
        backgroundPlaylistTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { timer in
            if UIApplication.shared.applicationState != .active {
                self.changePlaylistintheBG()
            }
        }
        
    }
    
    func changePlaylistintheBG() {
        let currentHour = Calendar.current.component(.hour, from: Date())
        let currentMinute = Calendar.current.component(.minute, from: Date())
        
        let alarms = AlarmData.loadAlarms()
        for alarm in alarms {
            if (alarm.repeatStatus == [] || alarm.repeatStatus.contains(DetailInfo.getCurrentDayFormatted())) {
                if alarm.time.hour == currentHour && alarm.time.min == currentMinute {
                    self.playPlaylistNext(playlist: alarm.playlistLabel,
                                          secondaryPlaylists: alarm.secondaryPlaylists ?? [])
                    return
                }
            }
        }
    }
    
}
