//
//  TextRecognitionService.swift
//  Bell
//
//  Created by 遠藤拓弥 on 2025/11/22.
//

import Vision
import UIKit

class TextRecognitionService {
    private let flightPattern = "[A-Z]{2,3}\\s?\\d{1,4}"
    private let dateParser = FlightDateParser()

    func recognizeText(from image: UIImage) async throws -> ExtractedFlightInfo? {
        guard let cgImage = image.cgImage else {
            return nil
        }

        let request = VNRecognizeTextRequest()
        request.recognitionLevel = .accurate
        request.recognitionLanguages = ["en-US", "ja-JP"]

        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        try handler.perform([request])

        guard let observations = request.results else {
            return nil
        }

        let recognizedText = observations.compactMap { $0.topCandidates(1).first?.string }.joined(separator: " ")

        print("=== 認識したテキスト ===")
        print(recognizedText)
        print("=====================")

        return extractFlightInfo(from: recognizedText)
    }

    private func extractFlightInfo(from text: String) -> ExtractedFlightInfo? {
        let flightNumber = extractFlightNumber(from: text)
        let destination = extractDestination(from: text)
        let gate = extractGate(from: text)

        guard let departureDate = dateParser.parseDate(from: text) else {
            return nil
        }

        return ExtractedFlightInfo(
            flightNumber: flightNumber ?? "Unknown",
            departureDate: departureDate,
            destination: destination ?? "Unknown",
            gate: gate
        )
    }

    private func extractFlightNumber(from text: String) -> String? {
        guard let regex = try? NSRegularExpression(pattern: flightPattern),
              let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)) else {
            return nil
        }
        return String(text[Range(match.range, in: text)!])
    }

    private func extractDestination(from text: String) -> String? {
        let airports = ["TOKYO", "HND", "NRT", "OSAKA", "KIX", "ITM", "FUKUOKA", "FUK",
                       "羽田", "成田", "大阪", "関西", "福岡"]

        for airport in airports {
            if text.uppercased().contains(airport) {
                return airport
            }
        }
        return nil
    }

    private func extractGate(from text: String) -> String? {
        let gatePattern = "GATE\\s?\\d{1,3}|ゲート\\s?\\d{1,3}"
        guard let regex = try? NSRegularExpression(pattern: gatePattern, options: .caseInsensitive),
              let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)) else {
            return nil
        }
        return String(text[Range(match.range, in: text)!])
    }
}
