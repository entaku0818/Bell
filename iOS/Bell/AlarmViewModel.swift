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
    var alarms: [AlarmInfo] = []

    struct AlarmInfo: Identifiable {
        let id: UUID
        let flightNumber: String
        let destination: String
        let departureDate: Date
        let alarmDate: Date
    }

    func createAlarm(for flightInfo: ExtractedFlightInfo) async {
        // Request authorization
        do {
            print("=== AlarmKit認証開始 ===")
            let authStatus = try await alarmManager.requestAuthorization()
            print("認証ステータス: \(authStatus)")

            guard authStatus == .authorized else {
                print("認証が許可されていません: \(authStatus)")
                errorMessage = "アラームの権限が許可されていません (ステータス: \(authStatus))"
                return
            }

            print("認証成功")
        } catch {
            print("認証エラー: \(error)")
            print("エラー詳細: \(error.localizedDescription)")
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

        // Use fixed schedule for specific departure time (2 hours before)
        let schedule = Alarm.Schedule.fixed(flightInfo.alarmDate)

        let configuration = AlarmManager.AlarmConfiguration<FlightAlarmMetadata>.alarm(
            schedule: schedule,
            attributes: attributes
        )

        do {
            let alarmID = UUID()
            print("アラームスケジュール開始: \(alarmID)")
            print("出発時刻: \(flightInfo.departureDate)")
            print("カウントダウン時間: \(flightInfo.departureDate.timeIntervalSince(Date())) 秒")

            try await alarmManager.schedule(id: alarmID, configuration: configuration)

            print("アラーム設定成功")
            currentAlarmID = alarmID
            isAlarmActive = true
            errorMessage = nil

            // Add to alarms list
            let alarmInfo = AlarmInfo(
                id: alarmID,
                flightNumber: flightInfo.flightNumber,
                destination: flightInfo.destination,
                departureDate: flightInfo.departureDate,
                alarmDate: flightInfo.alarmDate
            )
            alarms.append(alarmInfo)

            // Start Live Activity
            await startLiveActivity(for: flightInfo)
        } catch {
            print("アラーム設定エラー: \(error)")
            print("エラー詳細: \(error.localizedDescription)")
            errorMessage = "アラームの設定に失敗しました: \(error.localizedDescription)"
            isAlarmActive = false
        }
    }

    private func startLiveActivity(for flightInfo: ExtractedFlightInfo) async {
        print("=== Live Activity開始 ===")

        let attributes = FlightAlarmAttributes(
            flightInfo: "\(flightInfo.flightNumber) \(flightInfo.destination)行き"
        )
        print("attributes: \(attributes)")

        let contentState = FlightAlarmAttributes.ContentState(
            flightNumber: flightInfo.flightNumber,
            destination: flightInfo.destination,
            departureDate: flightInfo.departureDate
        )
        print("contentState: \(contentState)")

        do {
            print("Activity.request開始")
            activity = try Activity.request(
                attributes: attributes,
                content: .init(state: contentState, staleDate: nil)
            )
            print("Live Activity開始成功: \(activity?.id ?? "no id")")
        } catch {
            print("Live Activityエラー: \(error)")
            print("エラー詳細: \(error.localizedDescription)")
            errorMessage = "Live Activityの開始に失敗しました: \(error.localizedDescription)"
        }
    }

    func cancelAlarm() async {
        guard let alarmID = currentAlarmID else { return }

        do {
            try await alarmManager.stop(id: alarmID)
            alarms.removeAll { $0.id == alarmID }
            currentAlarmID = nil
            isAlarmActive = false
            errorMessage = nil

            // End Live Activity
            if let activity = activity {
                await activity.end(nil, dismissalPolicy: .immediate)
            }
            activity = nil
        } catch {
            errorMessage = "アラームのキャンセルに失敗しました: \(error.localizedDescription)"
        }
    }

    func create10MinuteTimer() async {
        // Request authorization
        do {
            print("=== 10分タイマー設定開始 ===")
            let authStatus = try await alarmManager.requestAuthorization()
            print("認証ステータス: \(authStatus)")

            guard authStatus == .authorized else {
                print("認証が許可されていません: \(authStatus)")
                errorMessage = "アラームの権限が許可されていません (ステータス: \(authStatus))"
                return
            }
        } catch {
            print("認証エラー: \(error)")
            errorMessage = "認証に失敗しました: \(error.localizedDescription)"
            return
        }

        // Create alarm presentation
        let alert = AlarmPresentation.Alert(
            title: "10分タイマー終了"
        )

        let presentation = AlarmPresentation(alert: alert)

        let attributes = AlarmAttributes<FlightAlarmMetadata>(
            presentation: presentation,
            tintColor: .orange
        )

        // Use timer for 10 minutes (600 seconds)
        let configuration = AlarmManager.AlarmConfiguration.timer(
            duration: 600,
            attributes: attributes
        )

        do {
            let alarmID = UUID()
            print("10分タイマースケジュール開始: \(alarmID)")

            try await alarmManager.schedule(id: alarmID, configuration: configuration)

            print("タイマー設定成功")
            errorMessage = nil

            // Add to alarms list
            let fireDate = Date().addingTimeInterval(600) // 10 minutes from now
            let alarmInfo = AlarmInfo(
                id: alarmID,
                flightNumber: "10分タイマー",
                destination: "タイマー",
                departureDate: fireDate,
                alarmDate: fireDate
            )
            alarms.append(alarmInfo)

            // Start Live Activity for timer
            await startTimerLiveActivity(fireDate: fireDate)
        } catch {
            print("タイマー設定エラー: \(error)")
            print("エラー詳細: \(error.localizedDescription)")
            errorMessage = "タイマーの設定に失敗しました: \(error.localizedDescription)"
        }
    }

    private func startTimerLiveActivity(fireDate: Date) async {
        print("=== タイマー Live Activity開始 ===")

        let attributes = FlightAlarmAttributes(
            flightInfo: "10分タイマー"
        )

        let contentState = FlightAlarmAttributes.ContentState(
            flightNumber: "⏱️ タイマー",
            destination: "10分",
            departureDate: fireDate
        )

        do {
            print("Timer Activity.request開始")
            activity = try Activity.request(
                attributes: attributes,
                content: .init(state: contentState, staleDate: nil)
            )
            print("タイマー Live Activity開始成功: \(activity?.id ?? "no id")")
        } catch {
            print("タイマー Live Activityエラー: \(error)")
            print("エラー詳細: \(error.localizedDescription)")
            errorMessage = "Live Activityの開始に失敗しました: \(error.localizedDescription)"
        }
    }
}
