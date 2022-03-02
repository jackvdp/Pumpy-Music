//
//  StartView.swift
//  Pumpy Music iOS
//
//  Created by Jack Vanderpump on 03/04/2021.
//  Copyright © 2021 Jack Vanderpump. All rights reserved.
//

import SwiftUI

struct StartView: View {
    
    @EnvironmentObject var accountManager: AccountManager
    
    var body: some View {
        VStack {
            if let user = accountManager.user {
                UserView()
                    .environmentObject(user)
            } else if accountManager.pageState == .login {
                LoginView(usernamePlaceholder: "Enter your username",
                          buttonText: "Log In",
                          pageSwitchText: "Register")
            } else if accountManager.pageState == .register {
                LoginView(usernamePlaceholder: "Enter your email address",
                          buttonText: "Register",
                          pageSwitchText: "Already have an account?")
            }
        }
        .animation(.easeIn(duration: 0.5))
    }
}

#if DEBUG
struct StartView_Previews: PreviewProvider {
    static var previews: some View {
        StartView()
            .environmentObject(AccountManager())
    }
}
#endif

private struct UserView: View {
    
    @EnvironmentObject var user: User
    
    var body: some View {
        HomeView(homeVM: HomeVM())
            .environmentObject(user.musicManager)
            .environmentObject(user.musicManager.nowPlayingManager)
            .environmentObject(user.musicManager.playlistManager)
            .environmentObject(user.musicManager.blockedTracksManager)
            .environmentObject(user.settingsManager)
            .environmentObject(user.externalDisplayManager)
//            .environmentObject(user.repeatManager)
            .environmentObject(user.alarmData)
            .environmentObject(user.musicManager.tokenManager)
            .environmentObject(user.musicManager.queueManager)
            .environment(\.musicStoreKey, user.musicManager.tokenManager.appleMusicToken)
            .environment(\.musicStoreFrontKey, user.musicManager.tokenManager.appleMusicStoreFront)
//            .environment(\.settingsKey, user.settingsManager.settings)
    }
    
}
