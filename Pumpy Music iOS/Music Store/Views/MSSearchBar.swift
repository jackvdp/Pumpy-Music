//
//  MSSearchBar.swift
//  Pumpy Music iOS
//
//  Created by Jack Vanderpump on 25/03/2021.
//  Copyright © 2021 Jack Vanderpump. All rights reserved.
//

import SwiftUI

struct MSSearchBar: View {
    
    @State private var searchText = String()
    @ObservedObject var storeVM: StoreVM
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.pumpyPink)
                TextField("Search Songs", text: $searchText, onCommit: {
                    UIApplication.shared.resignFirstResponder()
                    storeVM.searchStore(searchText: searchText)
                })
            }
            .textFieldStyle(DefaultTextFieldStyle())
            .accentColor(.pumpyPink)
            Divider()
                .background(Color.pumpyPink)
        }
        .padding()
    }
}
