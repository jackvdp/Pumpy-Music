//
//  PlaylistTable.swift
//  PlaylistPicker
//
//  Created by Jack Vanderpump on 30/11/2019.
//  Copyright © 2019 Jack Vanderpump. All rights reserved.
//

import SwiftUI
import Introspect
import MediaPlayer
import PumpyLibrary

struct PlaylistTable: View {
    
    @State private var playlists = [Playlist]()
    @State private var tableView: UITableView?
    
    var body: some View {
        List(playlists, id: \.cloudGlobalID) { playlistSingle in
            NavigationLink(destination: TrackTable(playlist: playlistSingle)) {
                PlaylistRow(playlist: playlistSingle)
            }
        }
        .listStyle(.plain)
        .onAppear() {
            deselectRows()
            playlists = MusicContent.getPlaylists()
        }
        .navigationBarTitle("Playlists")
        .accentColor(.pumpyPink)
        .introspectTableView(customize: { tableView in
            self.tableView = tableView
        })
    }
    
    private func deselectRows() {
        if let tableView = tableView, let selectedRow = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedRow, animated: true)
        }
    }
}

struct PlaylistTable_Previews: PreviewProvider {
    static var previews: some View {
        PlaylistTable()
    }
}
