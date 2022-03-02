//
//  SettingsView.swift
//  Pumpy Music iOS
//
//  Created by Jack Vanderpump on 14/03/2021.
//  Copyright © 2021 Jack Vanderpump. All rights reserved.
//

import SwiftUI

struct SettingsView: View {
    
    @EnvironmentObject var settingsVM: SettingsManager
    @State var passwordField = UITextField()
    @State var revealAdminSettings: Bool = false
    
    var body: some View {
        VStack {
            Form {
                Section {
                    Toggle("Use Crossfade", isOn: $settingsVM.settings.crossfadeOn)
                    Toggle("Ban Explicit Content:", isOn: $settingsVM.settings.banExplicit)
                }
                if revealAdminSettings {
                    Section {
                        Toggle("Show Music Library", isOn: $settingsVM.settings.showMusicLibrary)
                        Toggle("Show Music Store", isOn: $settingsVM.settings.showMusicStore)
                    }
                    Section {
                        Toggle("Show Playlist Scheduler:", isOn: $settingsVM.settings.showScheduler)
                    }
                    Section {
                        Toggle("Show External Display:", isOn: $settingsVM.settings.showExternalDisplay)
                    }
                }
                Section {
                    NavigationLink(destination: CapabilitiesView()) {
                        MenuRow(title: "Capabilities", imageName: "bolt.fill")
                    }
                }
            }
            if !revealAdminSettings {
                Spacer()
                Button {
                    lockSettingsAlert()
                } label: {
                    HStack {
                        Image(systemName: "lock.fill").foregroundColor(.white)
                        Text("Access Admin Settings")
                    }.padding()
                }
            }
        }
        .toggleStyle(SwitchToggleStyle(tint: Color.pumpyPink))
        .accentColor(.pumpyPink)
        .navigationBarTitle("Settings")
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var settingsView = SettingsView(revealAdminSettings: true)
    
    static var previews: some View {
        settingsView
            .environmentObject(SettingsManager(username: "Test"))
    }
}
