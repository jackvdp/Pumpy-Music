//
//  MenuView.swift
//  Pumpy Music iOS
//
//  Created by Jack Vanderpump on 10/03/2021.
//  Copyright © 2021 Jack Vanderpump. All rights reserved.
//

import SwiftUI

struct MenuView: View {
    
    @EnvironmentObject var accountVM: AccountManager
    @EnvironmentObject var settings: SettingsManager
    @EnvironmentObject var musicManager: MusicManager
    @EnvironmentObject var user: User
    @State private var showingAlert = false
    @Environment(\.musicStoreKey) var appleMusicToken
    @Environment(\.musicStoreFrontKey) var appleMusicStoreFront
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    Section {
                        if settings.settings.showMusicLibrary {
                            NavigationLink(destination: PlaylistTable()) {
                                MenuRow(title: "Music Library", imageName: "music.note.list")
                            }
                        }
                        if settings.settings.showMusicStore {
                            if let token = appleMusicToken, let sfID = appleMusicStoreFront {
                                NavigationLink(destination: MusicStoreView(storeVM: StoreVM(musicManager: musicManager, token: token, storeFront: sfID))) {
                                    MenuRow(title: "Music Store", imageName: "music.mic")
                                }
                            }
                        }
                    }
                    Section {
                        if settings.settings.showScheduler {
                            NavigationLink(destination: ScheduleView(scheduleViewModel: ScheduleViewModel(user: user))) {
                                MenuRow(title: "Playlist Schedule", imageName: "clock")
                            }
                        }
                        if settings.settings.showBlocked {
                            if let token = appleMusicToken, let sfID = appleMusicStoreFront {
                                NavigationLink(destination: BlockedTracksView(token: token, storeFront: sfID)) {
                                    MenuRow(title: "Blocked Tracks", imageName: "hand.thumbsdown")
                                }
                            }
                            
                        }
                    }
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
                .navigationBarTitle("Menu")
                .navigationViewStyle(StackNavigationViewStyle())
                .listStyle(InsetGroupedListStyle())
                HStack {
                    Text("Account: ")
                        .foregroundColor(.gray)
                    Text(user.username)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                    Text(" | v\(K.versionNumber)")
                        .foregroundColor(.gray)
                }.padding()
            }
        }
        .alert(isPresented: $showingAlert) {
            Alert(
                title: Text("Sign Out?"),
                message: Text("Are you sure you want to log out?"),
                primaryButton: .destructive(Text("Sign Out")) {
                    accountVM.signOut()
                },
                secondaryButton: .cancel()
            )
        }
        .accentColor(.pumpyPink)
    }
    
}

struct MenuView_Previews: PreviewProvider {
    static var previews: some View {
        MenuView()
    }
}
