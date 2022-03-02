//
//  ActiveModel.swift
//  Pumpy Music iOS
//
//  Created by Jack Vanderpump on 20/08/2021.
//  Copyright © 2021 Jack Vanderpump. All rights reserved.
//

import Foundation
import UIKit

struct ActiveModel: Codable {
    var deviceName = UIDevice.current.name
    var date = Date.getCurrentTime()
    let activeStatus: ActiveStatus
}

enum ActiveStatus: String, Codable {
    case loggedIn = "loggedIn"
    case loggedOut = "loggedOut"
    case background = "background"
    case terminated = "terminated"
}
