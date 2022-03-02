//
//  Remote Models.swift
//  Pumpy Music iOS
//
//  Created by Jack Vanderpump on 24/04/2020.
//  Copyright © 2020 Jack Vanderpump. All rights reserved.
//

import Foundation

struct RemoteInfo: Codable {
    var remoteCommand: RemoteEnum?
    var updateTime = Date.getCurrentTime()
}

enum RemoteEnum {
    
    case playPause
    case skipTrack
    case previousTrack
    case playPlaylistNow(playlist: String)
    case playPlaylistNext(playlist: String)
    case scheduledPlaylistFromServer(playlist: String)
    case getLibraryPlaylists
    case getTracksFromPlaylist(playlist: String)
    case removeTrackFromQueue(id: String)
    case addToQueue(queueIDs: [String])
    case activeInfo
    
}

extension RemoteEnum: Codable {
    
    enum Key: CodingKey {
        case rawValue
        case associatedValue
    }
    
    enum CodingError: Error {
        case unknownValue
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Key.self)
        
        switch self {
        case .playPause:
            try container.encode("playPause", forKey: .rawValue)
            
        case .skipTrack:
            try container.encode("skipTrack", forKey: .rawValue)
            
        case .previousTrack:
            try container.encode("previousTrack", forKey: .rawValue)
            
        case .playPlaylistNow(let playlist):
            try container.encode("playPlaylistNow", forKey: .rawValue)
            try container.encode(playlist, forKey: .associatedValue)
            
        case .playPlaylistNext(let playlist):
            try container.encode("playPlaylistNext", forKey: .rawValue)
            try container.encode(playlist, forKey: .associatedValue)
            
        case .scheduledPlaylistFromServer(let playlist):
            try container.encode("scheduledPlaylistFromServer", forKey: .rawValue)
            try container.encode(playlist, forKey: .associatedValue)
            
        case .getLibraryPlaylists:
            try container.encode("getLibraryPlaylists", forKey: .rawValue)
            
        case .getTracksFromPlaylist(let playlist):
            try container.encode("getTracksFromPlaylist", forKey: .rawValue)
            try container.encode(playlist, forKey: .associatedValue)
            
        case .removeTrackFromQueue(let id):
            try container.encode("removeTrackFromQueue", forKey: .rawValue)
            try container.encode(id, forKey: .associatedValue)
            
        case .addToQueue(let queue):
            try container.encode("addToQueue", forKey: .rawValue)
            try container.encode(queue, forKey: .associatedValue)
        case .activeInfo:
            try container.encode("activeInfo", forKey: .rawValue)
        }
        
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Key.self)
        let rawValue = try container.decode(String.self, forKey: .rawValue)
        
        switch rawValue {
        case "playPause":
            self = .playPause
        case "skipTrack":
            self = .skipTrack
        case "previousTrack":
            self = .previousTrack
        case "playPlaylistNow":
            let playlist = try container.decode(String.self, forKey: .associatedValue)
            self = .playPlaylistNow(playlist: playlist)
        case "playPlaylistNext":
            let playlist = try container.decode(String.self, forKey: .associatedValue)
            self = .playPlaylistNext(playlist: playlist)
        case "scheduledPlaylistFromServer":
            let playlist = try container.decode(String.self, forKey: .associatedValue)
            self = .scheduledPlaylistFromServer(playlist: playlist)
        case "getLibraryPlaylists":
            self = .getLibraryPlaylists
        case "getTracksFromPlaylist":
            let playlist = try container.decode(String.self, forKey: .associatedValue)
            self = .getTracksFromPlaylist(playlist: playlist)
        case "removeTrackFromQueue":
            let id = try container.decode(String.self, forKey: .associatedValue)
            self = .removeTrackFromQueue(id: id)
        case "addToQueue":
            let tracks = try container.decode([String].self, forKey: .associatedValue)
            self = .addToQueue(queueIDs: tracks)
        case "activeInfo":
            self = .activeInfo
        default:
            throw CodingError.unknownValue
        }
    }
    
}
