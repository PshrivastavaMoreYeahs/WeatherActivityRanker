////
//  OpenMeteoEndpoint.swift
//  WeatherActivityRanker
//
//  Created by Prashant Shrivastava on 09/09/26.
//

import Foundation

nonisolated enum OpenMeteoEndpoint {
    case geocoding(query: String)
    case forecast(latitude: Double, longitude: Double)

    var url: URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = host
        components.path = path
        components.queryItems = queryItems
        return components.url
    }

    private var host: String {
        switch self {
        case .geocoding:
            return "geocoding-api.open-meteo.com"
        case .forecast:
            return "api.open-meteo.com"
        }
    }

    private var path: String {
        switch self {
        case .geocoding:
            return "/v1/search"
        case .forecast:
            return "/v1/forecast"
        }
    }

    private var queryItems: [URLQueryItem] {
        switch self {
        case let .geocoding(query):
            return [
                URLQueryItem(name: "name", value: query),
                URLQueryItem(name: "count", value: "5"),
                URLQueryItem(name: "language", value: "en"),
                URLQueryItem(name: "format", value: "json")
            ]

        case let .forecast(latitude, longitude):
            return [
                URLQueryItem(name: "latitude", value: String(latitude)),
                URLQueryItem(name: "longitude", value: String(longitude)),
                URLQueryItem(name: "daily", value: dailyForecastFields.joined(separator: ",")),
                URLQueryItem(name: "forecast_days", value: "7"),
                URLQueryItem(name: "timezone", value: "auto"),
                URLQueryItem(name: "temperature_unit", value: "celsius"),
                URLQueryItem(name: "wind_speed_unit", value: "kmh"),
                URLQueryItem(name: "precipitation_unit", value: "mm")
            ]
        }
    }

    private var dailyForecastFields: [String] {
        [
            "weather_code",
            "temperature_2m_max",
            "temperature_2m_min",
            "apparent_temperature_max",
            "precipitation_probability_max",
            "precipitation_sum",
            "snowfall_sum",
            "wind_speed_10m_max",
            "wind_gusts_10m_max",
            "wind_direction_10m_dominant",
            "uv_index_max"
        ]
    }
}
