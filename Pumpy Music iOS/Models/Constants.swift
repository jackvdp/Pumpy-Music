//
//  Constants.swift
//  Pumpy Music iOS
//
//  Created by Jack Vanderpump on 03/01/2020.
//  Copyright © 2020 Jack Vanderpump. All rights reserved.
//

import Foundation
import MediaPlayer

struct K {
    
    static let versionNumber = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
    
    static let pumpyPink = "pumpyPink"
    static let username = "Username"
    static let password = "Password"
    static let alarmsKey = "alarmsKey"
    static let repeatKey = "repeatItem"
    static let didUpdateStateNotification = NSNotification.Name("didUpdateState")
    static let pumpyImage = "Pumpy Logo Transparent"
    static let stopMusic = "Stop Music"
    static let defaultArtwork = "Pumpy Artwork"
    
    struct Alarm {
        static let playlistLabel = "playlistLabel"
        static let secondaryAlarm = "secondaryAlarm"
        static let externalSettingsOverride = "externalSettingsOverride"
        static let showQRCode = "showQRCode"
        static let qrLink = "QRLink"
        static let qrMessage = "QRMessage"
        static let contentType = "contentType"
        static let messageSpeed = "messageSpeed"
        static let qrType = "qrType"
    }
    
    struct FStore {
        static let FCMKey = "AIzaSyB388XOkRSDcSZzXQ54ql3EsdRtjF0lAuE"
        static let alarmCollection = "Alarm Collection"
        static let currentPlayback = "Latest Playback Info"
        static let remoteData = "Remote Data"
        static let playlistCollection = "Playlist Collection"
        static let trackCollection = "Track Collection"
        static let upNext = "Up Next"
        static let playlistName = "Playlist Name"
        static let activeStatus = "Active Status"
        static let settings = "Settings"
        static let extDisSettings = "External Display Settings"
        static let repeatShowing = "Repeat Showing"
        static let repeatTrack = "Repeat Track"
        static let downloadedTracks = "Downloaded Tracks"
        static let blockedTracks = "Blocked Tracks"
        static let time = "Time"
        static let deviceName = "Device Name"
    }
    
    struct MusicStore {
        static let url = "https://api.music.apple.com/v1/"
        static let musicUserToken = "Music-User-Token"
        static let authorisation = "Authorization"
        static let bearerToken = "Bearer \(K.MusicStore.developerToken)"
    }

    struct Font {
        static let helvetica = "HelveticaNeue"
        static let helveticaLight = "HelveticaNeue-Light"
    }
}
