//
//  FlightAlarmData.swift
//  Bell
//
//  Created by 遠藤拓弥 on 2025/11/22.
//

import Foundation
import AlarmKit

struct FlightAlarmData: AlarmMetadata {
    let flightNumber: String
    let destination: String
    let departureDate: Date

    var displayText: String {
        "\(flightNumber) \(destination)行き"
    }
}
