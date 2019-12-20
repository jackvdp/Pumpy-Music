

import UIKit
import MediaPlayer

@objcMembers
class MusicPlayerManager: NSObject {
    
    var timerTest : Timer?
    var nextPlaylist: String?
    
    // MARK: Types
    
    /// Notification that is fired when there is an update to the playback state or currently playing asset in `MPMusicPlayerController`.
    static let didUpdateState = NSNotification.Name("didUpdateState")
    
    // MARK: Properties
    
    /**
     The instance of `MPMusicPlayerController` that is used for playing back titles from either the device media library
     or from the Apple Music Catalog.
     */
    let musicPlayerController = MPMusicPlayerController.systemMusicPlayer
    
    override init() {
        super.init()
        
        /*
         It is important to call `MPMusicPlayerController.beginGeneratingPlaybackNotifications()` so that
         playback notifications are generated and other parts of the can update their state if needed.
         */
        musicPlayerController.beginGeneratingPlaybackNotifications()
        
        let notificationCenter = NotificationCenter.default
        
        notificationCenter.addObserver(self,
                                       selector: #selector(handleMusicPlayerControllerNowPlayingItemDidChange),
                                       name: .MPMusicPlayerControllerNowPlayingItemDidChange,
                                       object: musicPlayerController)
        
        notificationCenter.addObserver(self,
                                       selector: #selector(handleMusicPlayerControllerPlaybackStateDidChange),
                                       name: .MPMusicPlayerControllerPlaybackStateDidChange,
                                       object: musicPlayerController)
    }
    
    deinit {
        /*
         It is important to call `MPMusicPlayerController.endGeneratingPlaybackNotifications()` so that
         playback notifications are no longer generated.
         */
        musicPlayerController.endGeneratingPlaybackNotifications()
        
        // Remove all notification observers.
        let notificationCenter = NotificationCenter.default
        
        notificationCenter.removeObserver(self,
                                          name: .MPMusicPlayerControllerNowPlayingItemDidChange,
                                          object: musicPlayerController)
        notificationCenter.removeObserver(self,
                                          name: .MPMusicPlayerControllerPlaybackStateDidChange,
                                          object: musicPlayerController)
    }
    
    // MARK: Playback Loading Methods
    
    func beginPlayback(itemCollection: MPMediaItemCollection) {
        musicPlayerController.setQueue(with: itemCollection)
        
        musicPlayerController.play()
    }
    
    func beginPlayback(itemID: String) {
        musicPlayerController.setQueue(with: [itemID])
        
        musicPlayerController.play()
    }
    
    // MARK: Playback Control Methods
    
    func togglePlayPause() {
        if musicPlayerController.playbackState == .playing {
            musicPlayerController.pause()
        } else {
            musicPlayerController.prepareToPlay()
            musicPlayerController.play()
        }
    }
    
    func skipToNextItem() {
        musicPlayerController.skipToNextItem()
    }
    
    func skipBackToBeginningOrPreviousItem() {
        if musicPlayerController.currentPlaybackTime < 5 {
            // If the currently playing `MPMediaItem` is less than 5 seconds into playback then skip to the previous item.
            musicPlayerController.skipToPreviousItem()
        } else {
            // Otherwise skip back to the beginning of the currently playing `MPMediaItem`.
            musicPlayerController.skipToBeginning()
        }
    }
    
    func playPlaylist(chosenPlaylist: String?) {
        if musicPlayerController.playbackState == .playing {
            nextPlaylist = chosenPlaylist
            startTimer()
            if musicPlayerController.currentPlaybackTime > musicPlayerController.nowPlayingItem!.playbackDuration - 5 {
                playPlaylistNow(chosenPlaylist: chosenPlaylist)
                stopTimerTest()
            }
        } else {
            playPlaylistNow(chosenPlaylist: chosenPlaylist)
        }
    }
    
    func playPlaylistNow(chosenPlaylist: String?) {
        print("Playing")
        let myMediaQuery = MPMediaQuery.songs()
        let predicateFilter = MPMediaPropertyPredicate(value: chosenPlaylist, forProperty: MPMediaPlaylistPropertyName)
        myMediaQuery.filterPredicates = NSSet(object: predicateFilter) as? Set<MPMediaPredicate>
        musicPlayerController.setQueue(with: myMediaQuery)
        musicPlayerController.repeatMode = .all
        musicPlayerController.shuffleMode = .songs
        musicPlayerController.prepareToPlay()
        musicPlayerController.play()

    }
    
    @objc func playlistQueue() {
        if musicPlayerController.playbackState == .playing {
            if musicPlayerController.currentPlaybackTime > musicPlayerController.nowPlayingItem!.playbackDuration - 5 {
                playPlaylistNow(chosenPlaylist: nextPlaylist)
                stopTimerTest()
            }
        }
    }
    
    func startTimer() {
      guard timerTest == nil else { return }

      timerTest =  Timer.scheduledTimer(
          timeInterval: TimeInterval(1),
          target      : self,
          selector    : #selector(playlistQueue),
          userInfo    : nil,
          repeats     : true)
    }
    
    func stopTimerTest() {
        timerTest?.invalidate()
        timerTest = nil
    }
    
    
    
    
    // MARK: Notification Observing Methods
    
    func handleMusicPlayerControllerNowPlayingItemDidChange() {
        NotificationCenter.default.post(name: MusicPlayerManager.didUpdateState, object: nil)
    }
    
    func handleMusicPlayerControllerPlaybackStateDidChange() {
        NotificationCenter.default.post(name: MusicPlayerManager.didUpdateState, object: nil)
    }
    
    
    
}
