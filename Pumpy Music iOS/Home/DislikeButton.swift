//
//  DislikeButton.swift
//  Pumpy Music iOS
//
//  Created by Jack Vanderpump on 16/08/2021.
//  Copyright © 2021 Jack Vanderpump. All rights reserved.
//

import SwiftUI

struct DislikeButton: View {
    
    let track: Track
    var nowPlayingManager: NowPlayingManager?
    @EnvironmentObject var blockedTracksManager: BlockedTracksManager
    
    @State private var rotation: Double = 0
    @State private var colour: Color = .white
    @State private var showAlert = false
    var size: CGFloat = 30
    
    var body: some View {
        Button(action: {
            if blockedTracksManager.unblockTrackOrAskToBlock(id: track.playbackID) {
                showAlert = true
            }
        }) {
            Image(systemName: "hand.thumbsup")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: size, height: size, alignment: .center)
                .foregroundColor(colour)
                .font(Font.title.weight(.thin))
                .rotationEffect(.degrees(rotation))
                .animation(.easeIn)
        }
        .buttonStyle(PlainButtonStyle())
        .alert(isPresented: $showAlert, content: createAlert)
        .onChange(of: blockedTracksManager.blockedTracks) { _ in
            setButton()
        }
        .onChange(of: nowPlayingManager?.currentTrack) { _ in
            setButton()
        }
    }
    
    func setButton() {
        withAnimation {
            if blockedTracksManager.blockedTracks.contains(track.playbackID) {
                rotation = 180
                colour = .red
            } else {
                rotation = 0
                colour = .white
            }
        }
    }
    
    func createAlert() -> Alert {
        return Alert(title: Text("Block \(track.title) by \(track.artist)"),
                     message: Text("Blocked tracks will be removed from playback."),
                     primaryButton: .default(Text("Cancel"), action: {}),
                     secondaryButton: .destructive(Text("Block"),
                                                   action: {
            blockedTracksManager.addTrackToBlockedList(id: track.playbackID)
        }))
    }

}

#if DEBUG
struct DislikeButton_Previews: PreviewProvider {
    
    static let musicManager = MusicManager(username: "Test", settingsManager: SettingsManager(username: "Test"))
    
    static let track: Track = Track(title: "Song name", artist: "Artist name", playbackID: "", isExplicit: true)
    
    static var previews: some View {
        DislikeButton(track: track)
            .environmentObject(musicManager.blockedTracksManager)
    }
}
#endif

