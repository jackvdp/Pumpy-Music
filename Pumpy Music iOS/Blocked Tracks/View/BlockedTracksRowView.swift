//
//  BlockedTracksRowView.swift
//  Pumpy Music iOS
//
//  Created by Jack Vanderpump on 17/08/2021.
//  Copyright © 2021 Jack Vanderpump. All rights reserved.
//

import SwiftUI
import ActivityIndicatorView

struct BlockedTracksRowView: View {
    
    @StateObject var blockedTrackVM: BlockedTrackViewModel
    
    var body: some View {
        HStack(alignment: .center, spacing: 20.0) {
            Image(uiImage: blockedTrackVM.artwork)
                .resizable()
                .renderingMode(.original)
                .aspectRatio(contentMode: .fill)
                .frame(width: 50, height: 50)
                .cornerRadius(10)
            VStack(alignment: .leading, spacing: 5.0) {
                Text(blockedTrackVM.trackTitle)
                    .font(.headline)
                    .lineLimit(1)
                    .foregroundColor(.white)
                Text(blockedTrackVM.trackArtist)
                    .font(.subheadline)
                    .lineLimit(1)
                    .foregroundColor(.white)
            }
            Spacer()
            ActivityIndicatorView(isVisible: $blockedTrackVM.loadingSpinnerOn, type: .arcs)
                .frame(width: 20, height: 20)
                .foregroundColor(Color(UIColor(named: K.pumpyPink)!))
        }
        .padding(.all, 5.0)
    }
}

struct BlockedTracksRowView_Previews: PreviewProvider {
    static var previews: some View {
        BlockedTracksRowView(blockedTrackVM: BlockedTrackViewModel(id: "", token: "", storeFront: ""))
    }
}
