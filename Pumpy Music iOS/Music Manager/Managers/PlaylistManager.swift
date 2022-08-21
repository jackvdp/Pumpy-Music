//
//  NewPlaylistManager.swift
//  Pumpy Music iOS
//
//  Created by Jack Vanderpump on 06/08/2022.
//  Copyright © 2022 Jack Vanderpump. All rights reserved.
//

import Foundation
import PumpyLibrary
import MusicKit
import MediaPlayer

class PlaylistManager: NSObject, PlaylistProtocol {
    
    let musicPlayerController = ApplicationMusicPlayer.shared
    @Published var playlistLabel = String()
    @Published var playlistURL = String()
    let blockedTracksManager: BlockedTracksManager
    let settingsManager: SettingsManager
    let tokenManager: TokenManager
    let queueManager: QueueManager
    var playlistTimer: Timer?
    private let runLoop = RunLoop.current
    
    init(blockedTracksManager: BlockedTracksManager,
         settingsManager: SettingsManager,
         tokenManager: TokenManager,
         queueManager: QueueManager) {
        self.blockedTracksManager = blockedTracksManager
        self.settingsManager = settingsManager
        self.tokenManager = tokenManager
        self.queueManager = queueManager
        super.init()
        setUpPlaylistChangeTimer()
        addDefaultsObservers()
    }
    
    deinit {
        playlistTimer?.invalidate()
        removeObservers()
        DeinitCounter.count += 1
    }
    
    // MARK: - Public Functions
    
    func playPlaylistNow(playlist: String, secondaryPlaylists: [SecondaryPlaylist] = []) {
//        let queue = getQueueFromPlaylists(playlist: playlist, secondaryPlaylists: secondaryPlaylists)
//        musicPlayerController.setQueue(with: queue)
//        musicPlayerController.shuffleMode = .off
//        musicPlayerController.repeatMode = .all
//        MusicCoreFunctions.prepareToPlayAndPlay()
//        self.displayPlaylistInfo(playlist: playlist)
        
        let queue = ApplicationMusicPlayer.Queue(
    }
    
    
    
    func playPlaylistNext(playlist: String, secondaryPlaylists: [SecondaryPlaylist] = []) {
        
        guard musicPlayerController.playbackState == .playing else {
            playPlaylistNow(playlist: playlist, secondaryPlaylists: secondaryPlaylists)
            return
        }
        
        let queueDescriptor = self.getQueueFromPlaylists(playlist: playlist,
                                                         secondaryPlaylists: secondaryPlaylists)
        queueManager.addPlaylistToQueue(queueDescriptor: queueDescriptor)
        self.displayPlaylistInfo(playlist: playlist)
    }
    
    // MARK: - Get items from playlists
    
    private func getQueueFromPlaylists(playlist: String,
                                       secondaryPlaylists: [SecondaryPlaylist]) -> MPMusicPlayerMediaItemQueueDescriptor  {
        let totalNumberOfTracks = 150
        let secondaryItems: [MPMediaItem] = secondaryPlaylists.flatMap {
            getItemsFromPlaylist(playlist: $0.name, number: totalNumberOfTracks / $0.ratio)
        }
        let primaryItems = getItemsFromPlaylist(playlist: playlist, number: totalNumberOfTracks - secondaryItems.count)
        let itemsToAdd = (primaryItems + secondaryItems).shuffled()
        
        let collection = MPMediaItemCollection(items: itemsToAdd)
        return MPMusicPlayerMediaItemQueueDescriptor(itemCollection: collection)
    }
    
    private func getItemsFromPlaylist(playlist: String, number: Int) -> [MPMediaItem] {
        let query = MPMediaQuery.playlists()
        let filter = MPMediaPropertyPredicate(value: playlist,
                                              forProperty: MPMediaPlaylistPropertyName,
                                              comparisonType: .equalTo)
        query.addFilterPredicate(filter)
        guard let items = query.items else {
            return []
        }
        
        return Array(removeUnwantedTracks(items: items).shuffled().prefix(number))
    }
    
    private func removeUnwantedTracks(items: [MPMediaItem]) -> [MPMediaItem] {
        var itemsToKeep = items
        // Blocked Tracks
        itemsToKeep.removeAll(where: { item in
            blockedTracksManager.blockedTracks.contains(where: {
                $0.playbackID == item.playbackStoreID
            })
        })
        // Explicit
        if settingsManager.onlineSettings.banExplicit {
            itemsToKeep.removeAll(where: { $0.isExplicitItem })
        }
        return itemsToKeep
    }
    
    // MARK: - Set UI elements
    
    private func displayPlaylistInfo(playlist: String) {
        playlistLabel = "Playlist: \(playlist)"
        getPlaylistURL(playlist)
    }
    
    private func getPlaylistURL(_ playlist: String) {
        if let token = tokenManager.appleMusicToken, let store = tokenManager.appleMusicStoreFront {
            let amAPI = AppleMusicAPI(token: token, storeFront: store)
            amAPI.getPlaylistURL(playlist: playlist) { urlString in
                DispatchQueue.main.async { [weak self] in
                    self?.playlistURL = urlString
                }
            }
        }
    }
    
    // MARK: - Playlist Monitor Timer
    
    private func setUpPlaylistChangeTimer() {
        playlistTimer?.invalidate()
        let nextAlarm = MusicCoreFunctions.getNextPlaylist(alarms: AlarmData.loadAlarms())
        let dateToFireTimer = getDateForNextTimer(nextAlarm: nextAlarm)
        guard let dateToFireTimer = dateToFireTimer else { return }
        
        playlistTimer = Timer(fire: dateToFireTimer, interval: 0, repeats: false) { [weak self] _ in
            self?.playlistTimer?.invalidate()
            if self?.settingsManager.onlineSettings.overrideSchedule == false {
                if let nextAlarm = nextAlarm {
                    self?.playPlaylistNext(playlist: nextAlarm.playlistLabel,
                                     secondaryPlaylists: nextAlarm.secondaryPlaylists ?? [])
                }
            }
            self?.setUpPlaylistChangeTimer()
        }
        
        guard let playlistTimer = playlistTimer else { return }
        runLoop.add(playlistTimer, forMode: .common)
    }
    
    private func getDateForNextTimer(nextAlarm: Alarm?) -> Date? {
        let calendar = Calendar(identifier: .gregorian)
        if let nextAlarm = nextAlarm {
            var dateComponents = calendar.dateComponents(in: .current, from: Date())
            dateComponents.hour = nextAlarm.time.hour
            dateComponents.minute = nextAlarm.time.min
            dateComponents.second = 0
            return Calendar(identifier: .gregorian).date(from: dateComponents)
        } else {
            let midnight = calendar.startOfDay(for: Date())
            return calendar.date(byAdding: .day, value: 1, to: midnight)
        }
    }
    
    // Observe notifications for alarm changes to reset timer
    
    private  func addDefaultsObservers() {
        UserDefaults.standard.addObserver(self,
                                          forKeyPath: K.alarmsKey,
                                          options: NSKeyValueObservingOptions.new,
                                          context: nil)
    }
    
    func removeObservers() {
        UserDefaults.standard.removeObserver(self, forKeyPath: K.alarmsKey)
        playlistTimer?.invalidate()
    }
    
    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?) {
        
        if keyPath == K.alarmsKey {
            setUpPlaylistChangeTimer()
        }
    }
}
