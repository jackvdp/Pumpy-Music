//
//  ItemsView.swift
//  Pumpy Music iOS
//
//  Created by Jack Vanderpump on 11/04/2021.
//  Copyright © 2021 Jack Vanderpump. All rights reserved.
//

import SwiftUI
import SDWebImageSwiftUI
import AlertToast
import PumpyLibrary

struct DetailsView: View {
    
    let object: MusicStoreItem
    @ObservedObject var storeVM: StoreVM
    @EnvironmentObject var musicManager: MusicManager
    @State private var showingAlert = false
    
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .bottom) {
                VStack {
                    WebImage(url: Artwork.makeMusicStoreURL(object.artworkURL, size: Int(geo.size.height / 3)))
                        .placeholder(Image(K.defaultArtwork).resizable())
                        .resizable()
                        .cornerRadius(10)
                        .frame(width: geo.size.height / 3, height:  geo.size.height / 3, alignment: .center)
                        .shadow(color: .black, radius:10)
                    Text(object.name)
                        .font(.title2)
                        .fontWeight(.bold)
                    Text(object.artistName)
                        .font(.title3)
                    Divider()
                    MSDetailTrackRow(tracks: storeVM.itemTracks)
                    Spacer()
                }
                .edgesIgnoringSafeArea(.bottom)
                .padding(.top, -50)
                if !(object.type == .station) {
                    PlayNextNowRow {
                        self.showingAlert = true
                        storeVM.playItems(object, .next)
                    } playNowAction: {
                        storeVM.playItems(object, .now)
                    }
                }
            }
            .onAppear() {
                storeVM.getTracksForItem(item: object)
            }
            .toast(isPresenting: $showingAlert) {
                AlertToast(displayMode: .alert,
                           type: .systemImage("plus", .pumpyPink),
                           title: "Playing Next")
            }
        }
    }
    
    
}

struct ItemsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DetailsView(object: MusicStoreItem(id: "", name: "Test", artistName: "Test", artworkURL: "", isExplicit: false, type: .playlist),storeVM: StoreVM(musicManager: MusicManager(username: "Test", settingsManager: SettingsManager(username: "Test")), token: "", storeFront: ""))
        }
    }
}
