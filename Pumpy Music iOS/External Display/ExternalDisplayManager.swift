//
//  ExternalDisplayVM.swift
//  Pumpy Music iOS
//
//  Created by Jack Vanderpump on 16/04/2021.
//  Copyright © 2021 Jack Vanderpump. All rights reserved.
//

import Foundation
import CoreImage.CIFilterBuiltins
import SwiftUI
import Firebase
import CodableFirebase
import PumpyLibrary

class ExternalDisplayManager: ObservableObject {
    
    let username: String
    let musicManager: MusicManager
    
    init(username: String, musicManager: MusicManager) {
        self.username = username
        self.musicManager = musicManager
        downloadSettings()
    }
    
    deinit {
        print("deiniting")
    }
    
    @Published var extDisType: ExtDisType = .defualts
    
    var settingsListener: ListenerRegistration?
    
    // Live Settings (only used when alarm sets extDisType to override)
    @Published var liveSettings = ExtDisSettings()
    
    // Default Settings (gets saved to firebase and shows in settings)
    @Published var defaultSettings = ExtDisSettings() {
        didSet {
            updateLiveSettings()
        }
    }
    
    // Playlist QR Code
    let playlistMarqueeLabel = "To get the current playlist please scan the QR code"
    let playlistMarqueeSpeed = 5.0
    
    func updateLiveSettings() {
        print("updating settings")
        switch extDisType {
        case .defualts:
            liveSettings = defaultSettings
        case .override:
            break
        }
    }
    
    func generateQRCode() -> UIImage? {
        let data = Data(getCorrectURL().utf8)
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        filter.setValue(data, forKey: "inputMessage")
        if let outputImage = filter.outputImage {
            if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
                return UIImage(cgImage: cgimg)
            }
        }
        return nil
    }
    
    func getCorrectURL() -> String {
        switch liveSettings.qrType  {
        case .playlist:
            return musicManager.playlistManager.playlistURL
        case .custom:
            return liveSettings.qrURL
        }
    }
    
    func getCorrectLabel() -> String {
        switch liveSettings.qrType  {
        case .playlist:
            return playlistMarqueeLabel
        case .custom:
            return liveSettings.marqueeTextLabel
        }
    }
    
    func qrSpeed() -> Double {
        switch liveSettings.qrType  {
        case .playlist:
            return playlistMarqueeSpeed
        case .custom:
            return liveSettings.marqueeLabelSpeed
        }
    }
    
    func qrLength() -> Int {
        switch liveSettings.qrType  {
        case .playlist:
            return playlistMarqueeLabel.count
        case .custom:
            return liveSettings.marqueeTextLabel.count
        }
    }
    
    func qrTime() -> Double {
        return Double(qrLength()) / qrSpeed()
    }
    
    func frameHeight(_ height: CGFloat) -> CGFloat {
        if liveSettings.showQRCode {
            return height * 0.8
        }
        return height
    }
    
    
    func saveSettingsOnline() {
        saveSettings(settings: defaultSettings)
    }
    
    func downloadSettings() {
        let db = Firestore.firestore()
        settingsListener = FireMethods.listen(db: db, name: username, documentName: K.FStore.extDisSettings, dataFieldName: K.FStore.extDisSettings, decodeObject: ExtDisSettings.self) { settings in
            self.defaultSettings = settings
        }
    }
    
    func removeSettingsListener() {
        settingsListener?.remove()
    }
    
    func saveSettings(settings: ExtDisSettings) {
        FireMethods.save(object: settings, name: username, documentName: K.FStore.extDisSettings, dataFieldName: K.FStore.extDisSettings)
    }
}
