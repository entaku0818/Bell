//
//  FlightAlarmAttributes.swift
//  Bell
//
//  Created by 遠藤拓弥 on 2025/11/22.
//

import ActivityKit
import Foundation

struct FlightAlarmAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var flightNumber: String
        var destination: String
        var departureDate: Date
    }

    var flightInfo: String
}
