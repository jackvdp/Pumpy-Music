//
//  HomeView.swift
//  Pumpy Music iOS
//
//  Created by Jack Vanderpump on 03/12/2019.
//  Copyright © 2019 Jack Vanderpump. All rights reserved.
//

import SwiftUI
import MediaPlayer
import UIKit
import AVKit
import Combine

struct HomeView: View {
    
    let musicPlayerManager: MusicPlayerManager = MusicPlayerManager()
    @State var currentArtwork: MPMediaItemArtwork? = MPMediaItemArtwork(image: UIImage(imageLiteralResourceName: "Pumpy Artwork"))
    @State var currentTrack: String? = "N/A"
    @State var currentArtist: String? = "N/A"
    @State var playButtonImage: String? = "Play"
    @State var progressBarInt: CGFloat? = 0
    @State var playbackTimeFormat: String? = "0:00"
    @State var playbackDurationFormat: String? = "0:00"
    let musicManager = MusicManager.sharedMusicManager
    
    
    var body: some View {
        let timer = Timer.publish(every: 0.25, on: .main, in: .common).autoconnect()
        
        return ZStack() {
            backgroundImage(backgroundArtwork: currentArtwork!)
            darkEffect()
            VStack {
                NavigationBar()
                PlayerArtwork(playerArtwork: currentArtwork!, progressBarInt: progressBarInt ?? 0, playbackTimeFormat: playbackTimeFormat ?? "0:00", playbackDurationFormat: playbackDurationFormat ?? "0:00")
                Spacer()
                SongLabels(trackLabel: currentTrack!, artistLabel: currentArtist!, playlistLabel: "\(musicManager.playlistLabel)")
                Spacer()
                PlayerControls(playButtonImage: playButtonImage!)
                Spacer()
                VolumeControl()
            }
            .onReceive(timer) {_ in
                    self.updateProgress()
            }
        }
            .onAppear {
                let NC = NotificationCenter.default
                NC.addObserver(forName: MusicPlayerManager.didUpdateState,
                                    object: nil,
                                    queue: nil,
                                    using: self.handleMusicPlayerManagerDidUpdateState)
                
                self.updateTrackData()
                self.updatePlaybackControls()
                self.updateProgress()
        }
    }
    
    // MARK: UI Functions
    
    func updateTrackData() {
        if let nowPlayingItem = musicPlayerManager.musicPlayerController.nowPlayingItem {
            currentArtwork = nowPlayingItem.artwork ?? MPMediaItemArtwork(image: UIImage(imageLiteralResourceName: "Pumpy Artwork"))
            currentArtist = nowPlayingItem.artist ?? ""
            currentTrack = nowPlayingItem.title ?? "Not Available"
        } else {
            currentArtwork = MPMediaItemArtwork(image: UIImage(imageLiteralResourceName: "Pumpy Artwork"))
            currentTrack = "Not Playing"
            currentArtist = "– – – –"
        }
        print(musicManager.playlistLabel)
    }
    
    func handleMusicPlayerManagerDidUpdateState(_ notification: Notification) {
        DispatchQueue.main.async {
            self.updateTrackData()
            self.updatePlaybackControls()
        }
    }
    
    func updatePlaybackControls() {
        
        let playbackState = musicPlayerManager.musicPlayerController.playbackState
        
        switch playbackState {
        case .interrupted, .paused, .stopped:
            playButtonImage = "Play"
        case .playing:
            playButtonImage = "Pause"
        default:
            break
        }
        
    }
    
    func updateProgress() {
        let playbackTime = musicPlayerManager.musicPlayerController.currentPlaybackTime
        let playbackDuration = musicPlayerManager.musicPlayerController.nowPlayingItem?.playbackDuration
        if (musicPlayerManager.musicPlayerController.playbackState == MPMusicPlaybackState.playing) {
            if let playbackDurationUnwrapped = playbackDuration {
            progressBarInt = (CGFloat(playbackTime/playbackDurationUnwrapped))
            }
        } else if (musicPlayerManager.musicPlayerController.playbackState == MPMusicPlaybackState.paused) {
            if let playbackDurationUnwrapped = playbackDuration {
            progressBarInt = (CGFloat(playbackTime/playbackDurationUnwrapped))
            }
        } else {
                progressBarInt = 0
        }
        timeLabels()
    }
    
    func timeLabels() {
        let playbackTime = musicPlayerManager.musicPlayerController.currentPlaybackTime
        let playbackDuration = musicPlayerManager.musicPlayerController.nowPlayingItem?.playbackDuration ?? 0
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        dateFormatter.dateFormat = "mm:ss"
        playbackTimeFormat = dateFormatter.string(from: Date(timeIntervalSinceReferenceDate: playbackTime))
        playbackDurationFormat = dateFormatter.string(from: Date(timeIntervalSinceReferenceDate: playbackDuration))
    }
    
    
}



struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}


// MARK: Design


struct backgroundImage: View {
    
    var backgroundArtwork: MPMediaItemArtwork
    
    var body: some View {
        GeometryReader { geometry in
            Image(uiImage: self.backgroundArtwork.image(at: CGSize(width: 300, height: 300)) ?? UIImage(imageLiteralResourceName: "Pumpy Artwork"))
            .resizable()
            .blur(radius: 25)
            .aspectRatio(geometry.size, contentMode: .fill)
            .edgesIgnoringSafeArea(.all)
    }
    }
}

struct darkEffect: View {
    var body: some View {
        Rectangle()
            .fill(Color.black)
            .opacity(0.60)
            .edgesIgnoringSafeArea(.all)
    }
}

struct NavigationBar: View {
    var body: some View {
        VStack {
            HStack() {
                MusicButton()
                Spacer()
                Image("Pumpy Name")
                    .resizable()
                    .frame(width: 90, height: 30)
                    .aspectRatio(contentMode: .fit)
                Spacer()
                ScheduleButton()
            }
            .padding([.leading, .trailing], 20.0)
            .padding([.top], 10)
        }
    }
}

struct PlayerArtwork: View {
    
    @State private var boundWidth: CGFloat = 330.0
    var playerArtwork: MPMediaItemArtwork
    var progressBarInt: CGFloat
    var playbackTimeFormat: String
    var playbackDurationFormat: String
    
    var body: some View {
        VStack {
            ZStack(alignment: .bottomLeading) {
                Image(uiImage: playerArtwork.image(at: CGSize(width: 300, height: 300)) ?? UIImage(imageLiteralResourceName: "Pumpy Artwork"))
                    .resizable()
                    .aspectRatio(2/2, contentMode: .fit)
                    .alignmentGuide(.bottom, computeValue: { d in
                        DispatchQueue.main.async {
                            self.boundWidth = d.width // avoid change state during update
                        }
                        return d[.bottom]
                    })
                ProgressBarHighlight(barWidth: self.boundWidth)
                ProgressBar(barWidth: self.boundWidth, progressBarInt: progressBarInt)
            }
            .padding([.top, .leading, .trailing], 20.0)
            TimeLabels(barWidth: self.boundWidth, playbackTimeFormat: playbackTimeFormat, playbackDurationFormat: playbackDurationFormat)
        }
    }

    
}

struct ProgressBar: View {
    var barWidth: CGFloat
    var progressBarInt: CGFloat
    
    var body: some View {
        if progressBarInt >= 0 && progressBarInt <= 1 {
            return ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.gray)
                    .frame(width: self.barWidth, height: 2)
                Rectangle()
                    .fill(Color.white)
                    .frame(width: self.barWidth * progressBarInt, height: 2)
            }
        } else {
            return ZStack(alignment: .leading) {
            Rectangle()
                .fill(Color.gray)
                .frame(width: self.barWidth, height: 2)
            Rectangle()
                .fill(Color.white)
                .frame(width: self.barWidth * 1, height: 2)
        }
    }
    }
}

struct ProgressBarHighlight: View {
    var barWidth: CGFloat
    var body: some View {
            Rectangle()
                .fill(Color.black)
                .frame(width: self.barWidth, height: 30)
                .opacity(0.25)
                .blur(radius: 10)
    }
}

struct TimeLabels: View {
    var barWidth: CGFloat
    var playbackTimeFormat: String
    var playbackDurationFormat: String
    
    var body: some View {
        HStack {
            Text(playbackTimeFormat)
                .foregroundColor(Color.white)
            Spacer()
            Text(playbackDurationFormat)
                .foregroundColor(Color.white)
        }
    .frame(width: self.barWidth)
        .padding([.leading, .trailing], 20.0)
        .font(.custom("HelveticaNeue-Light", size: 15))
    }
}

struct SongLabels: View {
    
    var trackLabel: String
    var artistLabel: String
    var playlistLabel: String
    
    var body: some View {
        VStack(spacing: 5.0) {
            Text(trackLabel)
            .foregroundColor(Color.white)
            .font(.custom("HelveticaNeue", size: 17))
            .lineLimit(1)
            Text(artistLabel)
            .foregroundColor(Color.white)
            .font(.custom("HelveticaNeue-Light", size: 17))
            .lineLimit(1)
            Text(playlistLabel)
            .foregroundColor(Color.white)
            .font(.custom("HelveticaNeue-Light", size: 17))
            .lineLimit(1)
        }
        .padding(.bottom, 20.0)
        .padding([.leading, .trailing], 10.0)
    }
}

struct PlayerControls: View {
    var playButtonImage: String
    
    var body: some View {
        HStack(alignment: .center, spacing: 40.0) {
            rewindButton()
            playButton(playButtonImage: playButtonImage)
            fastforwardButton()
        }
        .padding(.bottom, 20.0)
    }
}

struct VolumeControl: View {
    var body: some View {
        HStack(alignment: .center, spacing: 25.0) {
            Image(systemName: "speaker")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(.white)
                .font(Font.title.weight(.light))
            .frame(width: 15, height: 15, alignment: .center)
            VolumeView()
                .frame(height: 20)
            AirPlayView()
                .frame(width: 15, height: 15)
        }
        .padding(.horizontal, 20.0)
        .padding(.bottom, 20.0)
    }
}




// MARK: Buttons

struct SchedulerView: UIViewControllerRepresentable {
    
    typealias UIViewControllerType = UINavigationController
    
    func makeUIViewController(context: Context) -> UINavigationController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "NavigationAlarm") as! UINavigationController

        }
    
    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
        //
    }
    
}

struct MusicButton: View {
    @State private var showPlaylists = false
    
    var body: some View {
                Button(action: {self.showPlaylists = true})
                { Image(systemName: "music.note.list")
                    .resizable()
                    .foregroundColor(Color.white)
                    .frame(width: 25, height: 25, alignment: .center)
                    .aspectRatio(contentMode: .fit)
                    .font(Font.title.weight(.ultraLight))
                    }
                .sheet(isPresented: $showPlaylists) {
                    PlaylistTable()
        }
            }

}

struct ScheduleButton: View {
    @State private var showScheduler = false
    
    var body: some View {
        Button(action: {self.showScheduler = true})
        { Image(systemName: "alarm")
            .resizable()
            .foregroundColor(Color.white)
            .frame(width: 25, height: 25, alignment: .center)
            .aspectRatio(contentMode: .fit)
            .font(Font.title.weight(.light))
        }
        .sheet(isPresented: $showScheduler) {
            SchedulerView()
        }
    }
}

struct playButton: View {
    let musicPlayerManager: MusicPlayerManager = MusicPlayerManager()
    var playButtonImage: String
    
    var body: some View {
        Button(action: {self.musicPlayerManager.togglePlayPause()})
        { Image(playButtonImage)
        .resizable()
            .frame(width: 40, height: 40, alignment: .center)
            .accentColor(.white)
        }
        
    }
}

struct fastforwardButton: View {
    let musicPlayerManager: MusicPlayerManager = MusicPlayerManager()
    var body: some View {
        Button(action: {self.musicPlayerManager.skipToNextItem()})
        { Image("fast-forward-button copy")
        .resizable()
            .frame(width: 40, height: 40, alignment: .center)
            .accentColor(.white)
        }
        
    }
}

struct rewindButton: View {
    let musicPlayerManager: MusicPlayerManager = MusicPlayerManager()
    
    var body: some View {
        Button(action: {self.musicPlayerManager.skipBackToBeginningOrPreviousItem()})
        { Image("rewind-button copy")
        .resizable()
            .frame(width: 40, height: 40, alignment: .center)
            .accentColor(.white)
        }
        
    }
}

struct VolumeView: UIViewRepresentable {
    
    func makeUIView(context: Context) -> MPVolumeView {
        MPVolumeView(frame: .zero)
    }
    
    func updateUIView(_ view: MPVolumeView, context: Context) {
        view.tintColor = .white
        view.setVolumeThumbImage(#imageLiteral(resourceName: "Thumb"), for: .normal)
        view.showsRouteButton = false
        }

}

struct AirPlayView: UIViewRepresentable {
    
    func makeUIView(context: Context) -> AVRoutePickerView {
        AVRoutePickerView(frame: .zero)
    }
    
    func updateUIView(_ view: AVRoutePickerView, context: Context) {
        view.tintColor = .white
        view.activeTintColor = UIColor(named: "pumpyPink")
        }

}
