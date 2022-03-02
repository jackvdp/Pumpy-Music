//
//  ContentView.swift
//  AudioDownloader
//
//  Created by Jack Vanderpump on 21/06/2020.
//  Copyright © 2020 Jack Vanderpump. All rights reserved.
//

import SwiftUI

struct AudioDownloadView: View {
    
    @EnvironmentObject var user: User
    @EnvironmentObject var repeatManager: RepeatManager
    @EnvironmentObject var musicManager: MusicManager
    @StateObject var adViewModel: DownloadViewModel
    @State private var textFieldURL = String()
    @State var addURLTextField = UITextField()
    
    var body: some View {
        VStack {
            Text("Users must have the the owner's permission before downloading any file.")
                .font(.footnote)
                .foregroundColor(Color.gray)
                .multilineTextAlignment(.center)
                .padding(.all)
            List {
                ForEach(repeatManager.files, id: \.self) { file in
                    Button(action: { AudioPlayer().playSoundsFromURL(url: file.localURL) }) {
                        Text(file.localURL.lastPathComponent)
                    }
                }
                .onDelete(perform: delete)
            }
        }
        .navigationBarItems(
            leading: ActivityIndicator(isAnimating: $adViewModel.showSpinner, style: .medium),
            trailing: Button(action: {
                self.urlAddAudio()
            }, label: {
                Image(systemName: "plus")
            })
        )
        .navigationBarTitle("Audio Downloader")
        .navigationViewStyle(StackNavigationViewStyle())
        .accentColor(.pumpyPink)
    }
    
    
    func delete(at offsets: IndexSet) {
        offsets.forEach { i in
            adViewModel.deleteFile(at: i)
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        AudioDownloadView(adViewModel: DownloadViewModel(username: "Test", repeatManager: RepeatManager(username: "Test", musicManager: MusicManager(username: "Test", settingsManager: SettingsManager(username: "Test")))))
    }
}

struct ActivityIndicator: UIViewRepresentable {
    
    @Binding var isAnimating: Bool
    let style: UIActivityIndicatorView.Style
    
    func makeUIView(context: UIViewRepresentableContext<ActivityIndicator>) -> UIActivityIndicatorView {
        return UIActivityIndicatorView(style: style)
    }
    
    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityIndicator>) {
        isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
    }
}




