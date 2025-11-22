//
//  AlarmViewModel.swift
//  Bell
//
//  Created by 遠藤拓弥 on 2025/11/22.
//

import Foundation
import AlarmKit
import SwiftUI

@Observable
class AlarmViewModel {
    var alarmSession: AlarmSession?
    var isAlarmActive = false
    var errorMessage: String?

    func createAlarm(for flightInfo: ExtractedFlightInfo) async {
        let metadata = FlightAlarmData(
            flightNumber: flightInfo.flightNumber,
            destination: flightInfo.destination,
            departureDate: flightInfo.departureDate
        )

        let configuration = AlarmConfiguration(
            scheduledTime: flightInfo.alarmDate,
            metadata: metadata
        )
        configuration.tintColor = .blue
        configuration.preAlert = 600
        configuration.postAlert = 300

        do {
            alarmSession = try await AlarmSession.create(configuration: configuration)
            isAlarmActive = true
            errorMessage = nil
        } catch {
            errorMessage = "アラームの設定に失敗しました: \(error.localizedDescription)"
            isAlarmActive = false
        }
    }

    func cancelAlarm() async {
        guard let session = alarmSession else { return }

        do {
            try await session.cancel()
            alarmSession = nil
            isAlarmActive = false
            errorMessage = nil
        } catch {
            errorMessage = "アラームのキャンセルに失敗しました: \(error.localizedDescription)"
        }
    }

    func snoozeAlarm(duration: TimeInterval) async {
        guard let session = alarmSession else { return }

        do {
            try await session.snooze(duration: duration)
        } catch {
            errorMessage = "スヌーズに失敗しました: \(error.localizedDescription)"
        }
    }
}
