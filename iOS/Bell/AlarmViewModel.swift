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
    var alarmSession: AlarmSession?
    var isAlarmActive = false
    var errorMessage: String?
    var activity: Activity<FlightAlarmAttributes>?

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

            await startLiveActivity(for: flightInfo)
        } catch {
            errorMessage = "アラームの設定に失敗しました: \(error.localizedDescription)"
            isAlarmActive = false
        }
    }

    private func startLiveActivity(for flightInfo: ExtractedFlightInfo) async {
        let attributes = FlightAlarmAttributes(
            flightInfo: "\(flightInfo.flightNumber) \(flightInfo.destination)"
        )

        let contentState = FlightAlarmAttributes.ContentState(
            flightNumber: flightInfo.flightNumber,
            destination: flightInfo.destination,
            departureDate: flightInfo.departureDate,
            isAlerting: false
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
        guard let session = alarmSession else { return }

        do {
            try await session.cancel()
            alarmSession = nil
            isAlarmActive = false
            errorMessage = nil

            await activity?.end(nil, dismissalPolicy: .immediate)
            activity = nil
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
