//
//  PlayerControls.swift
//  Pumpy Music iOS
//
//  Created by Jack Vanderpump on 20/04/2020.
//  Copyright © 2020 Jack Vanderpump. All rights reserved.
//

import SwiftUI
import AVKit
import MediaPlayer
import Scheduler

struct PlayerControls: View {
    
    @EnvironmentObject var homeVM: HomeVM
    
    var body: some View {
        HStack(alignment: .center, spacing: 40.0) {
            UpNextButton(homeVM: homeVM)
            PlayButton()
            FastForwardButton()
        }
    }
    
    struct PlayButton: View {
        
        @EnvironmentObject var playlistManager: PlaylistManager
        @EnvironmentObject var nowPlayingManager: NowPlayingManager
        @EnvironmentObject var alarmData: AlarmData
        
        var body: some View {
            Image(nowPlayingManager.playButtonState.rawValue)
                .resizable()
                .frame(width: 40, height: 40, alignment: .center)
                .accentColor(.white)
                .onTapGesture {
                    MusicCoreFunctions.togglePlayPause(alarms: alarmData.alarmArray,
                                                       playlistManager: playlistManager)
                }
                .onLongPressGesture(minimumDuration: 2) {
                    MusicCoreFunctions.coldStart(alarms: alarmData.alarmArray,
                                                 playlistManager: playlistManager)
                }
            
        }
    }

    struct FastForwardButton: View {
        @EnvironmentObject var musicManager: MusicManager
        
        var body: some View {
            Button(action: {
                    MusicCoreFunctions.skipToNextItem()
                        
            }) {
                Image("fast-forward-button copy")
                    .resizable()
                    .frame(width: 40, height: 40, alignment: .center)
                    .accentColor(.white)
            }
            
        }
    }

    struct UpNextButton: View {
        @ObservedObject var homeVM: HomeVM
        
        var body: some View {
            Button(action: {
                withAnimation {
                    switch homeVM.pageType {
                    case .artwork:
                    homeVM.pageType = .upNext
                    case .upNext:
                    homeVM.pageType = .artwork
                    }
                }
            }) {
                Image(systemName: "list.bullet")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30, alignment: .center)
                    .foregroundColor(homeVM.pageType == .upNext ? .pumpyPink : .white)
                    .font(Font.title.weight(.light))
            }
        }
    }
    
}



#if DEBUG
struct PlayerControls_Previews: PreviewProvider {
    
    static let homeVm = HomeVM()
    static let user = User(username: "Test")
    
    static var previews: some View {
        homeVm.pageType = .upNext
        return PlayerControls()
            .environmentObject(homeVm)
            .environmentObject(user.musicManager)
            .environmentObject(user.musicManager.nowPlayingManager)
            .environmentObject(user.musicManager.playlistManager)
            .environmentObject(user.musicManager.blockedTracksManager)
            .environmentObject(user.settingsManager)
            .environmentObject(user.externalDisplayManager)
            .environmentObject(user.alarmData)
            .environmentObject(user.musicManager.tokenManager)
            .environmentObject(user.musicManager.queueManager)
    }
}
#endif
