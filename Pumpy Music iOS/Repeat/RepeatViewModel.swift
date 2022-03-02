//
//  RepeatViewModel.swift
//  Pumpy Music iOS
//
//  Created by Jack Vanderpump on 02/04/2021.
//  Copyright © 2021 Jack Vanderpump. All rights reserved.
//

import Foundation
import SwiftUI

class RepeatViewModel: ObservableObject {
    
    let repeatManager: RepeatManager
    
    @Published var files = [String]()
    @Published var repeatItem: RepeatStruct = RepeatStruct(enabled: false, repeatMins: 15, audio: nil)
    
    init(repeatManager: RepeatManager) {
        self.repeatManager = repeatManager
        files = repeatManager.files.map { $0.localURL.lastPathComponent }
        if let item = repeatManager.repeatItem {
            repeatItem = item
        }
    }
    
}
