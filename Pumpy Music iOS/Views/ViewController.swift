//
//  ViewController.swift
//  Pumpy Music iOS
//
//  Created by Jack Vanderpump on 17/09/2019.
//  Copyright © 2019 Jack Vanderpump. All rights reserved.
//

import UIKit
import MediaPlayer
import AVKit
import SwiftUI

@objcMembers
class ViewController: UIViewController, MPMediaPickerControllerDelegate {
    
    let musicPlayerManager = MusicPlayerManager()
    var currentArtwork: MPMediaItemArtwork!
    var myTimer: Timer!
    var mpVolumeSlider: UISlider?

    @IBOutlet weak var backgroundView: UIImageView!
    @IBOutlet weak var playerArtwork: UIImageView!
    @IBOutlet weak var currentTrackNameLabel: MarqueeLabel!
    @IBOutlet weak var currentTrackArtistLabel: MarqueeLabel!
    @IBOutlet weak var skipToPreviousItemButton: UIButton!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var skipToNextItemButton: UIButton!
    @IBOutlet weak var currentPlaylist: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var playbackTimeLabel: UILabel!
    @IBOutlet weak var playbackDurationLabel: UILabel!
    @IBOutlet weak var volumeParentView: UIView!
    @IBOutlet weak var airPlayView: UIView!
    @IBSegueAction func toPlaylistPicker(_ coder: NSCoder) -> UIViewController? {
        return UIHostingController(coder: coder, rootView: PlaylistTable())
    }
 
    // MARK: Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.setNeedsStatusBarAppearanceUpdate()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleMusicPlayerManagerDidUpdateState),
                                               name: MusicPlayerManager.didUpdateState,
                                               object: nil)
        self.myTimer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(self.updateProgress), userInfo: nil, repeats: true)
        updatePlaybackControls()
        updateProgress()
        marqueeLabels()
        navigationBarFormat()
        setupAirPlayButton()
        setupVolumeSlider()
        
        for family in UIFont.familyNames.sorted() {
            let names = UIFont.fontNames(forFamilyName: family)
            print("Family: \(family) Font names: \(names)")
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
    func updateProgress() {
        let playbackTime = musicPlayerManager.musicPlayerController.currentPlaybackTime
        let playbackDuration = musicPlayerManager.musicPlayerController.nowPlayingItem?.playbackDuration
        if (musicPlayerManager.musicPlayerController.playbackState == MPMusicPlaybackState.playing) {
            if let playbackDurationUnwrapped = playbackDuration {
            progressBar.setProgress(Float(playbackTime/playbackDurationUnwrapped), animated: true)
            }
        } else if (musicPlayerManager.musicPlayerController.playbackState == MPMusicPlaybackState.paused) {
            if let playbackDurationUnwrapped = playbackDuration {
            progressBar.setProgress(Float(playbackTime/playbackDurationUnwrapped), animated: true)
            }
        } else {
                progressBar.progress = 0
        }
        timeLabels()
    }
    
    func marqueeLabels() {
        currentTrackNameLabel.type = .continuous
        currentTrackNameLabel.animationCurve = .linear
        currentTrackNameLabel.speed = .rate(30)
        currentTrackNameLabel.trailingBuffer = 30
        currentTrackArtistLabel.type = .continuous
        currentTrackArtistLabel.animationCurve = .linear
        currentTrackArtistLabel.speed = .rate(30)
        currentTrackArtistLabel.trailingBuffer = 30
    }
    
    func timeLabels() {
        let playbackTime = musicPlayerManager.musicPlayerController.currentPlaybackTime
        let playbackDuration = musicPlayerManager.musicPlayerController.nowPlayingItem?.playbackDuration ?? 0
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        dateFormatter.dateFormat = "mm:ss"
        let playbackTimeFormat = dateFormatter.string(from: Date(timeIntervalSinceReferenceDate: playbackTime))
        let playbackDurationFormat = dateFormatter.string(from: Date(timeIntervalSinceReferenceDate: playbackDuration))
        playbackTimeLabel.text = playbackTimeFormat
        playbackDurationLabel.text = playbackDurationFormat
    }
    
    func navigationBarFormat() {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        let imageView = UIImageView(image: UIImage(imageLiteralResourceName: "Pumpy Name"))
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        navigationItem.titleView = imageView
    }
    
    func setupVolumeSlider() {
        // Note: This slider implementation uses a MPVolumeView
        // The volume slider only works in devices, not the simulator.
        for subview in MPVolumeView().subviews {
            guard let volumeSlider = subview as? UISlider else { continue }
            mpVolumeSlider = volumeSlider
        }
        
        guard let mpVolumeSlider = mpVolumeSlider else { return }
        
        volumeParentView.addSubview(mpVolumeSlider)
        
        mpVolumeSlider.translatesAutoresizingMaskIntoConstraints = false
        mpVolumeSlider.leftAnchor.constraint(equalTo: volumeParentView.leftAnchor).isActive = true
        mpVolumeSlider.rightAnchor.constraint(equalTo: volumeParentView.rightAnchor).isActive = true
        mpVolumeSlider.centerYAnchor.constraint(equalTo: volumeParentView.centerYAnchor).isActive = true
        
        mpVolumeSlider.setThumbImage(#imageLiteral(resourceName: "Thumb"), for: .normal)
    }
    
    func setupAirPlayButton() {
        if #available(iOS 11.0, *) {
            let airPlayButton = AVRoutePickerView(frame: airPlayView.bounds)
            airPlayButton.tintColor = .white
            airPlayButton.activeTintColor = UIColor(named: "pumpyPink")
            airPlayView.backgroundColor = .clear
            airPlayView.addSubview(airPlayButton)
        } else {
            let airPlayButton = MPVolumeView(frame: airPlayView.bounds)
            airPlayButton.showsVolumeSlider = false
            airPlayView.backgroundColor = .clear
            airPlayView.addSubview(airPlayButton)
        }
    }
    
    // MARK: Buttons
    
    @IBAction func playPause(_ sender: Any) {
        musicPlayerManager.togglePlayPause()
    }
    
    @IBAction func skipToNextItem(_ sender: Any) {
        musicPlayerManager.skipToNextItem()
    }
    
    @IBAction func skipBack(_ sender: Any) {
        musicPlayerManager.skipBackToBeginningOrPreviousItem()
    }
    
    @IBAction func airplayButton(_ sender: Any) {
        
    }
    
    @IBAction func volumeSlider(_ sender: Any) {
        
    }

    @IBAction func playlistButton(_ sender: Any) {
        print("Pressing")
        musicPlayerManager.togglePlayPause()
    }
    // MARK: UI Update Methods
    
    func updatePlaybackControls() {
        let playbackState = musicPlayerManager.musicPlayerController.playbackState
        
        switch playbackState {
        case .interrupted, .paused, .stopped:
            playPauseButton.setImage(#imageLiteral(resourceName: "Play"), for: .normal)
        case .playing:
            playPauseButton.setImage(#imageLiteral(resourceName: "Pause"), for: .normal)
        default:
            break
        }
        
        if playbackState == .stopped {
            skipToPreviousItemButton.isEnabled = false
            // playPauseButton.isEnabled = false
            skipToNextItemButton.isEnabled = false
        } else {
            skipToPreviousItemButton.isEnabled = true
            playPauseButton.isEnabled = true
            skipToNextItemButton.isEnabled = true
        }
        updateCurrentItemMetadata()
    }
    
    func updateCurrentItemMetadata() {
        
        if let nowPlayingItem = musicPlayerManager.musicPlayerController.nowPlayingItem {
            currentArtwork = nowPlayingItem.artwork
            playerArtwork.image = currentArtwork?.image(at: playerArtwork.frame.size)
            backgroundView.image = currentArtwork?.image(at: backgroundView.frame.size)
            currentTrackNameLabel.text = nowPlayingItem.title
            currentTrackArtistLabel.text = nowPlayingItem.artist
        } else {
            playerArtwork.image = .init(imageLiteralResourceName: "Pumpy Artwork")
            backgroundView.image = .init(imageLiteralResourceName: "Pumpy Artwork")
            currentTrackNameLabel.text = "Not Playing"
            currentTrackArtistLabel.text = "– – – –"
            currentPlaylist.text = "Playlist: N/A"
            
        }
    }
    
    // MARK: Notification Observing Methods
    
    func handleMusicPlayerManagerDidUpdateState() {
        DispatchQueue.main.async {
            self.updatePlaybackControls()
        }
    }
    
}


class AlertHelper {
    func showAlert(fromController controller: UIViewController) {
        var alert = UIAlertController(title: "abc", message: "def", preferredStyle: .alert)
        controller.present(alert, animated: true, completion: nil)
    }
}


