//
//  TokenManager.swift
//  Pumpy Music iOS
//
//  Created by Jack Vanderpump on 13/08/2021.
//  Copyright © 2021 Jack Vanderpump. All rights reserved.
//

import Foundation
import StoreKit
import SwiftyJSON

class TokenManager: ObservableObject {
    
    @Published var appleMusicToken: String?
    @Published var appleMusicStoreFront: String?
    let storeController = SKCloudServiceController()
    
    init() {
        getUserToken()
        getStoreFrontID()
    }
    
    deinit {
        print("deiniting")
    }
    
    func getUserToken() {
        storeController.requestUserToken(forDeveloperToken: K.MusicStore.developerToken) { (receivedToken, error) in
            guard error == nil else {
                print(error.debugDescription)
                return
            }
            if let token = receivedToken {
                self.appleMusicToken = token
            }
        }
    }
    
    func getStoreFrontID() {
        storeController.requestStorefrontCountryCode { store, error in
            if let e = error {
                print(e)
            } else {
                if let store = store {
                    self.appleMusicStoreFront = store
                }
            }
            
        }
        
    }
    
}
