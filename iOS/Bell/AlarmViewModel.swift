//
//  AlarmViewModel.swift
//  Bell
//
//  Created by 遠藤拓弥 on 2025/11/22.
//

import Foundation
import AlarmKit
import SwiftUI
import ActivityKit

@Observable
class AlarmViewModel {
    private let alarmManager = AlarmManager.shared
    var currentAlarmID: UUID?
    var isAlarmActive = false
    var errorMessage: String?
    var activity: Activity<FlightAlarmAttributes>?

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

            // Start Live Activity
            await startLiveActivity(for: flightInfo)
        } catch {
            errorMessage = "アラームの設定に失敗しました: \(error.localizedDescription)"
            isAlarmActive = false
        }
    }

    private func startLiveActivity(for flightInfo: ExtractedFlightInfo) async {
        let attributes = FlightAlarmAttributes(
            flightInfo: "\(flightInfo.flightNumber) \(flightInfo.destination)行き"
        )

        let contentState = FlightAlarmAttributes.ContentState(
            flightNumber: flightInfo.flightNumber,
            destination: flightInfo.destination,
            departureDate: flightInfo.departureDate
        )

        do {
            activity = try Activity.request(
                attributes: attributes,
                content: .init(state: contentState, staleDate: nil)
            )
        } catch {
            errorMessage = "Live Activityの開始に失敗しました: \(error.localizedDescription)"
        }
    }

    func cancelAlarm() async {
        guard let alarmID = currentAlarmID else { return }

        do {
            try await alarmManager.stop(id: alarmID)
            currentAlarmID = nil
            isAlarmActive = false
            errorMessage = nil

            // End Live Activity
            await activity?.end(nil, dismissalPolicy: .immediate)
            activity = nil
        } catch {
            errorMessage = "アラームのキャンセルに失敗しました: \(error.localizedDescription)"
        }
    }
}
