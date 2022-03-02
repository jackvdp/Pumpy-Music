//
//  Queue.swift
//  Pumpy Music iOS
//
//  Created by Jack Vanderpump on 22/04/2021.
//  Copyright © 2021 Jack Vanderpump. All rights reserved.
//

import Foundation
import MediaPlayer

class QueueManager: ObservableObject {
    
    var username: String
    let musicPlayerController = MPMusicPlayerController.applicationQueuePlayer
    let backgroundQueue = DispatchQueue(label: "com.pumpy.bgThread")
    let semaphore = DispatchSemaphore(value: 1)
    @Published var queueTracks = [Track]()
    @Published var queueIndex = 0
    @Published var readyToEditQueue = true
    
    init(name: String) {
        username = name
    }
    
    deinit {
        print("deiniting")
    }
        
    func getUpNext() {
        if readyToEditQueue {
            self.musicPlayerController.perform { (currentQueue) in
                return
            } completionHandler: { (newQueue, error) in
                if let e = error {
                    print(e)
                } else {
                    self.saveNewQueue(newQueue.items)
                }
            }
        }
    }
    
    func removeFromQueue(id: String) {
        if readyToEditQueue {
            self.musicPlayerController.perform { (currentQueue) in
                self.readyToEditQueue = false
                
                if let item = currentQueue.items.first(where: {
                    $0.playbackStoreID == id
                }) {
                    currentQueue.remove(item)
                }
            } completionHandler: { (newQueue, error) in
                self.readyToEditQueue = true
                if let e = error {
                    print(e)
                } else {
                    self.saveNewQueue(newQueue.items)
                }
            }
        }
    }
    
    func saveNewQueue(_ items: [MPMediaItem]) {
        DispatchQueue.main.async {
            self.readyToEditQueue = false
            self.backgroundQueue.async {
                self.semaphore.wait()
                let i = Array(items)
                let tracks = i.map { Track(track: $0) }
                DispatchQueue.main.async {
                    self.queueTracks = tracks
                    self.semaphore.signal()
                }
                PlaybackData.saveCurrentQueueOnline(items: tracks, for: self.username)
                DispatchQueue.main.async {
                    self.readyToEditQueue = true
                }
            }
        }
        
    }
    
    func getIndex() {
        let index = musicPlayerController.indexOfNowPlayingItem
        if index > 10000 {
            queueIndex = 0
        } else {
            queueIndex = index
        }
    }
    
}


