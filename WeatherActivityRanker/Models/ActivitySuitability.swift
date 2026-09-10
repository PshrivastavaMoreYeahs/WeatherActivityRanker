////
//  ActivitySuitability.swift
//  WeatherActivityRanker
//
//  Created by Prashant Shrivastava on 09/09/26.
//

import Foundation

nonisolated struct ActivitySuitability: Identifiable, Equatable, Sendable {
    var id: ActivityType { activity }

    let activity: ActivityType
    let score: Int
    let rating: SuitabilityRating
    let rationale: String
    let availability: ActivityAvailability
}
