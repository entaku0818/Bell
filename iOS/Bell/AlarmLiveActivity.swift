//
//  AlarmLiveActivity.swift
//  Bell
//
//  Created by 遠藤拓弥 on 2025/11/22.
//

import SwiftUI
import AlarmKit
import ActivityKit

struct FlightAlarmAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var flightNumber: String
        var destination: String
        var departureDate: Date
        var isAlerting: Bool
    }

    var flightInfo: String
}

struct AlarmLiveActivityView: View {
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

            if context.state.isAlerting {
                Text("🔔 搭乗時刻です！")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.red)

                HStack(spacing: 12) {
                    Button(intent: DismissAlarmIntent()) {
                        Label("確認済み", systemImage: "checkmark")
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }

                    Button(intent: SnoozeAlarmIntent(duration: 300)) {
                        Label("5分後", systemImage: "clock")
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
            } else {
                HStack {
                    Text("搭乗まで")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text(timeRemaining)
                        .font(.title2)
                        .fontWeight(.bold)
                        .monospacedDigit()
                }

                Button(intent: PauseAlarmIntent()) {
                    Label("一時停止", systemImage: "pause")
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
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

struct DismissAlarmIntent: AppIntent {
    static var title: LocalizedStringResource = "Dismiss Alarm"

    func perform() async throws -> some IntentResult {
        return .result()
    }
}

struct SnoozeAlarmIntent: AppIntent {
    static var title: LocalizedStringResource = "Snooze Alarm"

    @Parameter(title: "Duration")
    var duration: TimeInterval

    func perform() async throws -> some IntentResult {
        return .result()
    }
}

struct PauseAlarmIntent: AppIntent {
    static var title: LocalizedStringResource = "Pause Alarm"

    func perform() async throws -> some IntentResult {
        return .result()
    }
}
