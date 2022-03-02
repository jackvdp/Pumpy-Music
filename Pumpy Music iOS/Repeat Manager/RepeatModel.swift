//
//  RepeatModel.swift
//  Pumpy Music iOS
//
//  Created by Jack Vanderpump on 01/04/2021.
//  Copyright © 2021 Jack Vanderpump. All rights reserved.
//

import Foundation

struct RepeatStruct: Codable {
    var enabled: Bool
    var repeatMins: Int
    var audio: String?
}

struct AudioFilesURLS: Hashable {
    var localURL: URL
    var downloadURL: URL
    var id = UUID()
}
