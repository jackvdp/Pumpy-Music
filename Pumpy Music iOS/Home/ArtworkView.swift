//
//  BackgroundView.swift
//  Pumpy Music iOS
//
//  Created by Jack Vanderpump on 20/04/2020.
//  Copyright © 2020 Jack Vanderpump. All rights reserved.
//

import SwiftUI
import PumpyLibrary

struct ArtworkView: View {
    
    let contentType: Content
    var blur = 100
    @State private var imageSelection = ImageChoice.imageA
    @State private var imageA: UIImage?
    @State private var imageB: UIImage?
    
    @EnvironmentObject var musicManager: MusicManager
    
    var body: some View {
        ZStack {
            if imageSelection == .imageA {
                switch contentType {
                case .artwork:
                    Artwork(artwork: imageA ?? musicManager.nowPlayingManager.currentArtwork)
                case .background:
                    BackgroundImage(backgroundArtwork: imageA, blur: blur)
                }
            } else {
                switch contentType {
                case .artwork:
                    Artwork(artwork: imageB ?? musicManager.nowPlayingManager.currentArtwork)
                case .background:
                    BackgroundImage(backgroundArtwork: imageB, blur: blur)
                }
            }
        }
        .onReceive(musicManager.nowPlayingManager.$currentArtwork) { image in
            withAnimation {
                if imageSelection == .imageA {
                    if imageA != image {
                        imageB = image
                        imageSelection = .imageB
                    }
                } else {
                    if imageB != image {
                        imageA = image
                        imageSelection = .imageA
                    }
                }
            }
        }
    }
    
    
}

#if DEBUG
struct ArtworkView_Previews: PreviewProvider {
    
    static let user = User(username: "Test")
    
    static var previews: some View {
        ArtworkView(contentType: .artwork)
            .environmentObject(user.musicManager)
    }
}
#endif


extension ArtworkView {
    
    struct Artwork: View {
        let artwork: UIImage?
        let defaultArtwork = UIImage(imageLiteralResourceName: K.defaultArtwork)
        
        var body: some View {
            if let artwork = artwork {
                Image(uiImage: artwork)
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
            } else {
                Image(uiImage: defaultArtwork)
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
            }
        }
    }

    struct BackgroundImage: View {
        
        var backgroundArtwork: UIImage?
        let blur: Int
        
        var body: some View {
            GeometryReader { geometry in
                ZStack {
                    if let image = backgroundArtwork {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(geometry.size, contentMode: .fill)
                            .edgesIgnoringSafeArea(.all)
                            .blur(radius: geometry.size.height / 17, opaque: true)
                    } else {
                        BackgroundView()
                    }
                    Rectangle().fill(
                        LinearGradient(gradient: Gradient(colors: [Color.black.opacity(0.1), Color.black.opacity(0.4)]), startPoint: .top, endPoint: .bottom)
                    ).edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
                }
            }

        }
    }

    
    enum ImageChoice {
        case imageA
        case imageB
    }
    
    enum Content {
        case artwork
        case background
    }
}

