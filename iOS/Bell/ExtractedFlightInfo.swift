//
//  ExtractedFlightInfo.swift
//  Bell
//
//  Created by 遠藤拓弥 on 2025/11/22.
//

import Foundation

struct ExtractedFlightInfo {
    let flightNumber: String
    let departureDate: Date
    let destination: String
    let gate: String?

    var alarmDate: Date {
        Calendar.current.date(byAdding: .hour, value: -2, to: departureDate) ?? departureDate
    }
}
