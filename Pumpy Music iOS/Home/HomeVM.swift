//
//  HomeVM.swift
//  Pumpy Music iOS
//
//  Created by Jack Vanderpump on 20/04/2021.
//  Copyright © 2021 Jack Vanderpump. All rights reserved.
//

import Foundation
import SwiftUI
import PumpyLibrary

class HomeVM: HomeProtocol {

    @Published var pageType: PageType = .artwork
    @Published var showMenu = false {
        didSet {
            print("********** \(showMenu)")
        }
    }
    let alarmData: AlarmData
    let playlistManager: PlaylistManager
    
    init(alarmData: AlarmData, playlistManager: PlaylistManager) {
        self.alarmData = alarmData
        self.playlistManager = playlistManager
    }
    
    func playPause() {
        MusicCoreFunctions.togglePlayPause(alarms: alarmData.alarmArray,
                                           playlistManager: playlistManager)
    }
    
    func coldStart() {
        MusicCoreFunctions.coldStart(alarms: alarmData.alarmArray,
                                     playlistManager: playlistManager)
    }
    
    func skipToNextItem() {
        MusicCoreFunctions.skipToNextItem()
    }
    
}
