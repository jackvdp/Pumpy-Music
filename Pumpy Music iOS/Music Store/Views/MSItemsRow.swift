//
//  MSPlaylistROw.swift
//  Pumpy Music iOS
//
//  Created by Jack Vanderpump on 25/03/2021.
//  Copyright © 2021 Jack Vanderpump. All rights reserved.
//

import SwiftUI
import SDWebImageSwiftUI

struct MSTrackRow: View {
    
    var items: [MusicStoreItem]
    @Binding var itemSelected: MusicStoreItem?
    @EnvironmentObject var musicManager: MusicManager
    
    var body: some View {
        List (items, id:\.id) { playlist in
            HStack(alignment: .center, spacing: 20.0) {
                WebImage(url: Artwork.makeMusicStoreURL(playlist.artworkURL, size: 80))
                    .resizable()
                    .frame(width: 50, height: 50)
                    .cornerRadius(10)
                    .shadow(radius: 10)
                VStack(alignment: .leading, spacing: 5.0) {
                    Text(playlist.name)
                        .font(.headline)
                        .lineLimit(1)
                    Text(playlist.artistName)
                        .font(.subheadline)
                        .lineLimit(1)
                }
                Spacer()
                Button(action: {
                    withAnimation {
                        itemSelected = playlist
                    }
                }) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.pumpyPink)
                }
            }
        }
        .mask(
            LinearGradient(gradient: Gradient(colors: [Color.black, Color.black, Color.black, Color.black, Color.black, Color.black, Color.black, Color.black, Color.black.opacity(0)]), startPoint: .top, endPoint: .bottom)
        )
        .listStyle(PlainListStyle())
    }
}

struct MSPlaylistRow: View {
    
    @State private var actionSegue = false
    @State private var detailsView: AnyView = AnyView(EmptyView())
    @ObservedObject var storeVM: StoreVM
    @EnvironmentObject var musicManager: MusicManager
    
    var body: some View {
        List(storeVM.searchPlaylists, id:\.id) { playlist in
            HStack(alignment: .center, spacing: 20.0) {
                WebImage(url: Artwork.makeMusicStoreURL(playlist.artworkURL, size: 80))
                    .resizable()
                    .frame(width: 50, height: 50)
                    .cornerRadius(10)
                    .shadow(radius: 10)
                VStack(alignment: .leading, spacing: 5.0) {
                    Text(playlist.name)
                        .font(.headline)
                        .lineLimit(1)
                    Text(playlist.artistName)
                        .font(.subheadline)
                        .lineLimit(1)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.pumpyPink)
            }
            .onTapGesture {
                detailsView = AnyView(DetailsView(object: playlist, storeVM: storeVM))
                actionSegue = true
            }
        }
        .mask(
            LinearGradient(gradient: Gradient(colors: [Color.black, Color.black, Color.black, Color.black, Color.black, Color.black, Color.black, Color.black, Color.black.opacity(0)]), startPoint: .top, endPoint: .bottom)
        )
        .listStyle(PlainListStyle())
        .background(
            NavigationLink(destination: detailsView, isActive: $actionSegue) {}
        )
    }
}

struct MSDetailTrackRow: View {
    
    let tracks: [MusicStoreItem]
    @EnvironmentObject var musicManager: MusicManager
    
    var body: some View {
        List(tracks, id:\.id) { track in
            HStack(alignment: .center, spacing: 20.0) {
                WebImage(url: Artwork.makeMusicStoreURL(track.artworkURL, size: 80))
                    .resizable()
                    .frame(width: 50, height: 50)
                    .cornerRadius(10)
                    .shadow(radius: 10)
                VStack(alignment: .leading, spacing: 5.0) {
                    Text(track.name)
                        .font(.headline)
                        .lineLimit(1)
                    Text(track.artistName)
                        .font(.subheadline)
                        .lineLimit(1)
                }
                Spacer()
            }
        }
        .listStyle(PlainListStyle())
    }
}
