////
//  OpenMeteoDTOs.swift
//  WeatherActivityRanker
//
//  Created by Prashant Shrivastava on 09/09/26.
//

import Foundation

nonisolated struct OpenMeteoGeocodingResponseDTO: Decodable, Equatable {
    let results: [OpenMeteoCityDTO]?
}

nonisolated struct OpenMeteoCityDTO: Decodable, Equatable {
    let id: Int
    let name: String
    let latitude: Double
    let longitude: Double
    let elevation: Double?
    let admin1: String?
    let countryCode: String
    let country: String
    let timezone: String?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case latitude
        case longitude
        case elevation
        case admin1
        case countryCode = "country_code"
        case country
        case timezone
    }
}

nonisolated struct OpenMeteoForecastResponseDTO: Decodable, Equatable {
    let timezone: String
    let dailyUnits: OpenMeteoDailyUnitsDTO?
    let daily: OpenMeteoDailyForecastDTO

    enum CodingKeys: String, CodingKey {
        case timezone
        case dailyUnits = "daily_units"
        case daily
    }
}

nonisolated struct OpenMeteoDailyForecastDTO: Decodable, Equatable {
    let time: [String]
    let weatherCode: [Int]
    let temperature2mMaximum: [Double]
    let temperature2mMinimum: [Double]
    let apparentTemperature2mMaximum: [Double?]?
    let precipitationProbabilityMaximum: [Int?]?
    let precipitationSum: [Double?]?
    let snowfallSum: [Double?]?
    let windSpeed10mMaximum: [Double?]?
    let windGusts10mMaximum: [Double?]?
    let windDirection10mDominant: [Int?]?
    let uvIndexMaximum: [Double?]?

    enum CodingKeys: String, CodingKey {
        case time
        case weatherCode = "weather_code"
        case temperature2mMaximum = "temperature_2m_max"
        case temperature2mMinimum = "temperature_2m_min"
        case apparentTemperature2mMaximum = "apparent_temperature_max"
        case precipitationProbabilityMaximum = "precipitation_probability_max"
        case precipitationSum = "precipitation_sum"
        case snowfallSum = "snowfall_sum"
        case windSpeed10mMaximum = "wind_speed_10m_max"
        case windGusts10mMaximum = "wind_gusts_10m_max"
        case windDirection10mDominant = "wind_direction_10m_dominant"
        case uvIndexMaximum = "uv_index_max"
    }
}

nonisolated struct OpenMeteoDailyUnitsDTO: Decodable, Equatable {
    let time: String?
    let weatherCode: String?
    let temperature2mMaximum: String?
    let temperature2mMinimum: String?
    let apparentTemperature2mMaximum: String?
    let precipitationProbabilityMaximum: String?
    let precipitationSum: String?
    let snowfallSum: String?
    let windSpeed10mMaximum: String?
    let windGusts10mMaximum: String?
    let windDirection10mDominant: String?
    let uvIndexMaximum: String?

    enum CodingKeys: String, CodingKey {
        case time
        case weatherCode = "weather_code"
        case temperature2mMaximum = "temperature_2m_max"
        case temperature2mMinimum = "temperature_2m_min"
        case apparentTemperature2mMaximum = "apparent_temperature_max"
        case precipitationProbabilityMaximum = "precipitation_probability_max"
        case precipitationSum = "precipitation_sum"
        case snowfallSum = "snowfall_sum"
        case windSpeed10mMaximum = "wind_speed_10m_max"
        case windGusts10mMaximum = "wind_gusts_10m_max"
        case windDirection10mDominant = "wind_direction_10m_dominant"
        case uvIndexMaximum = "uv_index_max"
    }
}
