//
//  LoggedOffView.swift
//  Pumpy Music iOS
//
//  Created by Jack Vanderpump on 17/04/2021.
//  Copyright © 2021 Jack Vanderpump. All rights reserved.
//

import SwiftUI

extension ExternalDisplayView {
    struct LoggedOffView: View {
        var body: some View {
            GeometryReader { geo in
                ZStack {
                    BackgroundView()
                    VStack {
                        PumpyView()
                            .padding()
                            .frame(width: geo.size.width * 0.5)
//                            .shadow(color: .black, radius: /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
                    }
                }
            }
        }
    }
}

#if DEBUG
struct LoggedOffView_Previews: PreviewProvider {
    static var previews: some View {
        ExternalDisplayView.LoggedOffView()
            .previewLayout(.sizeThatFits)
            .frame(width: 1920, height: 1080)
    }
}
#endif
