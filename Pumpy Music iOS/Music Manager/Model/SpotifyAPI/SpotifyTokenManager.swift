//
//  SpotifyTokenManager.swift
//  Pumpy Music iOS
//
//  Created by Jack Vanderpump on 04/09/2021.
//  Copyright © 2021 Jack Vanderpump. All rights reserved.
//

import Foundation
import SwiftyJSON

class SpotifyTokenManager {
    private let clientID = "993a6ee42c244f59be85a00a70f5190e"
    private let clientSecret = "735a18b1e6f049fca74c8ccab21f98c9"
    private var renewTokenTimer: Timer?
    var spotifyToken: String?
    
    init() {
        getSpotifyToken()
    }
    
    func getSpotifyToken() {
        if let musicURL = URL(string: "https://accounts.spotify.com/api/token") {
            let body = String("grant_type=client_credentials").data(using: .utf8)
            var musicRequest = URLRequest(url: musicURL)
            musicRequest.httpMethod = "POST"
            
            let headerValue = String("\(clientID):\(clientSecret)").toBase64()
            
            musicRequest.addValue("Basic \(headerValue)", forHTTPHeaderField: K.MusicStore.authorisation)
            musicRequest.httpBody = body
            
            URLSession.shared.dataTask(with: musicRequest) { (data, response, error) in
                guard error == nil else { return }
                if let d = data {
                    self.parseToken(data: d)
                }
            }.resume()
        }
    }
    
    private func parseToken(data: Data) {
        if let jsonData = try? JSON(data: data) {
            print(jsonData)
            if let token = jsonData["access_token"].string {
                spotifyToken = token
                renewToken(time: jsonData["expires_in"].int ?? 120)
            }
        }
    }
    
    private func renewToken(time: Int) {
        renewTokenTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(time-60), repeats: true) { timer in
            self.getSpotifyToken()
        }
    }
}
