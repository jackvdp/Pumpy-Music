//
//  MinsRowView.swift
//  AudioDownloader
//
//  Created by Jack Vanderpump on 01/07/2020.
//  Copyright © 2020 Jack Vanderpump. All rights reserved.
//

import SwiftUI

struct MinsRowView: View {
    
    @Binding var repeatMins: Int
    let minutes = [15, 30, 60, 90, 120]

    var body: some View {
        Picker(selection: $repeatMins, label:
                FormViewRow(title: "Repeat every:", subTitle: "\(repeatMins) mins")
        ) {
            ForEach(minutes, id: \.self) { i in
                Text("\(i) mins")
            }
        }.pickerStyle(MenuPickerStyle())
    }
}

struct MinsRowView_Previews: PreviewProvider {
    static var previews: some View {
        MinsRowView(repeatMins: .constant(15))
    }
}
