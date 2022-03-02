//
//  Charts.swift
//  Pumpy Music iOS
//
//  Created by Jack Vanderpump on 04/09/2021.
//  Copyright © 2021 Jack Vanderpump. All rights reserved.
//

import SwiftUI
import Charts

struct AnalyticsView: View {
    
    @EnvironmentObject var nowPlayingManger: NowPlayingManager
    
    var body: some View {
        NavigationView {
            VStack {
                if let featuresFigures = nowPlayingManger.currentAudioFeatures {
                    List {
                        AnalyticsFiguresView(features: AudioFeaturesString(features: featuresFigures))
                        ChartView(featuresFigures: featuresFigures)
                    }
                } else {
                    Text("Features Unavailable")
                        .foregroundColor(Color.gray)
                        .font(.largeTitle)
                }
            }
            .navigationTitle("Track Stats")
        }
    }
}

#if DEBUG
struct AnalyticsView_Previews: PreviewProvider {
    
    static var npm = NowPlayingManager(spotifyTokenManager: SpotifyTokenManager())
    
    static var previews: some View {
        npm.currentAudioFeatures = AudioFeatures(danceability: 0.3, energy: 0.2, key: 0, loudness: 0.4, tempo: 150, valence: 0.6, liveliness: 0.7)
        return NavigationView {
            AnalyticsView().environmentObject(npm)
        }
    }
}
#endif


extension AnalyticsView {
    
    struct AnalyticsFiguresView: View {
        let features: AudioFeaturesString
        var body: some View {
            Section {
                Text("BPM: " + features.tempoString)
                Text("Energy: " + features.energyString)
                Text("Danceability: " + features.danceabilityString)
                Text("Happiness: " + features.valenceString)
                Text("Liveliness: " + features.livelinessString)
                Text("Loudness: " + features.loudnessString)
            }
        }
    }
    
    struct ChartView: View {
        let featuresFigures: AudioFeatures
        var body: some View {
            Section {
                Chart(data: figures)
                    .chartStyle(
                        ColumnChartStyle(column: Capsule().foregroundColor(.pumpyPink), spacing: 2)
                    )
                    .frame(height: 300)
                HStack {
                    Text("BPM").rotationEffect(Angle(degrees: 270)).lineLimit(1)
                    Spacer()
                    Text("Energy").rotationEffect(Angle(degrees: 270)).lineLimit(1)
                    Spacer()
                    Text("Danceability").rotationEffect(Angle(degrees: 270)).lineLimit(1)
                    Spacer()
                    Text("Happiness").rotationEffect(Angle(degrees: 270)).lineLimit(1)
                    Spacer()
                    Text("Liveliness").rotationEffect(Angle(degrees: 270)).lineLimit(1)
                }
            }
        }
        
        var figures: [Double] {
            return [
                (Double(featuresFigures.tempo ?? 0) / 200),
                Double(featuresFigures.energy ?? 0),
                Double(featuresFigures.danceability ?? 0),
                Double(featuresFigures.valence ?? 0),
                Double(featuresFigures.liveliness ?? 0),
            ]
        }
    }
}
