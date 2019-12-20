//
//  PlaylistTable.swift
//  PlaylistPicker
//
//  Created by Jack Vanderpump on 30/11/2019.
//  Copyright © 2019 Jack Vanderpump. All rights reserved.
//

import SwiftUI



struct PlaylistTable: View {
    let playlistClass: Playlists = Playlists()
    let trackClass: Tracks = Tracks()
    
    var body: some View {
        
        playlistClass.getPlaylists()
        
        return NavigationView {
            List(playlistClass.playlistArray, id: \.self)
            { playlistSingle in
                NavigationLink(destination: TrackTable(playlistName: playlistSingle.name))
                {
                    PlaylistRow(playlistArray: playlistSingle)
                }
            }
            .navigationBarTitle("Playlists")
        }
    }
}

struct PlaylistTable_Previews: PreviewProvider {
    static var previews: some View {
        PlaylistTable()
    }
}
