//
//  HomeVM.swift
//  Pumpy Music iOS
//
//  Created by Jack Vanderpump on 20/04/2021.
//  Copyright © 2021 Jack Vanderpump. All rights reserved.
//

import Foundation
import SwiftUI

class HomeVM: ObservableObject {
    
    @Published var pageType: PageType = .artwork
    @Published var showMenu = false
    
    enum PageType {
        case artwork
        case upNext
    }
    
}
