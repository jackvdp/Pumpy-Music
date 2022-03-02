//
//  Crossfade.swift
//  Pumpy Music iOS
//
//  Created by Jack Vanderpump on 18/05/2021.
//  Copyright © 2021 Jack Vanderpump. All rights reserved.
//

import Foundation
import MediaPlayer

class Crossfade {
    var volume: Int = 100
    var changePlaylistAction: (() -> Void)?
    var completionHandler: () -> Void
    
    init(changePlaylist: (() -> Void)? = nil, completionHandler: @escaping () -> Void) {
        changePlaylistAction = changePlaylist
        self.completionHandler = completionHandler
        volume = getVolume()
        decreaseVolume()
    }
    
    deinit {
        print("deinit crossfade")
    }
    
    private func decreaseVolume() {
        var count = 0
        var currentVolume = volume
        Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true) { t in
            count += 1
            currentVolume = currentVolume - 10
            self.setVolume(currentVolume)
            if count >= 10 || currentVolume < 10 {
                t.invalidate()
                self.setVolume(currentVolume)
                self.changeTrack()
                self.increaseVolume()
            }
        }
    }
    
    private func increaseVolume() {
        var count = 0
        var currentVolume: Int = 0
        Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true){ t in
            count += 1
            currentVolume = currentVolume + 10
            self.setVolume(currentVolume)
            if count >= 10 || self.volume - 10 < currentVolume {
                t.invalidate()
                currentVolume = self.volume
                self.setVolume(currentVolume)
                self.completionHandler()
            }
        }
    }
    
    private func changeTrack() {
        if let action = changePlaylistAction {
            action()
        } else {
            MusicCoreFunctions.skipToNextItem()
        }
    }
    
    private func setVolume(_ volume: Int) {
        let floatyVolume = Float(volume) / 100
        MPVolumeView.setVolume(floatyVolume)
    }
    
    private func getVolume() -> Int {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.ambient)
        } catch {
            return 100
        }
        try? session.setActive(true)
        return Int(session.outputVolume * 100)
    }
}
