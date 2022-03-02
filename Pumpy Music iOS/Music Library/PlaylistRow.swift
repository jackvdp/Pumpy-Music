//
//  PlaylistRow.swift
//  PlaylistPicker
//
//  Created by Jack Vanderpump on 30/11/2019.
//  Copyright © 2019 Jack Vanderpump. All rights reserved.
//

import SwiftUI
import MediaPlayer

struct PlaylistRow : View {

    let playlist: Playlist
    
    var body: some View {
        HStack(alignment: .center, spacing: 20.0) {
            Image("Pumpy Artwork")
                .resizable()
                .renderingMode(.original)
                .aspectRatio(contentMode: .fill)
                .frame(width: 75, height: 75)
                .cornerRadius(10)
            Text(playlist.item.name ?? "")
                .font(.headline)
        }
        .padding(.all, 10.0)
    }
}

struct PlaylistRow_Previews: PreviewProvider {
    static var previews: some View {
        PlaylistRow(playlist: Playlist(item: MPMediaPlaylist()))
    }
}
