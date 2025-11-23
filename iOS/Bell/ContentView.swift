//
//  ContentView.swift
//  Bell
//
//  Created by 遠藤拓弥 on 2025/11/22.
//

import SwiftUI
import PhotosUI

struct ContentView: View {
    @State private var selectedImage: PhotosPickerItem?
    @State private var selectedImageData: Data?
    @State private var flightInfo: ExtractedFlightInfo?
    @State private var isProcessing = false
    @State private var errorMessage: String?
    @State private var alarmViewModel = AlarmViewModel()
    @State private var showEditSheet = false

    private let textRecognition = TextRecognitionService()

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                if let imageData = selectedImageData,
                   let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 300)
                        .cornerRadius(12)
                } else {
                    Image(systemName: "airplane.departure")
                        .font(.system(size: 80))
                        .foregroundStyle(.blue)
                        .padding()
                }

                if isProcessing {
                    ProgressView("読み取り中...")
                        .padding()
                } else if let info = flightInfo {
                    FlightInfoCard(info: info)

                    Button(action: {
                        showEditSheet = true
                    }) {
                        Label("編集", systemImage: "pencil")
                            .font(.headline)
                            .foregroundColor(.blue)
                    }
                    .padding(.horizontal)

                    if alarmViewModel.isAlarmActive {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("アラーム設定済み")
                                .fontWeight(.medium)
                        }
                        .padding()

                        Button(action: {
                            Task {
                                await alarmViewModel.cancelAlarm()
                            }
                        }) {
                            Label("アラームをキャンセル", systemImage: "alarm.slash")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red)
                                .cornerRadius(12)
                        }
                        .padding(.horizontal)
                    } else {
                        Button(action: {
                            Task {
                                await alarmViewModel.createAlarm(for: info)
                            }
                        }) {
                            Label("アラームを設定", systemImage: "alarm")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .cornerRadius(12)
                        }
                        .padding(.horizontal)
                    }
                } else {
                    Text("搭乗券を選択してください")
                        .font(.title2)
                        .fontWeight(.medium)
                }

                if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding()
                }

                if let error = alarmViewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding()
                }

                PhotosPicker(selection: $selectedImage,
                           matching: .images) {
                    Label("写真を選択", systemImage: "photo.on.rectangle")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                .onChange(of: selectedImage) { _, newItem in
                    Task {
                        if let data = try? await newItem?.loadTransferable(type: Data.self) {
                            selectedImageData = data
                            await recognizeImage(data: data)
                        }
                    }
                }
                .padding(.horizontal)

                Button(action: {
                    Task {
                        await alarmViewModel.create10MinuteTimer()
                    }
                }) {
                    Label("3分タイマー", systemImage: "timer")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .cornerRadius(12)
                }
                .padding(.horizontal)

                Button(action: {
                    Task {
                        await alarmViewModel.createSoundTestTimer()
                    }
                }) {
                    Label("音テスト (5秒)", systemImage: "speaker.wave.3.fill")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(12)
                }
                .padding(.horizontal)

                Button(action: {
                    Task {
                        await alarmViewModel.playForcedSound()
                    }
                }) {
                    Label("3秒後に音を鳴らす", systemImage: "speaker.wave.2.fill")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.purple)
                        .cornerRadius(12)
                }
                .padding(.horizontal)

                Button(action: {
                    alarmViewModel.checkVolume()
                }) {
                    Label("音量を確認", systemImage: "speaker.wave.1")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray)
                        .cornerRadius(12)
                }
                .padding(.horizontal)

                Button(action: {
                    alarmViewModel.checkDeviceState()
                }) {
                    Label("デバイス状態を確認", systemImage: "info.circle")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                .padding(.horizontal)

                Button(action: {
                    Task {
                        await alarmViewModel.cancelAllAlarms()
                    }
                }) {
                    Label("全アラームをキャンセル", systemImage: "trash.fill")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(12)
                }
                .padding(.horizontal)

                Spacer()
            }
            .padding()
            .navigationTitle("BoardingBell")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: AlarmListView(alarmViewModel: alarmViewModel)) {
                        Label("アラーム一覧", systemImage: "list.bullet")
                    }
                }
            }
            .sheet(isPresented: $showEditSheet) {
                if let info = flightInfo {
                    FlightInfoEditView(flightInfo: $flightInfo)
                }
            }
        }
    }

    private func recognizeImage(data: Data) async {
        guard let uiImage = UIImage(data: data) else { return }

        isProcessing = true
        errorMessage = nil

        do {
            flightInfo = try await textRecognition.recognizeText(from: uiImage)
            if flightInfo == nil {
                errorMessage = "フライト情報を認識できませんでした"
            }
        } catch {
            errorMessage = "エラー: \(error.localizedDescription)"
        }

        isProcessing = false
    }
}

struct FlightInfoCard: View {
    let info: ExtractedFlightInfo

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "airplane")
                    .foregroundColor(.blue)
                Text("フライト情報")
                    .font(.headline)
            }

            Divider()

            InfoRow(label: "便名", value: info.flightNumber)
            InfoRow(label: "行き先", value: info.destination)
            InfoRow(label: "出発時刻", value: formatDate(info.departureDate))
            InfoRow(label: "アラーム", value: formatDate(info.alarmDate))

            if let gate = info.gate {
                InfoRow(label: "ゲート", value: gate)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal)
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }
}

struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
                .frame(width: 80, alignment: .leading)
            Text(value)
                .fontWeight(.medium)
        }
    }
}

struct FlightInfoEditView: View {
    @Binding var flightInfo: ExtractedFlightInfo?
    @Environment(\.dismiss) var dismiss

    @State private var flightNumber: String = ""
    @State private var destination: String = ""
    @State private var departureDate: Date = Date()

    var body: some View {
        NavigationStack {
            Form {
                Section("フライト情報") {
                    TextField("便名", text: $flightNumber)
                    TextField("行き先", text: $destination)
                }

                Section("出発時刻") {
                    DatePicker("日時", selection: $departureDate)
                }
            }
            .navigationTitle("編集")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        flightInfo = ExtractedFlightInfo(
                            flightNumber: flightNumber,
                            departureDate: departureDate,
                            destination: destination,
                            gate: flightInfo?.gate
                        )
                        dismiss()
                    }
                }
            }
            .onAppear {
                if let info = flightInfo {
                    flightNumber = info.flightNumber
                    destination = info.destination
                    departureDate = info.departureDate
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
