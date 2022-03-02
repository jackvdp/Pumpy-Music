//
//  HomeView.swift
//  Pumpy Music iOS
//
//  Created by Jack Vanderpump on 03/12/2019.
//  Copyright © 2019 Jack Vanderpump. All rights reserved.
//

import SwiftUI

struct HomeView: View {
    
    @StateObject var homeVM: HomeVM
    @Environment(\.verticalSizeClass) var verticalSizeClass: UserInterfaceSizeClass?
    @Environment(\.horizontalSizeClass) var horizontalSizeClass: UserInterfaceSizeClass?
    @Namespace var controls
    @Namespace var labels
    
    var body: some View {
        ZStack() {
            ArtworkView(contentType: .background)
            VStack(spacing: 5) {
                NavigationBar()
                Spacer()
                //portrait
                if horizontalSizeClass == .compact && verticalSizeClass == .regular  {
                    switch homeVM.pageType {
                    case .artwork:
                        ArtworkView(contentType: .artwork)
                    case .upNext:
                        UpNextView()
                            .padding(.horizontal, -20)
                    }
                    Spacer()
                    SongLabels().id(labels)
                    Spacer()
                    PlayerControls().id(controls)
                    Spacer()
                    VolumeControl()
                //landscape
                } else  {
                    HStack(spacing: 5) {
                        VStack(spacing: 5) {
                            Spacer()
                            ArtworkView(contentType: .artwork)
                            Spacer()
                            SongLabels().id(labels)
                            Spacer()
                            PlayerControls().id(controls)
                            Spacer()
                            VolumeControl()
                        }
                        VStack {
                            UpNextView()
                        }
                    }
                }
            }
            .animation(.easeIn(duration: 0.5))
            .padding([.horizontal, .bottom], 20)
            .padding(.top, 10)
        }
        .environmentObject(homeVM)
    }
    
}

#if DEBUG
struct HomeView_Previews: PreviewProvider {
    
    static let user = User(username: "Test")
    static let homeVM = HomeVM()
    
    static var previews: some View {
        user.musicManager.nowPlayingManager.currentTrack = Track(title: "Test", artist: "Test", playbackID: "11", isExplicit: true)
        user.musicManager.playlistManager.playlistLabel = "Test Playlist"
        homeVM.pageType = .upNext
        return HomeView(homeVM: homeVM)
            .environmentObject(user.musicManager)
            .environmentObject(user.musicManager.nowPlayingManager)
            .environmentObject(user.musicManager.playlistManager)
            .environmentObject(user.musicManager.blockedTracksManager)
            .environmentObject(user.settingsManager)
            .environmentObject(user.externalDisplayManager)
//            .environmentObject(user.repeatManager)
            .environmentObject(user.alarmData)
            .environmentObject(user.musicManager.tokenManager)
            .environmentObject(user.musicManager.queueManager)
            .environment(\.musicStoreKey, user.musicManager.tokenManager.appleMusicToken)
            .environment(\.musicStoreFrontKey, user.musicManager.tokenManager.appleMusicStoreFront)
//            .environment(\.settingsKey, user.settingsManager.settings)
    }
}
#endif

