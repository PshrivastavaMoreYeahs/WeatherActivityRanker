////
//  SuitabilityScoring.swift
//  WeatherActivityRanker
//
//  Created by Prashant Shrivastava on 10/09/26.
//

import Foundation

nonisolated protocol SuitabilityScoring: Sendable {
    func rankedForecast(from forecast: Forecast) -> RankedForecast
}
