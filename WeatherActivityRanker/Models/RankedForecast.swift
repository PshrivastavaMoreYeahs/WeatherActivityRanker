////
//  RankedForecast.swift
//  WeatherActivityRanker
//
//  Created by Prashant Shrivastava on 10/09/26.
//

import Foundation

nonisolated struct RankedForecast: Equatable, Sendable {
    let city: City
    let timezone: String
    let days: [RankedForecastDay]
}
