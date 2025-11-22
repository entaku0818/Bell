//
//  BellWidgetBundle.swift
//  BellWidget
//
//  Created by 遠藤拓弥 on 2025/11/22.
//

import WidgetKit
import SwiftUI

@main
struct BellWidgetBundle: WidgetBundle {
    var body: some Widget {
        BellWidget()
        BellWidgetControl()
        BellWidgetLiveActivity()
    }
}
