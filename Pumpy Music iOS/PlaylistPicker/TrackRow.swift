//
//  TrackRow.swift
//  Pumpy Music iOS
//
//  Created by Jack Vanderpump on 02/12/2019.
//  Copyright © 2019 Jack Vanderpump. All rights reserved.
//

import SwiftUI
import MediaPlayer

struct TrackRow : View {
    var track: Track

    var body: some View {
        HStack(alignment: .center, spacing: 20.0) {
            Image(uiImage: track.artwork.image(at: CGSize(width: 75, height: 75)) ?? UIImage(imageLiteralResourceName: "Pumpy Artwork"))
                .resizable()
                .renderingMode(.original)
                .aspectRatio(contentMode: .fill)
                .frame(width: 75, height: 75)
                .cornerRadius(10)
                .shadow(radius: 10)
            VStack(alignment: .leading, spacing: 5.0) {
                Text(track.name)
                    .font(.headline)
                    .lineLimit(1)
                Text(track.artist)
                    .font(.subheadline)
                    .lineLimit(1)
                
            }
        }
        .padding(.all, 10.0)
    }
}

struct TrackRow_Previews: PreviewProvider {
    static var previews: some View {
        TrackRow(track: Track(name: "Track 1", artist: "Artist 1", artwork:MPMediaItemArtwork(image: UIImage(imageLiteralResourceName: "Pumpy Artwork"))))
    }
}
