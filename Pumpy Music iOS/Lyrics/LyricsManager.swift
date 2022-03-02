//
//  LyricsManager.swift
//  Pumpy Music iOS
//
//  Created by Jack Vanderpump on 08/05/2021.
//  Copyright © 2021 Jack Vanderpump. All rights reserved.
//

//import Foundation
//import LyricsService
//import LyricsCore
//import MediaPlayer
//
//class LyricsManager {
//
//    let provider = LyricsProviders.Group()
//
//    func getLyricsFromCurrentSong(_ item: MPMediaItem) {
//        if let title = item.title, let artist = item.artist {
//            let searchRequest = LyricsSearchRequest(searchTerm: .info(title: title, artist: artist),
//                                                    title: title,
//                                                    artist: artist,
//                                                    duration: item.playbackDuration)
//
//            let _ = provider.lyricsPublisher(request: searchRequest)
//                .sink(receiveCompletion: { _ in
//                    print(1)
//                }, receiveValue: { lyrics in
//                    print("Lyrics \(lyrics)")
//                })
//        }
//
//    }
//
//}

