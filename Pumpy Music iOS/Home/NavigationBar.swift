//
//  NavigationBarView.swift
//  Pumpy Music iOS
//
//  Created by Jack Vanderpump on 20/04/2020.
//  Copyright © 2020 Jack Vanderpump. All rights reserved.
//

import SwiftUI

struct NavigationBar: View {
    
    @EnvironmentObject var nowPlayingManager: NowPlayingManager
    @EnvironmentObject var blockedTracksManager: BlockedTracksManager
    @State private var showChart = false
        
    var body: some View {
        HStack {
            if let track = nowPlayingManager.currentTrack {
                DislikeButton(track: track, nowPlayingManager: nowPlayingManager)
            }
            Spacer()
            PumpyView()
                .frame(width: 120, height: 40)
                .onTapGesture {
                    self.showChart = true
                }
            Spacer()
            MenuButton()
        }
        .sheet(isPresented: $showChart) {
            AnalyticsView()
                .environmentObject(nowPlayingManager)
        }
    }
    
}


#if DEBUG
struct NavBar_Previews: PreviewProvider {
    
    static let musicManager = MusicManager(username: "Test", settingsManager: SettingsManager(username: "Test"))
    
    static var previews: some View {
        NavigationBar()
            .environmentObject(HomeVM())
            .environmentObject(musicManager.blockedTracksManager)
            .environmentObject(musicManager.nowPlayingManager)
    }
}
#endif
