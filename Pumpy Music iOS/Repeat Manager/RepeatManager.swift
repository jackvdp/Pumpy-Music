//
//  AudioDownloaderViewModel.swift
//  Pumpy Music iOS
//
//  Created by Jack Vanderpump on 27/03/2021.
//  Copyright © 2021 Jack Vanderpump. All rights reserved.
//

import Foundation
import SwiftUI
import AVFoundation
import Combine
import Firebase
import CodableFirebase

class RepeatManager: ObservableObject {
    
    let username: String
    var repeatTrack: RepeatTrack?
    let musicManager: MusicManager
    var timer: Timer?
    var downloadListener: ListenerRegistration?
    var repeatListener: ListenerRegistration?
    @Published var files = [AudioFilesURLS]()
    
    @Published var repeatItem: RepeatStruct? {
        didSet {
            setTimer()
        }
    }
    
    init(username: String, musicManager: MusicManager) {
        self.username = username
        self.musicManager = musicManager
        setUpRepeat()
    }
    
    deinit {
        print("deiniting")
    }
    
    func setTimer() {
        if let item = repeatItem {
            if item.enabled {
                timer =  Timer.scheduledTimer(
                    timeInterval: TimeInterval(60*item.repeatMins),
                    target      : self,
                    selector    : #selector(startRepeat),
                    userInfo    : nil,
                    repeats     : true)
                return
            }
        }
        timer = nil
    }
    
    @objc func startRepeat() {
        repeatTrack = RepeatTrack(musicManager: musicManager)
    }
    
    func setUpRepeat(){
        loadOnlineRepeat()
        downloadURL()
    }
    
    
    // MARK: - Repeats
    
    func saveRepeat(_ item: RepeatStruct) {
        FireMethods.save(object: item, name: username, documentName: K.FStore.repeatTrack, dataFieldName: K.FStore.repeatTrack)
    }
    
    func loadOnlineRepeat() {
        let db = Firestore.firestore()
        repeatListener = FireMethods.listen(db: db, name: username, documentName: K.FStore.repeatTrack, dataFieldName: K.FStore.repeatTrack, decodeObject: RepeatStruct.self) { repeatItem in
            self.repeatItem = repeatItem
        }
    }
    
    // MARK: - Audio File URLs
    
    func downloadURL() {
        let db = Firestore.firestore()
        downloadListener = FireMethods.listen(db: db, name: username, documentName: K.FStore.downloadedTracks, dataFieldName: K.FStore.downloadedTracks, decodeObject: [URL].self) { urls in
            for track in urls {
                FileDownloader.loadFileAsync(url: track) { (url, error) in
                    if let error = error {
                        print(error)
                    }
                    if let u = url {
                        DispatchQueue.main.async {
                            self.files.append(AudioFilesURLS(localURL: u, downloadURL: track))
                        }
                        if track == urls.last {
                            self.deleteOldFiles()
                        }
                    }
                }
            }
        }
    }
    
    static func getAudioFiles() -> [URL] {
        var fileArray = FileManager.default.urls(for: .documentDirectory) ?? []
        fileArray.removeAll(where: { $0.lastPathComponent == "firestore" })
        return fileArray
    }
    
    func deleteOldFiles() {
        let oldLocalURLS = RepeatManager.getAudioFiles()
        let newLocalURLS = files.map { $0.localURL }
        for oldLocalURL in oldLocalURLS {
            let newLocalNames = newLocalURLS.map { $0.lastPathComponent }
            if !newLocalNames.contains(oldLocalURL.lastPathComponent) {
                do {
                    try FileManager.default.removeItem(at: oldLocalURL)
                } catch {
                    print("Error deleting old files")
                }
            }
        }
    }
    
    func removeListeners() {
        downloadListener?.remove()
        repeatListener?.remove()
    }
}


