//
//  LoopView.swift
//  AudioDownloader
//
//  Created by Jack Vanderpump on 30/06/2020.
//  Copyright © 2020 Jack Vanderpump. All rights reserved.
//

import SwiftUI

struct RepeatView: View {
    
    @EnvironmentObject var repeatManager: RepeatManager
    @StateObject var repeatVM: RepeatViewModel
        
    var body: some View {
        Form {
            Toggle("Enable repeat of track:", isOn: $repeatVM.repeatItem.enabled)
            MinsRowView(repeatMins: $repeatVM.repeatItem.repeatMins)
            TrackRowView(files: repeatVM.files, selectedURL: $repeatVM.repeatItem.audio)
        }
        .onReceive(repeatVM.$repeatItem) { value in
            repeatManager.saveRepeat(value)
        }
        .listStyle(GroupedListStyle())
        .navigationBarTitle("Loop Track")
        .accentColor(.pumpyPink)
    }
    
}

#if DEBUG
struct RepeatView_Previews: PreviewProvider {
    static var previews: some View {
        RepeatView(repeatVM: RepeatViewModel(repeatManager: RepeatManager(username: "Test", musicManager: MusicManager(username: "Test", settingsManager: SettingsManager(username: "Test")))))
    }
}
#endif
