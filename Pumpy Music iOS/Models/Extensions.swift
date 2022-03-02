//
//  Extensions.swift
//  Pumpy Music iOS
//
//  Created by Jack Vanderpump on 21/04/2020.
//  Copyright © 2020 Jack Vanderpump. All rights reserved.
//

import Foundation
import MediaPlayer
import SwiftUI

extension MPVolumeView {
    static func setVolume(_ volume: Float) {
        let volumeView = MPVolumeView()
        let slider = volumeView.subviews.first(where: { $0 is UISlider }) as? UISlider
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.01) {
            slider?.value = volume
        }
    }
    
    static func getVolume() -> Float {
        let volumeView = MPVolumeView()
        let slider = volumeView.subviews.first(where: { $0 is UISlider }) as? UISlider
        print(slider?.value ?? 1)
        
        return slider?.value ?? 1
    }
}

extension View {
    func isHidden(_ bool: Bool) -> some View {
        modifier(HiddenModifier(isHidden: bool))
    }
}

private struct HiddenModifier: ViewModifier {
    
    fileprivate let isHidden: Bool
    
    fileprivate func body(content: Content) -> some View {
        Group {
            if isHidden {
                content.hidden()
            } else {
                content
            }
        }
    }
}

extension Color {
    static let greyBGColour = Color("lightGrey")
    static let pumpyPink = Color(K.pumpyPink)
}

extension UIImageView {
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}

extension MPMediaItem {
    var imageURL: String? {
        if let artworkCatalog = self.value(forKey: "artworkCatalog") as? NSObject,
           let token = artworkCatalog.value(forKey: "token") as? NSObject {
            return token.value(forKey: "fetchableArtworkToken") as? String
        }
        return nil
    }
}


enum StandardError: Error {
    case error
}

enum HTTPError: LocalizedError {
    case statusCode
}

extension StandardError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .error:
            return NSLocalizedString("Error", comment: "Error")
        }
    }
}

protocol PropertyLoopable {
    func allProperties() throws -> [String: Any]
}

extension String {
    var safeCharacters: String {
        let okayChars = Set("abcdefghijklmnopqrstuvwxyz ABCDEFGHIJKLKMNOPQRSTUVWXYZ1234567890+-=().!_")
        return self.filter {okayChars.contains($0) }
    }
}

extension Date {
    static func getCurrentTime() -> String {
        return Date().description(with: .current)
    }
}

extension DispatchSemaphore {
    
    @discardableResult
    func with<T>(_ block: () throws -> T) rethrows -> T {
        wait()
        defer { signal() }
        return try block()
    }
}


extension Collection {
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

extension Array where Element: Hashable {
    func removingDuplicates() -> [Element] {
        var addedDict = [Element: Bool]()

        return filter {
            addedDict.updateValue(true, forKey: $0) == nil
        }
    }

    mutating func removeDuplicates() {
        self = self.removingDuplicates()
    }
}

extension String {

    func fromBase64() -> String? {
        guard let data = Data(base64Encoded: self) else {
            return nil
        }

        return String(data: data, encoding: .utf8)
    }

    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }

}

extension Notification.Name {
    
    static let SettingsUpdate = Notification.Name("SettingsUpdate")
    static let AlarmTriggered = Notification.Name("AlarmTriggered")
    
}
