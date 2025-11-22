//
//  BellWidgetLiveActivity.swift
//  BellWidget
//
//  Created by 遠藤拓弥 on 2025/11/22.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct BellWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: FlightAlarmAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "airplane.departure")
                        .foregroundColor(.blue)
                    Text(context.state.flightNumber)
                        .font(.headline)
                    Text("\(context.state.destination)行き")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                HStack {
                    Text("搭乗まで")
                        .font(.caption)
                    Text(timeRemaining(until: context.state.departureDate))
                        .font(.title2)
                        .fontWeight(.bold)
                        .monospacedDigit()
                }
            }
            .padding()
            .activityBackgroundTint(Color.blue.opacity(0.1))
            .activitySystemActionForegroundColor(Color.blue)

        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Image(systemName: "airplane.departure")
                        .foregroundColor(.blue)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text(context.state.flightNumber)
                        .font(.headline)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    HStack {
                        Text("搭乗まで")
                            .font(.caption)
                        Text(timeRemaining(until: context.state.departureDate))
                            .font(.title3)
                            .fontWeight(.bold)
                    }
                }
            } compactLeading: {
                Image(systemName: "airplane.departure")
            } compactTrailing: {
                Text(timeRemaining(until: context.state.departureDate))
                    .font(.caption)
                    .monospacedDigit()
            } minimal: {
                Image(systemName: "airplane")
            }
            .keylineTint(Color.blue)
        }
    }

    private func timeRemaining(until date: Date) -> String {
        let now = Date()
        let remaining = date.timeIntervalSince(now)

        if remaining <= 0 {
            return "00:00:00"
        }

        let hours = Int(remaining) / 3600
        let minutes = (Int(remaining) % 3600) / 60
        let seconds = Int(remaining) % 60

        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}

extension FlightAlarmAttributes {
    fileprivate static var preview: FlightAlarmAttributes {
        FlightAlarmAttributes(flightInfo: "NH123 羽田行き")
    }
}

extension FlightAlarmAttributes.ContentState {
    fileprivate static var example: FlightAlarmAttributes.ContentState {
        FlightAlarmAttributes.ContentState(
            flightNumber: "NH123",
            destination: "羽田",
            departureDate: Date().addingTimeInterval(7200)
        )
    }
}

#Preview("Notification", as: .content, using: FlightAlarmAttributes.preview) {
   BellWidgetLiveActivity()
} contentStates: {
    FlightAlarmAttributes.ContentState.example
}
