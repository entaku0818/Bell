//
//  FlightDateParser.swift
//  Bell
//
//  Created by 遠藤拓弥 on 2025/11/22.
//

import Foundation

class FlightDateParser {
    private let datePatterns = [
        "\\d{4}/\\d{1,2}/\\d{1,2}",
        "\\d{2}[A-Z]{3}",
        "\\d{1,2}月\\d{1,2}日"
    ]

    private let timePatterns = [
        "\\d{1,2}:\\d{2}",
        "\\d{1,2}時\\d{1,2}分"
    ]

    private let monthMap: [String: Int] = [
        "JAN": 1, "FEB": 2, "MAR": 3, "APR": 4,
        "MAY": 5, "JUN": 6, "JUL": 7, "AUG": 8,
        "SEP": 9, "OCT": 10, "NOV": 11, "DEC": 12
    ]

    func parseDate(from text: String) -> Date? {
        guard let dateString = extractDate(from: text),
              let timeString = extractTime(from: text) else {
            return nil
        }

        return combineDateTime(dateString: dateString, timeString: timeString)
    }

    private func extractDate(from text: String) -> String? {
        for pattern in datePatterns {
            if let regex = try? NSRegularExpression(pattern: pattern),
               let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)) {
                return String(text[Range(match.range, in: text)!])
            }
        }
        return nil
    }

    private func extractTime(from text: String) -> String? {
        for pattern in timePatterns {
            if let regex = try? NSRegularExpression(pattern: pattern),
               let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)) {
                return String(text[Range(match.range, in: text)!])
            }
        }
        return nil
    }

    private func combineDateTime(dateString: String, timeString: String) -> Date? {
        var components = DateComponents()

        if dateString.contains("/") {
            let parts = dateString.split(separator: "/").map { String($0) }
            if parts.count == 3 {
                components.year = Int(parts[0])
                components.month = Int(parts[1])
                components.day = Int(parts[2])
            }
        } else if dateString.range(of: "[A-Z]{3}", options: .regularExpression) != nil {
            let day = Int(dateString.prefix(2)) ?? 0
            let monthStr = String(dateString.suffix(3))
            components.day = day
            components.month = monthMap[monthStr]
            components.year = Calendar.current.component(.year, from: Date())
        } else if dateString.contains("月") {
            let parts = dateString.replacingOccurrences(of: "月", with: " ")
                .replacingOccurrences(of: "日", with: "")
                .split(separator: " ")
                .map { String($0) }
            if parts.count == 2 {
                components.month = Int(parts[0])
                components.day = Int(parts[1])
                components.year = Calendar.current.component(.year, from: Date())
            }
        }

        if timeString.contains(":") {
            let parts = timeString.split(separator: ":").map { String($0) }
            if parts.count == 2 {
                components.hour = Int(parts[0])
                components.minute = Int(parts[1])
            }
        } else if timeString.contains("時") {
            let parts = timeString.replacingOccurrences(of: "時", with: " ")
                .replacingOccurrences(of: "分", with: "")
                .split(separator: " ")
                .map { String($0) }
            if parts.count == 2 {
                components.hour = Int(parts[0])
                components.minute = Int(parts[1])
            }
        }

        return Calendar.current.date(from: components)
    }
}
