////
//  WeatherRepository.swift
//  WeatherActivityRanker
//
//  Created by Prashant Shrivastava on 09/09/26.
//

import Foundation

protocol WeatherRepository: Sendable {
    func searchCities(query: String) async throws -> [City]
    func forecast(for city: City) async throws -> Forecast
}
