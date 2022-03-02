//
//  File.swift
//  Pumpy Music iOS
//
//  Created by Jack Vanderpump on 07/03/2021.
//  Copyright © 2021 Jack Vanderpump. All rights reserved.
//

import Foundation
import SwiftUI

struct SettingsModel: Codable {
    var showMusicLibrary: Bool = true
    var showMusicStore: Bool = true
    var showScheduler: Bool = true
    var showDownloader: Bool = true
    var showRepeater: Bool = true
    var showBlocked: Bool = true
    var crossfadeOn: Bool = true
    var showExternalDisplay: Bool = true
    var banExplicit: Bool = false
}
