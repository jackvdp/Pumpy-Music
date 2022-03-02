//
//  ExternalDisplayView.swift
//  Pumpy Music iOS
//
//  Created by Jack Vanderpump on 16/04/2021.
//  Copyright © 2021 Jack Vanderpump. All rights reserved.
//

import SwiftUI

struct ExternalDisplayView: View {
    
    @EnvironmentObject var accountManager: AccountManager
    
    var body: some View {
        if let user = accountManager.user {
            HomeView()
                .environmentObject(user.musicManager)
                .environmentObject(user.externalDisplayManager)
        } else {
            LoggedOffView()
        }
    }
}

#if DEBUG
struct ExternalDisplayView_Previews: PreviewProvider {
    static var previews: some View {
        ExternalDisplayView()
            .environmentObject(AccountManager())
            .previewLayout(.sizeThatFits)
            .frame(width: 1920, height: 1080)
    }
}
#endif
