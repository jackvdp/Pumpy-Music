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
import PumpyLibrary

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
                    ForEach(tracks, id: \.playbackStoreID) { track in
                        Divider()
                        TrackRow<TokenManager,
                                 NowPlayingManager,
                                 BlockedTracksManager>(track: track)
                            .id(track.playbackStoreID)
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
    
    static let mm = MusicManager(username: "Test", settingsManager: SettingsManager(username: "Test"))
    
    static var previews: some View {
        TrackTable(playlist: MockData.playlist)
            .environmentObject(mm)
            .environmentObject(HomeVM(alarmData: AlarmData(username: "test"), playlistManager: mm.playlistManager))
    }
}
#endif
