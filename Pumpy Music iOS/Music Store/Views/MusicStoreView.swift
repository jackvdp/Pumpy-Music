//
//  SearchView.swift
//  Pumpy Music iOS
//
//  Created by Jack Vanderpump on 24/03/2021.
//  Copyright © 2021 Jack Vanderpump. All rights reserved.
//

import SwiftUI
import StoreKit
import MediaPlayer
import SDWebImageSwiftUI

struct MusicStoreView: View {
    
    @StateObject var storeVM: StoreVM
    @State private var itemSelected: MusicStoreItem? = nil
        
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 10) {
                MSSearchBar(storeVM: storeVM)
                if storeVM.searchTracks.isEmpty && storeVM.searchPlaylists.isEmpty {
                    RecommendedView(storeVM: storeVM)
                } else {
                    if !storeVM.searchTracks.isEmpty {
                        MusicStoreView.Headline(text: "Tracks")
                        MSTrackRow(items: storeVM.searchTracks, itemSelected: $itemSelected)
                        Divider()
                    }
                    if !storeVM.searchPlaylists.isEmpty {
                        MusicStoreView.Headline(text: "Playlists")
                        MSPlaylistRow(storeVM: storeVM)
                    }
                    Spacer()
                }
            }
            .edgesIgnoringSafeArea(.bottom)
            if itemSelected != nil {
                OverlayView(itemSelected: $itemSelected, storeVM: storeVM)
            }
            ActivityView(activityIndicatorVisible: $storeVM.showActivityIndicator)
        }
        .navigationTitle("Music Store")
    }
    
    struct Headline: View {
        var text: String
        var body: some View {
            Text(text)
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.horizontal)
        }
    }
}
