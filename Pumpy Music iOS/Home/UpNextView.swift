//
//  UpNextView.swift
//  Pumpy Music iOS
//
//  Created by Jack Vanderpump on 20/04/2021.
//  Copyright © 2021 Jack Vanderpump. All rights reserved.
//

import SwiftUI
import MediaPlayer

struct UpNextView: View {
    
    @EnvironmentObject var queueManager: QueueManager
    var fontStyle: Font
    var subFontOpacity: Double
    var showButton: Bool
    @State private var showUpNext = true
    
    init(fontStyle: Font = .subheadline, opacity: Double = 1.0, showButton: Bool = true) {
        self.fontStyle = fontStyle
        self.subFontOpacity = opacity
        self.showButton = showButton
        UITableView.appearance().separatorStyle = .none
        UITableViewCell.appearance().backgroundColor = .clear
        UITableView.appearance().backgroundColor = .clear
    }
    
    var body: some View {
        TitleHeader(fontStyle: fontStyle, subFontOpacity: subFontOpacity, showUpNext: $showUpNext)
        ScrollViewReader { proxy in
            List {
                ForEach(queueManager.queueTracks.indices, id: \.self) { i in
                    if let track = queueManager.queueTracks[safe: i] {
                        TrackRow(track: track)
                            .deleteDisabled(!(i > queueManager.queueIndex) || !queueManager.readyToEditQueue)
                            .onAppear() {
                                if i != queueManager.queueIndex {
                                    showNextOrPrevious(i)
                                }
                            }
                            .foregroundColor(i != queueManager.queueIndex ? .white : .pumpyPink)
                            .id(track.id)
                    }
                }
                .onDelete { indexSet in
                    removeRowsFromUpNext(at: indexSet)
                }
                .listRowBackground(Color.clear)
            }
            .listStyle(PlainListStyle())
            .onChange(of: queueManager.queueTracks) { tracks in
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    scroll(proxy)
                }
            }
            .onChange(of: queueManager.queueIndex) { tracks in
                scroll(proxy)
            }
            .onAppear() {
                scroll(proxy)
            }
            .animation(.easeIn(duration: 0.5))
            .mask(UpNextMask())
        }
    }
    
    func scroll(_ proxy: ScrollViewProxy) {
        if let track = queueManager.queueTracks[safe: queueManager.queueIndex + 1] {
            withAnimation {
                proxy.scrollTo(track.id, anchor: .top)
            }
        }
    }
    
    func showNextOrPrevious(_ i: Int) {
        if i + 1 < queueManager.queueIndex {
            showUpNext = false
        } else {
            showUpNext = true
        }
    }
    
    func removeRowsFromUpNext(at offsets: IndexSet) {
        for i in offsets {
            if queueManager.queueTracks.indices.contains(i) {
                let track = queueManager.queueTracks[i]
                queueManager.queueTracks.remove(at: i)
                queueManager.removeFromQueue(id: track.playbackID)
            }
        }
    }
}





#if DEBUG
struct UpNextView_Previews: PreviewProvider {
    
    static let queueManager = QueueManager(name: "Test")
    
    static var previews: some View {
        
        queueManager.queueTracks = [
            Track(title: "Na", artist: "Na", playbackID: "Na", isExplicit: true),
            Track(title: "Na", artist: "Na", playbackID: "Na", isExplicit: true),
            Track(title: "Na", artist: "Na", playbackID: "Na", isExplicit: true),
            Track(title: "Na", artist: "Na", playbackID: "Na", isExplicit: true),
            Track(title: "Na", artist: "Na", playbackID: "Na", isExplicit: true),
            Track(title: "Na", artist: "Na", playbackID: "Na", isExplicit: true),
            Track(title: "Na", artist: "Na", playbackID: "Na", isExplicit: true)
        ]
        
        return UpNextView()
            .environmentObject(queueManager)
            .environmentObject(TokenManager())
            .environmentObject(BlockedTracksManager(username: "Test", queueManager: queueManager))
            .environmentObject(NowPlayingManager(spotifyTokenManager: SpotifyTokenManager()))
    }
}
#endif

//extension UpNextView {
    
    struct TitleHeader: View {
        var fontStyle: Font
        var subFontOpacity: Double
        var enableButton = true
        @Binding var showUpNext: Bool
        @Namespace var title
        
        var body: some View {
            VStack {
                HStack {
                    UpNextTitle(fontStyle: fontStyle,
                              subFontOpacity: subFontOpacity * (showUpNext ? 1.0 : 0),
                              text: "Playing Next")
                        .id(title)
                    Spacer()
                    UpNextTitle(fontStyle: fontStyle,
                              subFontOpacity: subFontOpacity * (!showUpNext ? 1.0 : 0),
                              text: "Previous Tracks",
                              alignment: .trailing
                    )
                    .id(title)
                    .padding(.trailing)
                }
                .animation(.easeIn(duration: 0.5))
                Divider()
            }
            .padding(.leading)
        }
    }
    
    struct UpNextTitle: View {
        var fontStyle: Font
        var subFontOpacity: Double
        var text: String
        var alignment: Alignment = .leading
        var body: some View {
            Text(text)
                .font(fontStyle)
                .frame(maxWidth: .infinity, alignment: alignment)
                .opacity(subFontOpacity)
        }
    }
    
    struct UpNextMask: View {
        var body: some View {
            LinearGradient(gradient: Gradient(colors: [Color.white, Color.white, Color.white, Color.white, Color.white, Color.white, Color.white,Color.white,Color.white, Color.white, Color.white, Color.white, Color.white.opacity(0)]), startPoint: .top, endPoint: .bottom)
        }
        
    }
    
//}
