//
//  TrackTable.swift
//  PlaylistPicker
//
//  Created by Jack Vanderpump on 30/11/2019.
//  Copyright © 2019 Jack Vanderpump. All rights reserved.
//

import SwiftUI
import Combine
import MediaPlayer
import AlertToast

struct TrackTable: View {
    
    @EnvironmentObject var musicManager: MusicManager
    @EnvironmentObject var homeVM: HomeVM
    let playlist: Playlist
    @State private var tracks = [Track]()
    @State private var showingAlert = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                LazyVStack(alignment: .leading) {
                    Text(tracks.count == 1 ? "1 song" : "\(tracks.count) songs")
                        .font(.footnote)
                        .foregroundColor(Color.gray)
                    ForEach(tracks, id: \.id) { track in
                        Divider()
                        TrackRow(track: track).id(track.id)
                    }
                }
                .padding(.leading)
            }
            PlayNextNowRow {
                self.showingAlert = true
                if let name = playlist.name {
                    self.musicManager.playlistManager.playPlaylistNext(playlist: name)
                }
            } playNowAction: {
                if let name = playlist.name {
                    self.musicManager.playlistManager.playPlaylistNow(playlist: name)
                    self.homeVM.showMenu = false
                }
            }
        }
        .onAppear() {
            tracks = playlist.items
        }
        .navigationBarTitle(playlist.name ?? "")
        .toast(isPresenting: $showingAlert) {
            AlertToast(displayMode: .alert,
                       type: .systemImage("plus", .pumpyPink),
                       title: "Playing Next")
        }
    }
}

#if DEBUG
struct TrackTable_Previews: PreviewProvider {
    static var previews: some View {
        TrackTable(playlist: Playlist(item: MPMediaPlaylist()))
            .environmentObject(MusicManager(username: "Test", settingsManager: SettingsManager(username: "Test")))
            .environmentObject(HomeVM())
    }
}
#endif
