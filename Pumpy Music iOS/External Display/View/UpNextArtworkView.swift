//
//  UpNextArtworkView.swift
//  Pumpy Music iOS
//
//  Created by Jack Vanderpump on 26/04/2021.
//  Copyright © 2021 Jack Vanderpump. All rights reserved.
//

import SwiftUI
import PumpyLibrary

struct UpNextArtworkView: View {
    
    let geo: GeometryProxy
    @EnvironmentObject var extDisMgr: ExternalDisplayManager
    var subFont = K.Font.helveticaLight
    
    var body: some View {
        if geo.size.height >= geo.size.width {
            VStack {
                ArtworkView(contentType: .artwork)
                    .padding(geo.size.height * 0.05)
                    .frame(height: extDisMgr.frameHeight(geo.size.height * 0.4))
                SongLabels(size: geo.size.width * 0.03,
                           subFontOpacity: 0.5,
                           padding: geo.size.width * 0.005,
                           showNowPlaying: true,
                           showPlaylistLabel: false)
                    .padding(geo.size.height * 0.05)
                    .frame(height: extDisMgr.frameHeight(geo.size.height * 0.1))
                UpNextView(fontStyle: .custom(subFont, size: geo.size.width * 0.03 * 0.75), opacity: 0.5, showButton: false)
                    .padding(geo.size.height * 0.05)
                    .frame(height: extDisMgr.frameHeight(geo.size.height * 0.5))
            }
        } else {
            HStack {
                VStack {
                    ArtworkView(contentType: .artwork)
                        .padding(geo.size.height * 0.05)
                        .frame(width: geo.size.width * 0.5)
                    SongLabels(size: geo.size.height * 0.03,
                               subFontOpacity: 0.5,
                               padding: geo.size.width * 0.005,
                               showNowPlaying: true,
                               showPlaylistLabel: false)
                        .padding(geo.size.height * 0.05)
                        .frame(width: geo.size.width * 0.5)
                }.frame(width: extDisMgr.frameHeight(geo.size.width * 0.5))
                VStack {
                    UpNextView(fontStyle: .custom(subFont, size: geo.size.height * 0.03 * 0.75), opacity: 0.5, showButton: false)
                        .padding(geo.size.height * 0.05)
                }.frame(width: extDisMgr.frameHeight(geo.size.width * 0.5))
            }
        }
    }
}

struct UpNextArtworkView_Previews: PreviewProvider {
    static let musicManager = MusicManager(username: "Test", settingsManager: SettingsManager(username: "Test"))
    static let extDisManger = ExternalDisplayManager(username: "Test", musicManager: musicManager)
    
    static var previews: some View {
        extDisManger.liveSettings.showQRCode = true
        extDisManger.liveSettings.displayContent = .upNextArtwokAndTitles
        return Group {
            ExternalDisplayView.HomeView()
                .environmentObject(musicManager)
                .environmentObject(extDisManger)
                .previewLayout(.sizeThatFits)
                .frame(width: 1080, height: 1920)
            ExternalDisplayView.HomeView()
                .environmentObject(musicManager)
                .environmentObject(extDisManger)
                .previewLayout(.sizeThatFits)
                .frame(width: 1920, height: 1080)
        }
    }
}
