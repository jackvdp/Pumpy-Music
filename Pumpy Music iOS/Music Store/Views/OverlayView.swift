//
//  OverlayView.swift
//  Pumpy Music iOS
//
//  Created by Jack Vanderpump on 25/03/2021.
//  Copyright © 2021 Jack Vanderpump. All rights reserved.
//

import SwiftUI
import MediaPlayer
import SDWebImageSwiftUI

struct OverlayView: View {
    
    @EnvironmentObject var musicManager: MusicManager
    @Binding var itemSelected: MusicStoreItem?
    @ObservedObject var storeVM: StoreVM
    
    var body: some View {
        Rectangle()
            .fill(Color.black)
            .opacity(0.7)
            .edgesIgnoringSafeArea(.all)
            .onTapGesture {
                withAnimation {
                    itemSelected = nil
                }
            }
        VStack(spacing: 25) {
            Spacer()
            Text(itemSelected?.name ?? "")
                .font(.largeTitle)
                .shadow(color: .black, radius:10)
            Text(itemSelected?.artistName ?? "")
                .font(.title)
                .shadow(color: .black, radius:10)
            PlayNextNowRow {
                if let item = itemSelected {
                    MusicCoreFunctions.playStoreItemsNext([item])
                }
                withAnimation {
                    itemSelected = nil
                }
            } playNowAction: {
                if let item = itemSelected {
                    MusicCoreFunctions.playStoreItemsNow([item])
                }
                withAnimation {
                    itemSelected = nil
                }
            }
        }
        .padding()
        .transition(.move(edge: .bottom))
    }
    
}
