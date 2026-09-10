////
//  ActivityType.swift
//  WeatherActivityRanker
//
//  Created by Prashant Shrivastava on 09/09/26.
//

import Foundation

nonisolated enum ActivityType: String, CaseIterable, Identifiable, Sendable {
    case skiing
    case surfing
    case outdoorSightseeing
    case indoorSightseeing

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .skiing:
            return "Skiing"
        case .surfing:
            return "Surfing"
        case .outdoorSightseeing:
            return "Outdoor sightseeing"
        case .indoorSightseeing:
            return "Indoor sightseeing"
        }
    }
}
