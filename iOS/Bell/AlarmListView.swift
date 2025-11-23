//
//  AlarmListView.swift
//  Bell
//
//  Created by 遠藤拓弥 on 2025/11/22.
//

import SwiftUI

struct AlarmListView: View {
    let alarmViewModel: AlarmViewModel

    var body: some View {
        List {
            if alarmViewModel.alarms.isEmpty {
                Text("設定されているアラームはありません")
                    .foregroundColor(.secondary)
            } else {
                ForEach(alarmViewModel.alarms) { alarm in
                    AlarmRow(alarm: alarm)
                }
            }
        }
        .navigationTitle("アラーム一覧")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct AlarmRow: View {
    let alarm: AlarmViewModel.AlarmInfo

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "airplane.departure")
                    .foregroundColor(.blue)
                Text(alarm.flightNumber)
                    .font(.headline)
            }

            HStack {
                Text("行き先:")
                    .foregroundColor(.secondary)
                    .font(.caption)
                Text(alarm.destination)
                    .font(.subheadline)
            }

            HStack {
                Text("出発時刻:")
                    .foregroundColor(.secondary)
                    .font(.caption)
                Text(formatDate(alarm.departureDate))
                    .font(.subheadline)
            }

            HStack {
                Image(systemName: "alarm")
                    .foregroundColor(.orange)
                    .font(.caption)
                Text("アラーム: \(formatDate(alarm.alarmDate))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }
}

#Preview {
    NavigationStack {
        AlarmListView(alarmViewModel: AlarmViewModel())
    }
}
