////
//  Forecast.swift
//  WeatherActivityRanker
//
//  Created by Prashant Shrivastava on 09/09/26.
//

import Foundation

struct Forecast: Equatable, Sendable {
    let city: City
    let timezone: String
    let days: [ForecastDay]
}
