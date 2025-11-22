//
//  FlightAlarmData.swift
//  Bell
//
//  Created by 遠藤拓弥 on 2025/11/22.
//

import Foundation
import AlarmKit

struct FlightAlarmMetadata: AlarmMetadata {
    let flightNumber: String
    let destination: String
    let departureDate: Date
}

struct FlightAlarmData: AlarmAttributes<FlightAlarmMetadata> {
    var displayText: String {
        "\(metadata.flightNumber) \(metadata.destination)行き"
    }
}
