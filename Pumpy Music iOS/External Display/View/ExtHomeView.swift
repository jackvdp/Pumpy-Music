//
//  HomeView.swift
//  Pumpy Music iOS
//
//  Created by Jack Vanderpump on 17/04/2021.
//  Copyright © 2021 Jack Vanderpump. All rights reserved.
//

import SwiftUI

extension ExternalDisplayView {

    struct HomeView: View {
        
        @EnvironmentObject var extDisMgr: ExternalDisplayManager
        
        var body: some View {
            GeometryReader { geo in
                ZStack() {
                    ArtworkView(contentType: .background, blur: Int(geo.size.width / 10))
                    VStack {
                        switch extDisMgr.liveSettings.displayContent {
                        case .artworkAndTitles:
                            ArtworkAndTitleView(geo: geo)
                                .frame(height: extDisMgr.frameHeight(geo.size.height))
                        case .upNextArtwokAndTitles:
                            UpNextArtworkView(geo: geo)
                                .frame(height: extDisMgr.frameHeight(geo.size.height))
                        case .upNext:
                            UpNextView(fontStyle: .custom(K.Font.helveticaLight, size: geo.size.width * 0.03 * 0.75), opacity: 0.5, showButton: false)
                                .padding(geo.size.height * 0.05)
                                .frame(height: extDisMgr.frameHeight(geo.size.height))
                        }
                        if extDisMgr.liveSettings.showQRCode {
                            QRCodeView(width: geo.size.width, height: geo.size.height)
                                .frame(height: geo.size.height * 0.2)
                        }
                    }
                }
            }
        }

    }
    
}

struct ExHomeView_Previews: PreviewProvider {
    
    static let extDisManger = ExternalDisplayManager(username: "Test", musicManager: MusicManager(username: "Test", settingsManager: SettingsManager(username: "Test")))
    
    static var previews: some View {
        extDisManger.liveSettings.displayContent = .upNext
        return Group {
            ExternalDisplayView.HomeView()
                .environmentObject(MusicManager(username: "Test", settingsManager: SettingsManager(username: "Test")))
                .environmentObject(extDisManger)
                .previewLayout(.sizeThatFits)
                .frame(width: 1920, height: 1080)
            ExternalDisplayView.HomeView()
                .environmentObject(MusicManager(username: "Test", settingsManager: SettingsManager(username: "Test")))
                .environmentObject(extDisManger)
                .previewLayout(.sizeThatFits)
                .frame(width: 1080, height: 1920)
        }
    }
}


