//
//  FlightAlarmData.swift
//  Bell
//
//  Created by 遠藤拓弥 on 2025/11/22.
//

import Foundation
import AlarmKit
import SwiftUI

nonisolated struct FlightAlarmMetadata: AlarmMetadata {
    let flightNumber: String
    let destination: String
    let departureDate: Date
}
