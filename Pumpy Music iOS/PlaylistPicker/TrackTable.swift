//
//  TrackTable.swift
//  PlaylistPicker
//
//  Created by Jack Vanderpump on 30/11/2019.
//  Copyright © 2019 Jack Vanderpump. All rights reserved.
//

import SwiftUI
import Combine

struct TrackTable: View {
    
    let trackClass: Tracks = Tracks()
    var playlistName: String
    
    var body: some View {
        trackClass.getTracks(chosenPlaylist: playlistName)
        return VStack(alignment: .leading) {
            Spacer()
            Divider()
            HStack(alignment: .center, spacing: 20.0) {
                playNextButton(playlistName: playlistName)
                playNowButton(playlistName: playlistName)
            }
            .padding(.all, 10.0)
            Divider()
            List(trackClass.trackArray, id: \.self) { trackSingle in TrackRow(track: trackSingle)}
            .navigationBarTitle(playlistName)
        }
    }
}


struct TrackTable_Previews: PreviewProvider {
    static var previews: some View {
        TrackTable(playlistName: "Pumpy Bar Early")
    }
}


extension Color {
    static let greyBGColour = Color("lightGrey")
    static let pumpyPink = Color("pumpyPink")
}

struct playNextButton: View {
    @State private var showingAlert = false
    let musicManager = MusicManager.sharedMusicManager

    var playlistName: String
    var body: some View {
        Button(action: {
            self.showingAlert = true
            self.musicManager.playPlaylistNext(chosenPlaylist: self.playlistName)
        }) {
            Text("Play Next")
        }
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("Added to Queue"), message: Text("Playlist will play at the end of the current track."), dismissButton: .default(Text("Got it!")))
        }
        .frame(minWidth: 100, maxWidth: .infinity, minHeight: 50, maxHeight: 50)
        .foregroundColor(.pumpyPink)
        .background(Color.greyBGColour)
        .cornerRadius(10)
    }
}

struct playNowButton: View {
    let musicManager = MusicManager.sharedMusicManager

    var playlistName: String
    
    var body: some View {
        Button(action: {
            self.musicManager.playPlaylistNow(chosenPlaylist: self.playlistName)
        }) {
            Text("Play Now")
        }
        .frame(minWidth: 100, maxWidth: .infinity, minHeight: 50, maxHeight: 50)
        .foregroundColor(.pumpyPink)
        .background(Color.greyBGColour)
        .cornerRadius(10)
    }
}
