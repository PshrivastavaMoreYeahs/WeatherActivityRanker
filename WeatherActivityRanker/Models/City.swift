////
//  City.swift
//  WeatherActivityRanker
//
//  Created by Prashant Shrivastava on 09/09/26.
//

import Foundation

struct City: Identifiable, Equatable, Sendable {
    let id: Int
    let name: String
    let latitude: Double
    let longitude: Double
    let region: String?
    let countryCode: String
    let country: String
    let timezone: String?

    var displayName: String {
        [name, region, country]
            .compactMap { $0?.nilIfBlank }
            .joined(separator: ", ")
    }
}

private extension String {
    var nilIfBlank: String? {
        let trimmedValue = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedValue.isEmpty ? nil : trimmedValue
    }
}
