//
//  RecommendedView.swift
//  Pumpy Music iOS
//
//  Created by Jack Vanderpump on 09/04/2021.
//  Copyright © 2021 Jack Vanderpump. All rights reserved.
//

import SwiftUI
import SDWebImageSwiftUI
import PumpyLibrary

struct RecommendedView: View {
    
    @ObservedObject var storeVM: StoreVM
    @EnvironmentObject var musicManager: MusicManager
    @State private var actionSegue = false
    @State private var itemSelected: MusicStoreItem?
    @State private var detailsView: DetailsView?
    let rows = [
            GridItem(.adaptive(minimum: 120))
        ]
    
    var body: some View {
        List {
            ForEach(storeVM.recommendedCollections, id: \.self) { collection in
                Text(collection.title)
                    .font(.title)
                ScrollView(.horizontal) {
                    LazyHGrid(rows: rows, alignment: .center) {
                        ForEach(collection.objects, id: \.self) { object in
                            VStack {
                                WebImage(url: Artwork.makeMusicStoreURL(object.artworkURL, size: 100))
                                    .placeholder(Image(K.defaultArtwork).resizable())
                                    .resizable()
                                    .cornerRadius(10)
                                    .frame(width: 100, height: 100, alignment: .center)
                                Text(object.name)
                                    .lineLimit(2)
                                    .frame(width: 100, alignment: .leading)
                                Text(object.artistName)
                                    .foregroundColor(.gray)
                                    .lineLimit(1)
                                    .frame(width: 100, alignment: .leading)
                                Spacer()
                            }
                            .onTapGesture {
                                detailsView = DetailsView(object: object, storeVM: storeVM)
                                actionSegue = true
                            }
                            .onAppear() {
                                storeVM.itemTracks.removeAll()
                            }
                            .frame(width: 100)
                        }
                    }
                }
            }
        }
        .listStyle(.plain)
        .background(
            NavigationLink(destination: detailsView, isActive: $actionSegue) {}
        )
    }
}

//struct RecommendedView_Previews: PreviewProvider {
//    static var previews: some View {
//        RecommendedView(storeVM: StoreVM(), itemSelected: .constant(nil), collections: [
//            MSCollection(title: "Test", objects: [
//                MusicStoreItem(id: "Test", name: "Test", artistName: "Test", artworkURL: "Test", type: .playlist)
//            ])
//        ])
//    }
//}
