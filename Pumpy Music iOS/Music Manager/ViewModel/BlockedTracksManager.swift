//
//  BlockedTracks.swift
//  Pumpy Music iOS
//
//  Created by Jack Vanderpump on 28/06/2021.
//  Copyright © 2021 Jack Vanderpump. All rights reserved.
//

import Foundation
import Firebase
import CodableFirebase
import MediaPlayer
import SwiftUI

class BlockedTracksManager: ObservableObject {
    
    @Published var blockedTracks = [String]() {
        didSet {
            saveBlockedTracks(blockedTracks: blockedTracks)
        }
    }
    let queueManager: QueueManager
    var remoteListener: ListenerRegistration?
    var db = Firestore.firestore()
    let username: String
    
    init(username: String, queueManager: QueueManager) {
        self.username = username
        self.queueManager = queueManager
        listenForBlockedTracks()
    }
    
    deinit {
        print("deiniting")
    }
    
    func listenForBlockedTracks() {
        remoteListener = FireMethods.listen(db: db, name: username, documentName: K.FStore.blockedTracks, dataFieldName: K.FStore.blockedTracks, decodeObject: [String].self) { blocked in
            self.blockedTracks = blocked
        }
    }
    
    func saveBlockedTracks(blockedTracks: [String]) {
        FireMethods.save(object: blockedTracks,
                         name: username,
                         documentName: K.FStore.blockedTracks,
                         dataFieldName: K.FStore.blockedTracks)
    }
    
    func unblockTrackOrAskToBlock(id: String) -> Bool {
        if blockedTracks.contains(id) {
            removeTrack(id: id)
        } else {
            return true
        }
        return false
    }
    
    func addTrackToBlockedList(id: String) {
        blockedTracks.append(id)
        queueManager.removeFromQueue(id: id)
    }
    
    func removeTrack(id: String) {
        blockedTracks.removeAll(where: { $0 == id })
    }
    
    func removeListener() {
        remoteListener?.remove()
    }
    
}
