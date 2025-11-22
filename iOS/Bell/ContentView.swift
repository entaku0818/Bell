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

                Spacer()
            }
            .padding()
            .navigationTitle("BoardingBell")
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

#Preview {
    ContentView()
}
