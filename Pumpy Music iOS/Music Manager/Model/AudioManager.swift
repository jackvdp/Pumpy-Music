//
//  AudioManager.swift
//  Pumpy Music iOS
//
//  Created by Jack Vanderpump on 28/06/2020.
//  Copyright © 2020 Jack Vanderpump. All rights reserved.
//

import Foundation
import AVFoundation

class AudioPlayer {
    
    var audioPlayer: AVAudioPlayer?
    var fileURL: URL?

    func playSoundsFromURL(url: URL) {
        do {
            let session: AVAudioSession = AVAudioSession.sharedInstance()
            do {
                try session.setCategory(AVAudioSession.Category.playback)
            } catch {}
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.volume = 1
        } catch {
            print(error)
        }
        
        guard let player = audioPlayer else {
            print("Error")
            return
        }
        
        player.prepareToPlay()
        player.play()
    }
    
    func getPlaybackTime() -> Double {
        return audioPlayer?.duration ?? 0
    }
    
}
