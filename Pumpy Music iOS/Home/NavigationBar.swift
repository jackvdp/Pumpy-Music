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
    @EnvironmentObject var homeVM: HomeVM
        
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
            menuButton
        }
        .sheet(isPresented: $showChart) {
            AnalyticsView()
                .environmentObject(nowPlayingManager)
        }
    }
    
    var menuButton: some View {

        NavigationLink(destination: MenuView(), isActive: $homeVM.showMenu) {
            Button(action: {
                homeVM.showMenu.toggle()
            }) {
                Image(systemName: "line.horizontal.3")
                    .resizable()
                    .foregroundColor(Color.white)
                    .frame(width: 25, height: 25, alignment: .center)
                    .aspectRatio(contentMode: .fit)
                    .font(Font.title.weight(.ultraLight))
            }
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
