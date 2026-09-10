////
//  OpenMeteoRepositoryError.swift
//  WeatherActivityRanker
//
//  Created by Prashant Shrivastava on 09/09/26.
//

import Foundation

nonisolated enum OpenMeteoRepositoryError: LocalizedError, Equatable {
    case emptyQuery
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingFailed(String)
    case mappingFailed(OpenMeteoMappingError)
    case networkFailed(String)
    case emptySearchResults

    var errorDescription: String? {
        switch self {
        case .emptyQuery:
            return "Enter at least two characters to search for a city or town."
        case .invalidURL:
            return "The weather request could not be created."
        case .invalidResponse:
            return "The weather service returned an invalid response."
        case let .httpError(statusCode):
            return "The weather service returned an error. Status code: \(statusCode)."
        case .decodingFailed:
            return "The weather response could not be read."
        case let .mappingFailed(error):
            return "The weather response was incomplete or inconsistent. \(String(describing: error))"
        case .networkFailed:
            return "The weather service could not be reached. Check your connection and try again."
        case .emptySearchResults:
            return "No matching cities or towns were found."
        }
    }
}
