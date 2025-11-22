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
    private let alarmManager = AlarmManager.shared
    var currentAlarmID: UUID?
    var isAlarmActive = false
    var errorMessage: String?

    func createAlarm(for flightInfo: ExtractedFlightInfo) async {
        // Request authorization
        do {
            let authStatus = try await alarmManager.requestAuthorization()
            guard authStatus == .authorized else {
                errorMessage = "アラームの権限が許可されていません"
                return
            }
        } catch {
            errorMessage = "認証に失敗しました: \(error.localizedDescription)"
            return
        }

        // Create alarm presentation
        let alert = AlarmPresentation.Alert(
            title: "\(flightInfo.flightNumber) 搭乗時刻です"
        )

        let presentation = AlarmPresentation(alert: alert)

        let attributes = AlarmAttributes<FlightAlarmMetadata>(
            presentation: presentation,
            tintColor: .blue
        )

        let duration = Alarm.CountdownDuration(
            preAlert: flightInfo.departureDate.timeIntervalSince(Date()),
            postAlert: 300  // 5 minutes post-alert
        )

        let configuration = AlarmManager.AlarmConfiguration<FlightAlarmMetadata>(
            countdownDuration: duration,
            attributes: attributes
        )

        do {
            let alarmID = UUID()
            try await alarmManager.schedule(id: alarmID, configuration: configuration)
            currentAlarmID = alarmID
            isAlarmActive = true
            errorMessage = nil
        } catch {
            errorMessage = "アラームの設定に失敗しました: \(error.localizedDescription)"
            isAlarmActive = false
        }
    }

    func cancelAlarm() async {
        guard let alarmID = currentAlarmID else { return }

        do {
            try await alarmManager.stop(id: alarmID)
            currentAlarmID = nil
            isAlarmActive = false
            errorMessage = nil
        } catch {
            errorMessage = "アラームのキャンセルに失敗しました: \(error.localizedDescription)"
        }
    }
}
