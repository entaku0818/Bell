//
//  FlightAlarmActivity.swift
//  Bell
//
//  Created by 遠藤拓弥 on 2025/11/22.
//

import ActivityKit
import SwiftUI

struct FlightAlarmAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var flightNumber: String
        var destination: String
        var departureDate: Date
    }

    var flightInfo: String
}

struct FlightAlarmActivityView: View {
    let context: ActivityViewContext<FlightAlarmAttributes>

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "airplane.departure")
                    .foregroundColor(.blue)

                Text(context.state.flightNumber)
                    .font(.headline)

                Text("\(context.state.destination)行き")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Spacer()
            }

            HStack {
                Text("搭乗まで")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text(timeRemaining)
                    .font(.title2)
                    .fontWeight(.bold)
                    .monospacedDigit()
            }
        }
        .padding()
    }

    private var timeRemaining: String {
        let now = Date()
        let remaining = context.state.departureDate.timeIntervalSince(now)

        if remaining <= 0 {
            return "00:00:00"
        }

        let hours = Int(remaining) / 3600
        let minutes = (Int(remaining) % 3600) / 60
        let seconds = Int(remaining) % 60

        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}
