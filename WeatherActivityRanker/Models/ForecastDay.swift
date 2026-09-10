////
//  ForecastDay.swift
//  WeatherActivityRanker
//
//  Created by Prashant Shrivastava on 09/09/26.
//

import Foundation

nonisolated struct ForecastDay: Identifiable, Equatable, Sendable {
    var id: Date { date }

    let date: Date
    let weatherCode: Int
    let temperatureMinimum: Double
    let temperatureMaximum: Double
    let apparentTemperatureMaximum: Double?
    let precipitationProbabilityMaximum: Int?
    let precipitationSum: Double?
    let snowfallSum: Double?
    let windSpeedMaximum: Double?
    let windGustsMaximum: Double?
    let windDirectionDominant: Int?
    let uvIndexMaximum: Double?

    var temperatureRangeText: String {
        "\(String(format: "%.0f", temperatureMinimum))-\(String(format: "%.0f", temperatureMaximum)) C"
    }
}
