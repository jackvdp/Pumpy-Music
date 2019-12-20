//
//  MusicArrays.swift
//  PlaylistPicker
//
//  Created by Jack Vanderpump on 01/12/2019.
//  Copyright © 2019 Jack Vanderpump. All rights reserved.
//

import Foundation
import MediaPlayer
import SwiftUI
import Combine
import UIKit

class MusicManager: NSObject, ObservableObject {
    static let sharedMusicManager = MusicManager()
    var timerTest : Timer?
    var nextPlaylist: String?
    let musicPlayerController = MPMusicPlayerController.systemMusicPlayer
    var playlistLabel: String = ""

    private override init() {}
    
    func playPlaylistNow(chosenPlaylist: String?) {
        print("Playing")
        let myMediaQuery = MPMediaQuery.songs()
        let predicateFilter = MPMediaPropertyPredicate(value: chosenPlaylist, forProperty: MPMediaPlaylistPropertyName)
        myMediaQuery.filterPredicates = NSSet(object: predicateFilter) as? Set<MPMediaPredicate>
        musicPlayerController.setQueue(with: myMediaQuery)
        musicPlayerController.repeatMode = .all
        musicPlayerController.shuffleMode = .songs
        musicPlayerController.prepareToPlay()
        musicPlayerController.play()
        playlistLabel = "Playlist: \(chosenPlaylist!)"
        print(playlistLabel)
    }
    
    func playPlaylistNext(chosenPlaylist: String?) {
        print("HERE")
        if musicPlayerController.playbackState == .playing {
            nextPlaylist = chosenPlaylist
            startTimer()
            if musicPlayerController.currentPlaybackTime > musicPlayerController.nowPlayingItem!.playbackDuration - 5 {
                playPlaylistNow(chosenPlaylist: chosenPlaylist)
                stopTimerTest()
            }
        } else {
            playPlaylistNow(chosenPlaylist: chosenPlaylist)
        }
    }
    
    // MARK: Timer Next Track
    
    @objc func playlistQueue() {
        if musicPlayerController.playbackState == .playing {
            if musicPlayerController.currentPlaybackTime > musicPlayerController.nowPlayingItem!.playbackDuration - 5 {
                playPlaylistNow(chosenPlaylist: nextPlaylist)
                stopTimerTest()
            }
        }
    }
    
    func startTimer() {
      guard timerTest == nil else { return }

      timerTest =  Timer.scheduledTimer(
          timeInterval: TimeInterval(1),
          target      : self,
          selector    : #selector(playlistQueue),
          userInfo    : nil,
          repeats     : true)
    }
    
    func stopTimerTest() {
        timerTest?.invalidate()
        timerTest = nil
    }

    
    
}

//class QD: MPMusicPlayerMediaItemQueueDescriptor {
//    override init(query: MPMediaQuery)
//}

//MARK: Arrays

class Playlists {
    
    var playlistArray: [Playlist] = []
    let playlists = MPMediaQuery.playlists().collections
    var trackArray: [Track] = []
    
    func getPlaylists() {
        playlistArray = []
        if playlists != nil {
        for playlist in playlists! {
            playlistArray.append(Playlist(name: (playlist.value(forProperty: MPMediaPlaylistPropertyName)! as! String)))
            }
        }
    }
    
}

struct Playlist: Hashable {
    var name: String
}


class Tracks {
    
    var trackArray: [Track] = []
    let playlists = MPMediaQuery.playlists().collections
    
    func getTracks(chosenPlaylist: String) {
        trackArray = []
        for playlist in playlists! {
            if (playlist.value(forProperty: MPMediaPlaylistPropertyName)as! String) == chosenPlaylist {
                let songs = playlist.items
                            for song in songs {
                                if song.artwork != nil {
                                trackArray.append(Track(name: (song.value(forProperty: MPMediaItemPropertyTitle) as! String), artist:(song.value(forProperty: MPMediaItemPropertyArtist) as! String), artwork: song.artwork!))
                                }
                            }
                sortArray()
            }
        }
    }
    
    func sortArray() {
        let sortedTracks = trackArray.sorted(by: { $0.artist < $1.artist})
        trackArray = sortedTracks
    }
  
}

struct Track: Hashable {
    var name: String
    var artist: String
    var artwork: MPMediaItemArtwork
}
