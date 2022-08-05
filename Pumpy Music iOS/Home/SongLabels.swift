//
//  SongLabelsView.swift
//  Pumpy Music iOS
//
//  Created by Jack Vanderpump on 20/04/2020.
//  Copyright © 2020 Jack Vanderpump. All rights reserved.
//

import SwiftUI
import PumpyLibrary

struct SongLabels: View {
    
    @EnvironmentObject var nowPlayingManager: NowPlayingManager
    @EnvironmentObject var musicManager: MusicManager
    
    var size: CGFloat = 17
    var mainFont = K.Font.helvetica
    var subFont = K.Font.helveticaLight
    var mainFontOpacity = 1.0
    var subFontOpacity = 1.0
    var padding: CGFloat = 0
    var fontWeight: Font.Weight?
    var showNowPlaying = false
    var showPlaylistLabel = true
    
    var body: some View {
        VStack(spacing: 5.0) {
            if showNowPlaying {
                Text("Now playing")
                    .foregroundColor(Color.white)
                    .fontWeight(fontWeight)
                    .font(.custom(subFont, size: size * 0.75))
                    .lineLimit(1)
                    .opacity(subFontOpacity)
                    .padding(padding)
            }
            Text(nowPlayingManager.currentTrack?.title ?? "Not Playing")
                .foregroundColor(Color.white)
                .fontWeight(fontWeight)
                .font(.custom(mainFont, size: size))
                .lineLimit(1)
                .padding(padding)
            Text(nowPlayingManager.currentTrack?.artist ?? "– – – – –")
                .foregroundColor(Color.white)
                .fontWeight(fontWeight)
                .font(.custom(subFont, size: size))
                .lineLimit(1)
                .opacity(subFontOpacity)
                .padding(padding)
            if showPlaylistLabel {
                Text(musicManager.playlistManager.playlistLabel)
                    .foregroundColor(Color.white)
                    .fontWeight(fontWeight)
                    .font(.custom(subFont, size: size))
                    .lineLimit(1)
                    .opacity(subFontOpacity)
            }
        }
    }
}


#if DEBUG
struct SongLabels_Previews: PreviewProvider {
    
    static let user = User(username: "Test")
    
    static var previews: some View {
        user.musicManager.nowPlayingManager.currentTrack = MockData.track
        user.musicManager.playlistManager.playlistLabel = "Tets Playlist"
        return SongLabels()
            .environmentObject(user.musicManager)
            .environmentObject(user.musicManager.nowPlayingManager)
    }
}
#endif
