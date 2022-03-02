//
//  AppleMusicAPI.swift
//  Pumpy Music iOS
//
//  Created by Jack Vanderpump on 24/03/2021.
//  Copyright © 2021 Jack Vanderpump. All rights reserved.
//

import Foundation
import StoreKit
import SwiftyJSON
import HummingKit
import MediaPlayer

class AppleMusicAPI {
    
    var userToken: String
    var storefrontID: String
    
    init(token: String, storeFront: String) {
        userToken = token
        storefrontID = storeFront
    }
    
    func makeMSItem(object: JSON) -> MusicStoreItem? {
        if let kind = object["attributes"]["playParams"]["kind"].string,
           let name = object["attributes"]["name"].string,
           let id = object["attributes"]["playParams"]["id"].string,
           let artwork = object["attributes"]["artwork"]["url"].string {
            if let msKind = MusicStoreType(rawValue: kind) {
                var item = MusicStoreItem(
                    id: id,
                    name: name,
                    artistName: String(),
                    artworkURL: artwork,
                    type: msKind)
                
                switch msKind {
                case .playlist:
                    if let curatorName = object["attributes"]["curatorName"].string {
                        item.artistName = curatorName
                        return item
                    }
                case .track, .album:
                    if let artistName = object["attributes"]["artistName"].string {
                        item.artistName = artistName
                        return item
                    }
                case .station:
                    return item
                }
            }
        }
        return nil
    }
    
    // MARK: - Search
    
    func searchAppleMusic(_ searchTerm: String!, completionHandler: @escaping (MusicStoreResult) -> Void) {
        let term = searchTerm.replacingOccurrences(of: " ", with: "+")
        if let musicURL = URL(string: "\(K.MusicStore.url)catalog/\(storefrontID)/search?term=\(term)&types=songs,playlists&limit=25") {
            var musicRequest = URLRequest(url: musicURL)
            musicRequest.httpMethod = "GET"
            musicRequest.addValue(K.MusicStore.bearerToken, forHTTPHeaderField: K.MusicStore.authorisation)
            
            URLSession.shared.dataTask(with: musicRequest) { (data, response, error) in
                guard error == nil else { return }
                if let d = data {
                    let result = MusicStoreResult(songs: self.decodeSearch(d, type: .track), playlists: self.decodeSearch(d, type: .playlist))
                    completionHandler(result)
                }
            }.resume()
        }
    }
    
    func decodeSearch(_ data: Data, type: MusicStoreType) -> [MusicStoreItem] {
        var items = [MusicStoreItem]()
        if let json = try? JSON(data: data) {
            let itemsString = type == .playlist ? "playlists" : "songs"
            if let result = (json["results"][itemsString]["data"]).array {
                for item in result {
                    if let obj = makeMSItem(object: item){
                        items.append(obj)
                    }
                }
                return items
            }
        }
        return items
    }
    
    // MARK: - Recommended
    
    func getRecommended(completionHandler: @escaping ([MSCollection]) -> Void) {
        if let musicURL = URL(string: "\(K.MusicStore.url)me/recommendations/") {
            var musicRequest = URLRequest(url: musicURL)
            musicRequest.httpMethod = "GET"
            musicRequest.addValue(K.MusicStore.bearerToken, forHTTPHeaderField: K.MusicStore.authorisation)
            musicRequest.addValue(userToken, forHTTPHeaderField: K.MusicStore.musicUserToken)
            
            URLSession.shared.dataTask(with: musicRequest) { (data, response, error) in
                guard error == nil else { return }
                if let d = data {
                    let collections = self.parseRecommendedCollections(data: d)
                    completionHandler(collections)
                }
            }.resume()
        }
    }
    
    func parseRecommendedCollections(data: Data) -> [MSCollection] {
        var msCollections = [MSCollection]()
        if let jsonData = try? JSON(data: data) {
            if let collections = jsonData["data"].array {
                for collection in collections {
                    if let title = collection["attributes"]["title"]["stringForDisplay"].string {
                        if let objects = collection["relationships"]["contents"]["data"].array {
                            var msObjects = [MusicStoreItem]()
                            for object in objects {
                                if let obj = makeMSItem(object: object) {
                                    msObjects.append(obj)
                                }
                            }
                            msCollections.append(MSCollection(title: title, objects: msObjects))
                        }
                    }
                }
            }
        }
        return msCollections
    }
    
    // MARK: - Item Details

    func getTracksFromPlaylist(item: MusicStoreItem, completionHandler: @escaping ([MusicStoreItem]) -> Void) {
        if let musicURL = URL(string: "\(K.MusicStore.url)catalog/\(storefrontID)/\(item.collectiveString)/\(item.id)?include=songs") {
            var musicRequest = URLRequest(url: musicURL)
            musicRequest.httpMethod = "GET"
            musicRequest.addValue(K.MusicStore.bearerToken, forHTTPHeaderField: K.MusicStore.authorisation)
            
            URLSession.shared.dataTask(with: musicRequest) { (data, response, error) in
                guard error == nil else { return }
                if let d = data {
                    completionHandler(self.parseTracks(data: d))
                }
            }.resume()
        }
    }
    
    func parseTracks(data: Data) -> [MusicStoreItem] {
        var items = [MusicStoreItem]()
        if let jsonData = try? JSON(data: data) {
            if let playlists = jsonData["data"].array {
                for playlist in playlists {
                    if let songs = playlist["relationships"]["tracks"]["data"].array {
                        for song in songs {
                            if let msSong = makeMSItem(object: song) {
                                items.append(msSong)
                            }
                        }
                    }
                }
            }
        }
        return items
    }
    
     // MARK: - Get Item from ID
    
    func getTrackFromID(item: String, completionHandler: @escaping (MusicStoreItem?) -> Void) {
        if let musicURL = URL(string: "\(K.MusicStore.url)catalog/\(storefrontID)/songs/\(item)") {
            var musicRequest = URLRequest(url: musicURL)
            musicRequest.httpMethod = "GET"
            musicRequest.addValue(K.MusicStore.bearerToken, forHTTPHeaderField: K.MusicStore.authorisation)
            
            URLSession.shared.dataTask(with: musicRequest) { (data, response, error) in
                guard error == nil else { return }
                if let d = data {
                    completionHandler(self.parseTracks(data: d))
                }
            }.resume()
        }
    }
    
    func parseTracks(data: Data) -> MusicStoreItem? {
        if let jsonData = try? JSON(data: data) {
            if let tracks = jsonData["data"].array {
                for track in tracks {
                    return makeMSItem(object: track)
                }
            }
        }
        return nil
    }
    
    
    // MARK: - Artwork
    
    func getArtworkURL(id: String, completionHandler: @escaping (String) -> Void) {
        if let musicURL = URL(string: "\(K.MusicStore.url)catalog/\(storefrontID)/songs/\(id)") {
            var musicRequest = URLRequest(url: musicURL)
            musicRequest.httpMethod = "GET"
            musicRequest.addValue(K.MusicStore.bearerToken, forHTTPHeaderField: K.MusicStore.authorisation)

            URLSession.shared.dataTask(with: musicRequest) { (data, response, error) in
                guard error == nil else { return }
                if let d = data {
                    if let artworkString = self.parseTrackForArtwork(data: d) {
                        completionHandler(artworkString)
                    }
                }
            }.resume()
        }
    }
    
    func parseTrackForArtwork(data: Data) -> String? {
        if let jsonData = try? JSON(data: data) {
            print(jsonData)
            if let tracks = jsonData["data"].array {
                for track in tracks {
                    if let artworkURL = track["attributes"]["artwork"]["url"].string {
                        return artworkURL
                    }
                }
            }
        }
        return nil
    }
    
    // MARK: - Playlist
    
    func getPlaylistURL(playlist: String, completionHandler: @escaping (String) -> Void) {
        let query = MPMediaQuery.playlists()
        let predicate = MPMediaPropertyPredicate(value: playlist,
                                                 forProperty: MPMediaPlaylistPropertyName,
                                                 comparisonType: .equalTo)
        query.addFilterPredicate(predicate)
        if let plist = query.collections?.first as? MPMediaPlaylist {
            if let id = plist.cloudGlobalID {
                if let musicURL = URL(string: "\(K.MusicStore.url)catalog/\(storefrontID)/playlists/\(id)") {
                    var musicRequest = URLRequest(url: musicURL)
                    musicRequest.httpMethod = "GET"
                    musicRequest.addValue(K.MusicStore.bearerToken, forHTTPHeaderField: K.MusicStore.authorisation)
                    
                    URLSession.shared.dataTask(with: musicRequest) { (data, response, error) in
                        guard error == nil else { return }
                        if let d = data {
                            if let urlString = self.parsePlaylisrForURL(data: d) {
                                completionHandler(urlString)
                            }
                        }
                    }.resume()
                }
            }
            
            
        }
    }
    
    func parsePlaylisrForURL(data: Data) -> String? {
        if let jsonData = try? JSON(data: data) {
            if let playlist = jsonData["data"].array {
                if let plist = playlist.first {
                    if let url = plist["attributes"]["url"].string {
                        return url
                    }
                }
            }
        }
        return nil
    }
    
}
