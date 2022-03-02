//
//  StoreVM.swift
//  Pumpy Music iOS
//
//  Created by Jack Vanderpump on 24/03/2021.
//  Copyright © 2021 Jack Vanderpump. All rights reserved.
//

import Foundation
import StoreKit
import SwiftUI
import SwiftyJSON

class StoreVM: ObservableObject {
    
    @Published var searchTracks = [MusicStoreItem]()
    @Published var searchPlaylists = [MusicStoreItem]()
    @Published var showActivityIndicator = false
    @Published var recommendedCollections = [MSCollection]()
    @Published var itemTracks = [MusicStoreItem]()
    var appleMusicAPI: AppleMusicAPI
    let musicManager: MusicManager
    
    init(musicManager: MusicManager, token: String, storeFront: String) {
        self.musicManager = musicManager
        appleMusicAPI = AppleMusicAPI(token: token, storeFront: storeFront)
        clearSearch()
    }
    
    func searchStore(searchText: String) {
        if searchText.isEmpty {
            clearSearch()
        } else {
            SKCloudServiceController.requestAuthorization { (status) in
                if status == .authorized {
                    self.showActivityIndicator = true
                    self.appleMusicAPI.searchAppleMusic(searchText.safeCharacters) { (result) in
                        DispatchQueue.main.async {
                            self.showActivityIndicator = false
                            self.searchTracks = result.songs
                            self.searchPlaylists = result.playlists
                        }
                    }
                }
            }
        }
    }
    
    func clearSearch() {
        searchTracks = []
        searchPlaylists = []
        showActivityIndicator = true
        appleMusicAPI.getRecommended { (collection) in
            DispatchQueue.main.async {
                self.showActivityIndicator = false
                self.recommendedCollections = collection
            }
        }
    }
    
    func getTracksForItem(item: MusicStoreItem) {
        self.showActivityIndicator = true
        appleMusicAPI.getTracksFromPlaylist(item: item) { (items) in
            DispatchQueue.main.async {
                self.showActivityIndicator = false
                self.itemTracks = items
            }
        }
    }
    
    func playItems(_ object: MusicStoreItem, _ play: PlayType) {
        if !itemTracks.isEmpty {
            if object.type == .playlist {
                musicManager.playlistManager.playlistLabel = "Playlist: \(object.name)"
            }
            play == .next ? MusicCoreFunctions.playStoreItemsNext(itemTracks) : MusicCoreFunctions.playStoreItemsNow(itemTracks)
        }
    }
    
}
