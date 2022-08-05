//
//  ExtDisplaySettingsView.swift
//  Pumpy Music iOS
//
//  Created by Jack Vanderpump on 27/04/2021.
//  Copyright © 2021 Jack Vanderpump. All rights reserved.
//

import SwiftUI
import PumpyLibrary

struct ExtDisplaySettingsView: View {
    
    @EnvironmentObject var extDisMgr: ExternalDisplayManager
    
    var body: some View {
        List {
            Section {
                ExtDisplaySettingsRows(displayContent: $extDisMgr.defaultSettings.displayContent,
                                       showQRCode: $extDisMgr.defaultSettings.showQRCode,
                                       qrURL: $extDisMgr.defaultSettings.qrURL,
                                       marqueeTextLabel: $extDisMgr.defaultSettings.marqueeTextLabel,
                                       marqueeSpeed: $extDisMgr.defaultSettings.marqueeLabelSpeed,
                                       qrType: $extDisMgr.defaultSettings.qrType)
            }
            if extDisMgr.extDisType == .override {
                Section {
                    Button(action: {
                        extDisMgr.extDisType = .defualts
                    }, label: {
                        Text("Return Current External Display Back to Default Settings")
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                    })
                }
            }
        }
        .onDisappear() {
            extDisMgr.saveSettingsOnline()
        }
        .navigationBarTitle("External Display")
        .listStyle(InsetGroupedListStyle())
    }
}

#if DEBUG
struct ExtDisplaySettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ExtDisplaySettingsView().environmentObject(ExternalDisplayManager(username: "Test", musicManager: MusicManager(username: "Test", settingsManager: SettingsManager(username: "Test"))))
        }
    }
}
#endif
