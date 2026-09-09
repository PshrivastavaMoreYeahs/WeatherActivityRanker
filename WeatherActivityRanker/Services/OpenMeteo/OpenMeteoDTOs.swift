////
//  OpenMeteoDTOs.swift
//  WeatherActivityRanker
//
//  Created by Prashant Shrivastava on 09/09/26.
//

import Foundation

struct OpenMeteoGeocodingResponseDTO: Decodable, Equatable {
    let results: [OpenMeteoCityDTO]?
}

struct OpenMeteoCityDTO: Decodable, Equatable {
    let id: Int
    let name: String
    let latitude: Double
    let longitude: Double
    let admin1: String?
    let country: String
    let timezone: String?
}

struct OpenMeteoForecastResponseDTO: Decodable, Equatable {
    let timezone: String
    let daily: OpenMeteoDailyForecastDTO
}

struct OpenMeteoDailyForecastDTO: Decodable, Equatable {
    let time: [String]
    let weatherCode: [Int]
    let temperature2mMaximum: [Double]
    let temperature2mMinimum: [Double]
    let precipitationProbabilityMaximum: [Int?]?
    let precipitationSum: [Double?]?
    let snowfallSum: [Double?]?
    let windSpeed10mMaximum: [Double?]?
    let windDirection10mDominant: [Int?]?
    let uvIndexMaximum: [Double?]?

    enum CodingKeys: String, CodingKey {
        case time
        case weatherCode = "weather_code"
        case temperature2mMaximum = "temperature_2m_max"
        case temperature2mMinimum = "temperature_2m_min"
        case precipitationProbabilityMaximum = "precipitation_probability_max"
        case precipitationSum = "precipitation_sum"
        case snowfallSum = "snowfall_sum"
        case windSpeed10mMaximum = "wind_speed_10m_max"
        case windDirection10mDominant = "wind_direction_10m_dominant"
        case uvIndexMaximum = "uv_index_max"
    }
}
