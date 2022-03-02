//
//  downloadViewModel.swift
//  Pumpy Music iOS
//
//  Created by Jack Vanderpump on 02/04/2021.
//  Copyright © 2021 Jack Vanderpump. All rights reserved.
//

import Foundation
import SwiftUI
import AVFoundation
import Firebase
import CodableFirebase

class DownloadViewModel: ObservableObject {
    
    let repeatManager: RepeatManager
    let username: String
    @Published var showSpinner = false
    
    init(username: String, repeatManager: RepeatManager) {
        self.username = username
        self.repeatManager = repeatManager
    }
    
    func deleteFile(at index: Int) {
        if let file = repeatManager.files[safe: index] {
            do {
                try FileManager.default.removeItem(at: file.localURL)
                repeatManager.files.remove(at: index)
                saveURLSOnline()
            } catch {
                print(error)
            }
        }
    }
    
    func addAudio(_ urlString: String, completionHandler: @escaping (UIAlertController) -> Void) {
        if let urlDownload = URL(string: urlString) {
            showSpinner = true
            let audioAsset = AVAsset(url: urlDownload)
            if audioAsset.isPlayable {
                loadFileAsync(url: urlDownload) { (url, error) in
                    DispatchQueue.main.async {
                        self.showSpinner = false
                    }
                    self.saveURLSOnline()
                    if let error = error {
                        let errorAlert = self.makeAlert(title: "Error", message: error.localizedDescription)
                        completionHandler(errorAlert)
                    } else {
                        if let url = url {
                            self.repeatManager.files.append(AudioFilesURLS(localURL: url, downloadURL: urlDownload))
                            self.saveURLSOnline()
                        }
                    }
                }
            } else {
                let errorAlert = makeAlert(title: "Error", message: "URL does not contain a playable file.")
                completionHandler(errorAlert)
            }
        }
    }
    
    func saveURLSOnline() {
        let urls = repeatManager.files.map { $0.downloadURL }
        FireMethods.save(object: urls,
                         name: username,
                         documentName: K.FStore.downloadedTracks,
                         dataFieldName: K.FStore.downloadedTracks)
    }
    
    func loadFileAsync(url: URL, completion: @escaping (URL?, Error?) -> Void) {
        guard let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let destinationUrl = documentsUrl.appendingPathComponent(url.lastPathComponent)
        
        if FileManager().fileExists(atPath: destinationUrl.path) {
            print("File already exists [\(destinationUrl.path)]")
            completion(destinationUrl, nil)
        } else {
            let configuration = URLSessionConfiguration.default
            let operationQueue = OperationQueue()
            let session = URLSession(configuration: configuration, delegate: nil, delegateQueue: operationQueue)
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            let task = session.dataTask(with: request, completionHandler: { data, response, error in
                if error == nil {
                    if let response = response as? HTTPURLResponse {
                        if response.statusCode == 200 {
                            if let data = data {
                                if let _ = try? data.write(to: destinationUrl, options: Data.WritingOptions.atomic) {
                                    completion(destinationUrl, error)
                                } else {
                                    completion(destinationUrl, error)
                                }
                            } else {
                                completion(destinationUrl, error)
                            }
                        }
                    }
                } else {
                    completion(destinationUrl, error)
                }
            })
            task.resume()
        }
    }
    
    func makeAlert(title: String, message: String) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .default))
        return alert
    }
    
}
