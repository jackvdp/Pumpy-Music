//
//  Alarm.swift
//  AlarmClone
//
//  Created by Jes Yang on 2019/10/23.
//  Copyright © 2019 Jes Yang. All rights reserved.
//

import Foundation

struct Alarm: Codable, Equatable {
    var uuid: String
    var time: Time
    var playlistLabel: String
    var repeatStatus: [DetailInfo.DaysOfWeek]
    var secondaryPlaylists: [SecondaryPlaylist]?
    
    var externalSettingsOverride: Bool?
    var showQRCode: Bool?
    var QRLink: String?
    var QRMessage: String?
    var contentType: ExtDisContentType?
    var messageSpeed: Double?
    var qrType: QRType?
}

struct SecondaryPlaylist: Codable, Equatable, Hashable, Identifiable {
    var name: String
    var ratio: Int
    var id = UUID()
}

struct Time: Codable, Equatable {
    var hour: Int
    var min: Int
    
    var timeString: String {
        let formatter = DateFormatter.dateFormat(fromTemplate: "HH:mm", options: 0, locale: .current)
        let dateFormatter = DateFormatter()
        
        if let formatter = formatter, formatter.contains("a") {
            dateFormatter.dateFormat  = "h:mma"
        } else {
            dateFormatter.dateFormat  = formatter
        }
        
        return dateFormatter.string(from: date)
    }
    
    var date: Date {
        dateComponents.date!
    }

    var dateComponents: DateComponents {
        DateComponents(calendar: Calendar.current, hour: hour, minute: min, second: 0)
    }
    
}

extension DetailInfo.DaysOfWeek: Codable {
    
}

extension Date {
    var hour: Int { Calendar.current.component(.hour, from: self) }
    var minute: Int { Calendar.current.component(.minute, from: self) }
}
