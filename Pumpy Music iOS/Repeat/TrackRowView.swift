//
//  TrackRowView.swift
//  AudioDownloader
//
//  Created by Jack Vanderpump on 01/07/2020.
//  Copyright © 2020 Jack Vanderpump. All rights reserved.
//

import SwiftUI

struct TrackRowView: View {
    
    let files: [String]
    @Binding var selectedURL: String?
    
    var body: some View {
        Picker(selection: $selectedURL, label:
                FormViewRow(title: "Track to repeat:", subTitle: selectedURL ?? "Select Track")
        ) {
            Text("-- Select Track --").tag(nil as String?)
            ForEach(files, id: \.self) { track in
                Text(track).tag(track as String?)
            }
        }.pickerStyle(MenuPickerStyle())
    }
        
}


//struct TrackRowView_Previews: PreviewProvider {
//    static var previews: some View {
//        TrackRowView(musicManager: .constant(MusicManager(), selectedTrack: .constant(<#T##value: URL##URL#>), audioFiles: <#T##[URL]#>)
//    }
//}
