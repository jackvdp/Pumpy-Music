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
    @Namespace var background
    
    var body: some View {
        NavigationView {
            playerView
                .navigationBarHidden(true)
                .navigationBarTitle("Player")
        }
        .accentColor(.pumpyPink)
        .environmentObject(homeVM)
        .navigationViewStyle(.stack)
    }
    
    var playerView: some View {
        VStack {
            NavigationBar()
            if isPortrait() {
                portraitView
            } else  {
                landscapeView
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(
            ArtworkView(contentType: .background)
                .transaction { t in
                                    t.animation = .none
                                }
        )
    }
    
    var portraitView: some View {
        VStack {
            Spacer()
            switch homeVM.pageType {
            case .artwork:
                ArtworkView(contentType: .artwork)
            case .upNext:
                UpNextView()
                    .padding(.horizontal, -20)
            }
            Spacer(minLength: 20)
            SongLabels().id(labels)
            Spacer(minLength: 20)
            PlayerControls().id(controls)
            Spacer(minLength: 20)
            VolumeControl()
        }
    }
    
    var landscapeView: some View {
        HStack(spacing: 5) {
            VStack {
                Spacer()
                ArtworkView(contentType: .artwork)
                Spacer(minLength: 20)
                SongLabels().id(labels)
                Spacer(minLength: 20)
                PlayerControls().id(controls)
                Spacer(minLength: 20)
                VolumeControl()
            }
            VStack {
                UpNextView()
            }
        }
    }
    
    func isPortrait() -> Bool {
        horizontalSizeClass == .compact && verticalSizeClass == .regular
    }
    
}

#if DEBUG
struct HomeView_Previews: PreviewProvider {
    
    static var user: User {
        let u = User(username: "Test")
        u.musicManager.nowPlayingManager.currentTrack = Track(title: "Test", artist: "Test", playbackID: "11", isExplicit: true)
        u.musicManager.playlistManager.playlistLabel = "Test Playlist"
        return u
    }
    static let homeVM = HomeVM()
    static var homeVM2: HomeVM {
        let h = HomeVM()
        h.showMenu = true
        return h
    }
    
    static var previews: some View {
        HomeView(homeVM: homeVM)
            .environmentObject(user)
            .environmentObject(user.musicManager)
            .environmentObject(user.musicManager.nowPlayingManager)
            .environmentObject(user.musicManager.playlistManager)
            .environmentObject(user.musicManager.blockedTracksManager)
            .environmentObject(user.settingsManager)
            .environmentObject(user.externalDisplayManager)
            .environmentObject(user.alarmData)
            .environmentObject(user.musicManager.tokenManager)
            .environmentObject(user.musicManager.queueManager)
        
    }
}
#endif
