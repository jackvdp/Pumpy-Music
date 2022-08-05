//
//  Artwork.swift
//  Pumpy Music iOS
//
//  Created by Jack Vanderpump on 20/04/2021.
//  Copyright © 2021 Jack Vanderpump. All rights reserved.
//

import Foundation
import MediaPlayer

class Artwork {
    
    let appleMusicToken: String?
    let appleMusicStoreFront: String?
    
    init(token: String? = nil, store: String? = nil) {
        appleMusicToken = token
        appleMusicStoreFront = store
    }
    
    func getArtwork(from track: Track, size: Int, completion: @escaping (UIImage?) -> Void) {
        if let artwork = track.artwork?.image(at: CGSize(width: size, height: size)) {
            completion(artwork)
        } else {
            completion(nil)
            getArtworkFromStore(from: track, size: size) { image in
                completion(image)
            }
        }
    }
    
    func getArtworkFromStore(from track: Track, size: Int, completion: @escaping (UIImage) -> Void) {
        if let token = appleMusicToken, let storefront = appleMusicStoreFront {
            let amAPI = AppleMusicAPI(token: token, storeFront: storefront)
            let id = track.playbackStoreID
            amAPI.getArtworkURL(id: id) { (artworkString) in
                if let artworkURL = Artwork.makeMusicStoreURL(artworkString, size: size) {
                    Artwork.fetchImage(from: artworkURL) { (image) in
                        if let i = image {
                            completion(i)
                        }
                    }
                }
            }
        }
    }
    
    static func fetchImage(from url: URL, completionHandler: @escaping (_ image: UIImage?) -> ()) {
        let session = URLSession.shared
        let dataTask = session.dataTask(with: url) { (data, response, error) in
            if let e = error {
                print(e)
                print("Error fetching the image data! 😢")
                completionHandler(nil)
            } else {
                if let d = data {
                    if let image = UIImage(data: d) {
                        completionHandler(image)
                    }
                }
            }
        }
        dataTask.resume()
    }
    
    static func makeMusicStoreURL(_ urlString: String, size: Int) -> URL? {
        return URL(string: urlString.replacingOccurrences(of: "{w}", with: String(size)).replacingOccurrences(of: "{h}", with: String(size)))
    }
}
