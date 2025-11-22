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
    var currentAlarmID: String?
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

        let metadata = FlightAlarmMetadata(
            flightNumber: flightInfo.flightNumber,
            destination: flightInfo.destination,
            departureDate: flightInfo.departureDate
        )

        let attributes = FlightAlarmData(metadata: metadata)

        let countdownDuration = flightInfo.departureDate.timeIntervalSince(Date())

        let configuration = AlarmConfiguration(
            countdownDuration: countdownDuration,
            attributes: attributes
        )

        do {
            let alarmID = UUID().uuidString
            try await alarmManager.schedule(id: alarmID, configuration: configuration)
            currentAlarmID = alarmID
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
        guard let alarmID = currentAlarmID else { return }

        do {
            try await alarmManager.stop(id: alarmID)
            currentAlarmID = nil
            isAlarmActive = false
            errorMessage = nil

            await activity?.end(nil, dismissalPolicy: .immediate)
            activity = nil
        } catch {
            errorMessage = "アラームのキャンセルに失敗しました: \(error.localizedDescription)"
        }
    }
}
