//
//  SetQueueForDay.swift
//  Pumpy Music iOS
//
//  Created by Jack Vanderpump on 17/08/2020.
//  Copyright © 2020 Jack Vanderpump. All rights reserved.
//

import Foundation
import MediaPlayer

class SetQueueForDay {
    
    let alarms: [Alarm]
    let playlistManager: PlaylistManager
    let queue: QueueManager
    var overlap: Int = 0
    
    init(alarms: [Alarm], playlistManager: PlaylistManager, queue: QueueManager) {
        self.alarms = alarms
        self.playlistManager = playlistManager
        self.queue = queue
        setQueueForTheDay()
    }
    
    private func setQueueForTheDay() {
        
        // get current time
        let currentHour = Calendar.current.component(.hour, from: Date())
        let currentMinute = Calendar.current.component(.minute, from: Date())
        
        // get playlists for the day
        var todaysPlaylists = getTodaysPlaylists()
        
        if !todaysPlaylists.isEmpty {
            // filter future playlists
            todaysPlaylists = todaysPlaylists.filter { $0.time.hour > currentHour || ($0.time.hour == currentHour && $0.time.min > currentMinute || $0.time.hour < 6 ) }
            
            // sort playlists
            todaysPlaylists.sort {
                if $0.time.date.hour < 6, $1.time.date.hour >= 6 { return false }
                if $1.time.date.hour < 6, $0.time.date.hour >= 6 { return true }
                return ($0.time.date.hour, $0.time.date.minute) < ($1.time.date.hour, $1.time.date.minute)
            }
            
            // add the last playlist or the first future playlist again
            if let lastPlaylist = MusicCoreFunctions.getMostRecentPlaylist(alarms: alarms) {
                todaysPlaylists.insert(lastPlaylist, at: 0)
            }
            
            // create array of tracks from each playlist
            let itemsToAdd = makeItemsArray(todaysPlaylists)
            
            // add array to queue
            playlistManager.prependItems(itemsToAdd)
            
            // Prepare for BG
            queue.getUpNext()
            playlistManager.playlistLabel = "Playlist: Background Mode"
        }
        
    }
    
    
    private func getTodaysPlaylists() -> [Alarm] {
        var checkedAlarms = [Alarm]()

        for alarm in alarms {
            if (alarm.repeatStatus == [] || alarm.repeatStatus.contains(DetailInfo.getCurrentDayFormatted())) {
                checkedAlarms.append(alarm)
            }
        }
        return checkedAlarms
    }
    
    
    private func makeItemsArray(_ todaysPlaylists: [Alarm]) -> [MPMediaItem] {
        var itemsToAdd = [MPMediaItem]()
        let currentHour = Calendar.current.component(.hour, from: Date())
        let currentMinute = Calendar.current.component(.minute, from: Date())
        let currentSecond = Calendar.current.component(.second, from: Date())
        
        // Go through each playlist
        for i in 0...todaysPlaylists.count - 1 {
            var timeSegment = 0
            
            if todaysPlaylists.count > 1 {
                if i == 0 {
                    
                    // Get amount of time until first future playlist
                    timeSegment = ((todaysPlaylists[1].time.hour * 3600) + (todaysPlaylists[1].time.min * 60)) - ((currentHour * 3600) + (currentMinute * 60) + currentSecond)
                    // Adjust if it's in the late am
                    if todaysPlaylists[1].time.hour < 6 {
                        timeSegment += 86400
                    }
                    
                } else if i != todaysPlaylists.count - 1 {
                    
                    // Get amount of time for each of the future playlists
                    timeSegment = ((todaysPlaylists[i+1].time.hour * 3600) + (todaysPlaylists[i+1].time.min * 60)) - ((todaysPlaylists[i].time.hour * 3600) + (todaysPlaylists[i].time.min * 60) + overlap)
                    // Adjust if it's in the late am
                    if todaysPlaylists[i+1].time.hour < 6 {
                        timeSegment += 86400
                    }
                    
                }
            }
            
            // Get items from playlist for amount of time
            let alarm = todaysPlaylists[i]
            let items = playlistManager.getItemsFromAlarm(playlist: alarm.playlistLabel, secondaryPlaylists: alarm.secondaryPlaylists ?? [])
            let playlistItems = addTracksfromPlaylist(items, timeSegment)
            
            // Append playlist items to items from other playlists
            itemsToAdd.append(contentsOf: playlistItems ?? [])
        
        }
        
        return itemsToAdd
        
    }
    
    private func addTracksfromPlaylist(_ items: [MPMediaItem], _ time: Int) -> [MPMediaItem]? {
        var todaysItems = [MPMediaItem]()
        var cumulativeTracksTime: Int = 0
        
        // Cut at time segment unless last playlist
        if time != 0 {
            for item in items {
                if cumulativeTracksTime < time {
                    cumulativeTracksTime += Int(item.playbackDuration)
                    todaysItems.append(item)
                } else {
                    overlap = cumulativeTracksTime - time
                    // Send items for playlist or requested time
                    return todaysItems
                }
            }
        }
        
        // Send items for playlist if playlist is shorter than requested time or the last one
        todaysItems.append(contentsOf: items)
        return todaysItems
        
    }
    
}
