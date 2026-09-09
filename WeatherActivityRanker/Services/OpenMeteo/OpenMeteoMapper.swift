////
//  OpenMeteoMapper.swift
//  WeatherActivityRanker
//
//  Created by Prashant Shrivastava on 09/09/26.
//

import Foundation

final class OpenMeteoMapper {
    func mapCities(from response: OpenMeteoGeocodingResponseDTO) -> [City] {
        response.results?.map { dto in
            City(
                id: dto.id,
                name: dto.name,
                latitude: dto.latitude,
                longitude: dto.longitude,
                region: dto.admin1,
                countryCode: dto.countryCode,
                country: dto.country,
                timezone: dto.timezone
            )
        } ?? []
    }

    func mapForecast(from response: OpenMeteoForecastResponseDTO, city: City) throws -> Forecast {
        let daily = response.daily
        let expectedCount = daily.time.count

        try validateRequiredArray(daily.weatherCode, named: "weather_code", expectedCount: expectedCount)
        try validateRequiredArray(daily.temperature2mMaximum, named: "temperature_2m_max", expectedCount: expectedCount)
        try validateRequiredArray(daily.temperature2mMinimum, named: "temperature_2m_min", expectedCount: expectedCount)
        try validateOptionalArray(daily.apparentTemperature2mMaximum, named: "apparent_temperature_max", expectedCount: expectedCount)
        try validateOptionalArray(daily.precipitationProbabilityMaximum, named: "precipitation_probability_max", expectedCount: expectedCount)
        try validateOptionalArray(daily.precipitationSum, named: "precipitation_sum", expectedCount: expectedCount)
        try validateOptionalArray(daily.snowfallSum, named: "snowfall_sum", expectedCount: expectedCount)
        try validateOptionalArray(daily.windSpeed10mMaximum, named: "wind_speed_10m_max", expectedCount: expectedCount)
        try validateOptionalArray(daily.windGusts10mMaximum, named: "wind_gusts_10m_max", expectedCount: expectedCount)
        try validateOptionalArray(daily.windDirection10mDominant, named: "wind_direction_10m_dominant", expectedCount: expectedCount)
        try validateOptionalArray(daily.uvIndexMaximum, named: "uv_index_max", expectedCount: expectedCount)

        let days = try daily.time.indices.map { index in
            ForecastDay(
                date: try mapDate(from: daily.time[index]),
                weatherCode: daily.weatherCode[index],
                temperatureMinimum: daily.temperature2mMinimum[index],
                temperatureMaximum: daily.temperature2mMaximum[index],
                apparentTemperatureMaximum: daily.apparentTemperature2mMaximum?[index],
                precipitationProbabilityMaximum: daily.precipitationProbabilityMaximum?[index],
                precipitationSum: daily.precipitationSum?[index],
                snowfallSum: daily.snowfallSum?[index],
                windSpeedMaximum: daily.windSpeed10mMaximum?[index],
                windGustsMaximum: daily.windGusts10mMaximum?[index],
                windDirectionDominant: daily.windDirection10mDominant?[index],
                uvIndexMaximum: daily.uvIndexMaximum?[index]
            )
        }

        return Forecast(city: city, timezone: response.timezone, days: days)
    }

    private func validateRequiredArray<T>(_ values: [T], named fieldName: String, expectedCount: Int) throws {
        guard values.count == expectedCount else {
            throw OpenMeteoMappingError.mismatchedDailyArrayLength(
                fieldName: fieldName,
                expectedCount: expectedCount,
                actualCount: values.count
            )
        }
    }

    private func validateOptionalArray<T>(_ values: [T]?, named fieldName: String, expectedCount: Int) throws {
        guard let values else { return }

        try validateRequiredArray(values, named: fieldName, expectedCount: expectedCount)
    }

    private func mapDate(from value: String) throws -> Date {
        let components = value.split(separator: "-")

        guard components.count == 3,
              let year = Int(components[0]),
              let month = Int(components[1]),
              let day = Int(components[2]) else {
            throw OpenMeteoMappingError.invalidDailyDate(value)
        }

        var dateComponents = DateComponents()
        dateComponents.calendar = Calendar(identifier: .gregorian)
        dateComponents.timeZone = TimeZone(secondsFromGMT: 0)
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = day

        guard dateComponents.isValidDate,
              let date = dateComponents.date else {
            throw OpenMeteoMappingError.invalidDailyDate(value)
        }

        return date
    }
}

enum OpenMeteoMappingError: Error, Equatable {
    case invalidDailyDate(String)
    case mismatchedDailyArrayLength(fieldName: String, expectedCount: Int, actualCount: Int)
}
