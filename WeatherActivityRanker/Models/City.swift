////
//  City.swift
//  WeatherActivityRanker
//
//  Created by Prashant Shrivastava on 09/09/26.
//

import Foundation

nonisolated struct City: Identifiable, Equatable, Sendable {
    let id: Int
    let name: String
    let latitude: Double
    let longitude: Double
    let elevation: Double?
    let region: String?
    let countryCode: String
    let country: String
    let timezone: String?

    var displayName: String {
        [name, region, country]
            .compactMap { value in
                let trimmedValue = value?.trimmingCharacters(in: .whitespacesAndNewlines)
                return trimmedValue?.isEmpty == false ? trimmedValue : nil
            }
            .joined(separator: ", ")
    }
}
