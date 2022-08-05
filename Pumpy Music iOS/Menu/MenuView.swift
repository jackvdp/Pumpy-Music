//
//  MenuView.swift
//  Pumpy Music iOS
//
//  Created by Jack Vanderpump on 10/03/2021.
//  Copyright © 2021 Jack Vanderpump. All rights reserved.
//

import SwiftUI
import Scheduler
import PumpyLibrary

struct MenuView: View {
    
    @EnvironmentObject var accountVM: AccountManager
    @EnvironmentObject var settings: SettingsManager
    @EnvironmentObject var musicManager: MusicManager
    @EnvironmentObject var tokenManager: TokenManager
    @EnvironmentObject var user: User
    @State private var showingAlert = false
    
    var body: some View {
        VStack {
            List {
                music
                scheduleAndBlocked
                settingsAndExtDisplay
                logoutButton
            }
            .listStyle(.insetGrouped)
            versionLabel
        }
        .navigationBarTitle("Menu")
        .navigationBarTitleDisplayMode(.large)
        .accentColor(.pumpyPink)
        .alert(isPresented: $showingAlert) {
            alertBox
        }
    }
    
    var music: some View {
        Section {
            if settings.settings.showMusicLibrary {
                NavigationLink(destination: PlaylistTable()) {
                    MenuRow(title: "Music Library", imageName: "music.note.list")
                }
            }
            if settings.settings.showMusicStore {
                if let token = tokenManager.appleMusicToken, let sfID = tokenManager.appleMusicStoreFront {
                    NavigationLink(destination: MusicStoreView(storeVM: StoreVM(musicManager: musicManager, token: token, storeFront: sfID))) {
                        MenuRow(title: "Music Store", imageName: "music.mic")
                    }
                }
            }
        }
    }
    
    var scheduleAndBlocked: some View {
        Section {
            if settings.settings.showScheduler {
                NavigationLink(destination: ScheduleView(user: user, getPlists: MusicContent.getPlaylists)) {
                    MenuRow(title: "Playlist Schedule", imageName: "clock")
                }
            }
            if settings.settings.showBlocked {
                if let token = tokenManager.appleMusicToken, let sfID = tokenManager.appleMusicStoreFront {
                    NavigationLink(destination: BlockedTracksView(token: token, storeFront: sfID)) {
                        MenuRow(title: "Blocked Tracks", imageName: "hand.thumbsdown")
                    }
                }
                
            }
        }
    }
    
    var settingsAndExtDisplay: some View {
        Section {
            NavigationLink(destination: SettingsView()) {
                MenuRow(title: "Settings", imageName: "gear")
            }
            if settings.settings.showExternalDisplay {
                NavigationLink(destination: ExtDisplaySettingsView()) {
                    MenuRow(title: "External Display", imageName: "tv")
                }
            }
        }
    }
    
    var logoutButton: some View {
        Section {
            Button {
                showingAlert.toggle()
            } label: {
                HStack {
                    MenuRow(title: "Log Out", imageName: "arrow.down.left.circle").foregroundColor(.white)
                    Spacer()
                }
            }
        }
    }
    
    var versionLabel: some View {
        Text("Account: \(user.username) | v\(K.versionNumber)")
            .foregroundColor(.gray)
            .lineLimit(1)
            .padding()
    }
    
    var alertBox: Alert {
        Alert(
            title: Text("Sign Out?"),
            message: Text("Are you sure you want to log out?"),
            primaryButton: .destructive(Text("Sign Out")) {
                accountVM.signOut()
            },
            secondaryButton: .cancel()
        )
    }
    
}

struct MenuView_Previews: PreviewProvider {
    
    static let user = User(username: "test")
    
    static var previews: some View {
        MenuView()
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
