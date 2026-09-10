////
//  RankedForecastDay.swift
//  WeatherActivityRanker
//
//  Created by Prashant Shrivastava on 09/09/26.
//

import Foundation

nonisolated struct RankedForecastDay: Identifiable, Equatable, Sendable {
    var id: Date { forecastDay.id }

    let forecastDay: ForecastDay
    let activitySuitabilities: [ActivitySuitability]
}
