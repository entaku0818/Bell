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

                Text("搭乗券を選択してください")
                    .font(.title2)
                    .fontWeight(.medium)

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
}

#Preview {
    ContentView()
}
