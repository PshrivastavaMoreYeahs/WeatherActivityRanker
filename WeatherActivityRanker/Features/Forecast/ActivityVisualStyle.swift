////
//  ActivityVisualStyle.swift
//  WeatherActivityRanker
//
//  Created by Prashant Shrivastava on 10/09/26.
//

import SwiftUI

extension ActivityType {
    var symbolName: String {
        switch self {
        case .skiing:
            return "mountain.2.fill"
        case .surfing:
            return "water.waves"
        case .outdoorSightseeing:
            return "sun.max.fill"
        case .indoorSightseeing:
            return "building.columns.fill"
        }
    }
}

extension SuitabilityRating {
    var foregroundColor: Color {
        switch self {
        case .poor:
            return .red
        case .fair:
            return .orange
        case .good:
            return .green
        case .excellent:
            return .blue
        }
    }

    var backgroundColor: Color {
        foregroundColor.opacity(0.16)
    }
}
