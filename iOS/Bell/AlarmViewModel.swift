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
import AVFoundation

@Observable
class AlarmViewModel {
    private let alarmManager = AlarmManager.shared
    var currentAlarmID: UUID?
    var isAlarmActive = false
    var errorMessage: String?
    var activity: Activity<FlightAlarmAttributes>?
    var alarms: [AlarmInfo] = []
    var currentVolume: Float = 0.0

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

        // End existing activity first
        if let existingActivity = activity {
            print("既存のLive Activityを終了します")
            await existingActivity.end(nil, dismissalPolicy: .immediate)
            activity = nil
        }

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
            print("=== 3分タイマー設定開始 ===")
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
            title: "3分タイマー終了"
        )

        let presentation = AlarmPresentation(alert: alert)

        let attributes = AlarmAttributes<FlightAlarmMetadata>(
            presentation: presentation,
            tintColor: .orange
        )

        // Use timer for 3 minutes (180 seconds)
        // Remove sound parameter to use system default
        let configuration = AlarmManager.AlarmConfiguration.timer(
            duration: 180,
            attributes: attributes
        )

        do {
            let alarmID = UUID()
            print("3分タイマースケジュール開始: \(alarmID)")

            try await alarmManager.schedule(id: alarmID, configuration: configuration)

            print("タイマー設定成功")
            errorMessage = nil

            // Add to alarms list
            let fireDate = Date().addingTimeInterval(180) // 3 minutes from now
            let alarmInfo = AlarmInfo(
                id: alarmID,
                flightNumber: "3分タイマー",
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

        // End existing activity first
        if let existingActivity = activity {
            print("既存のLive Activityを終了します")
            await existingActivity.end(nil, dismissalPolicy: .immediate)
            activity = nil
        }

        let attributes = FlightAlarmAttributes(
            flightInfo: "3分タイマー"
        )

        let contentState = FlightAlarmAttributes.ContentState(
            flightNumber: "⏱️ タイマー",
            destination: "3分",
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

    func createSoundTestTimer() async {
        // Cancel all existing alarms first
        await cancelAllAlarms()

        // Request authorization
        do {
            print("=== 音テスト開始 ===")
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
            title: "🔊 音テスト！"
        )

        let presentation = AlarmPresentation(alert: alert)

        let attributes = AlarmAttributes<FlightAlarmMetadata>(
            presentation: presentation,
            tintColor: .red
        )

        // Use timer for 5 seconds
        // Remove sound parameter to use system default
        let configuration = AlarmManager.AlarmConfiguration.timer(
            duration: 5,
            attributes: attributes
        )

        do {
            let alarmID = UUID()
            print("音テストタイマースケジュール開始: \(alarmID)")

            try await alarmManager.schedule(id: alarmID, configuration: configuration)

            print("音テスト設定成功 - 10秒後に音が鳴ります")
            errorMessage = nil

            // Add to alarms list
            let fireDate = Date().addingTimeInterval(10)
            let alarmInfo = AlarmInfo(
                id: alarmID,
                flightNumber: "🔊 音テスト",
                destination: "10秒",
                departureDate: fireDate,
                alarmDate: fireDate
            )
            alarms.append(alarmInfo)
        } catch {
            print("音テスト設定エラー: \(error)")
            print("エラー詳細: \(error.localizedDescription)")
            errorMessage = "音テストの設定に失敗しました: \(error.localizedDescription)"
        }
    }

    func checkVolume() {
        let audioSession = AVAudioSession.sharedInstance()
        currentVolume = audioSession.outputVolume
        print("現在の音量: \(Int(currentVolume * 100))%")

        if currentVolume == 0 {
            errorMessage = "⚠️ 音量: 0%\n\n音量ボタン（+）を押して音量を上げてください"
        } else if currentVolume < 0.3 {
            errorMessage = "⚠️ 音量: \(Int(currentVolume * 100))%（低い）\n\n音が聞こえにくい可能性があります"
        } else {
            errorMessage = "✅ 音量: \(Int(currentVolume * 100))%"
        }
    }

    func cancelAllAlarms() async {
        print("=== 全アラームをキャンセル ===")

        // First, get the actual list of alarms from AlarmKit
        let actualAlarms: [Alarm]
        do {
            actualAlarms = try alarmManager.alarms
            print("AlarmKit に実際に存在するアラーム数: \(actualAlarms.count)")
        } catch {
            print("アラーム一覧取得エラー: \(error)")
            actualAlarms = []
        }

        // Get IDs of alarms that actually exist in the system
        let existingIDs = Set(actualAlarms.map { $0.id })

        var canceledCount = 0

        // Cancel all alarms in the list that still exist in the system
        for alarm in alarms {
            if existingIDs.contains(alarm.id) {
                do {
                    try alarmManager.cancel(id: alarm.id)
                    print("アラームキャンセル: \(alarm.flightNumber)")
                    canceledCount += 1
                } catch {
                    print("アラームキャンセル失敗: \(alarm.flightNumber) - \(error)")
                }
            } else {
                print("アラーム \(alarm.flightNumber) は既に終了済み（スキップ）")
            }
        }

        // Clear the list
        alarms.removeAll()

        // End Live Activity
        if let activity = activity {
            await activity.end(nil, dismissalPolicy: .immediate)
            self.activity = nil
            print("Live Activity終了")
        }

        print("全アラームをキャンセル完了")
        if canceledCount > 0 {
            errorMessage = "✅ \(canceledCount)個のアラームをキャンセルしました"
        }
    }
}
