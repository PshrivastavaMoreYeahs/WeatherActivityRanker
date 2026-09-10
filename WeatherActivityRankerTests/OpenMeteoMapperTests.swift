////
//  OpenMeteoMapperTests.swift
//  WeatherActivityRankerTests
//
//  Created by Prashant Shrivastava on 09/09/26.
//

import XCTest
@testable import WeatherActivityRanker

final class OpenMeteoMapperTests: XCTestCase {
    private let mapper = OpenMeteoMapper()

    func testMapCities_mapsGeocodingResultsToCities() {
        let response = OpenMeteoGeocodingResponseDTO(
            results: [
                OpenMeteoCityDTO(
                    id: 2643743,
                    name: "London",
                    latitude: 51.5085,
                    longitude: -0.1257,
                    elevation: 25,
                    admin1: "England",
                    countryCode: "GB",
                    country: "United Kingdom",
                    timezone: "Europe/London"
                )
            ]
        )

        let cities = mapper.mapCities(from: response)

        XCTAssertEqual(cities.count, 1)
        XCTAssertEqual(cities.first?.displayName, "London, England, United Kingdom")
        XCTAssertEqual(cities.first?.countryCode, "GB")
        XCTAssertEqual(cities.first?.elevation, 25)
    }

    func testMapForecast_mapsDailyParallelArraysToForecastDays() throws {
        let city = makeCity()
        let response = OpenMeteoForecastResponseDTO(
            timezone: "Europe/London",
            dailyUnits: nil,
            daily: OpenMeteoDailyForecastDTO(
                time: ["2026-09-09", "2026-09-10"],
                weatherCode: [1, 61],
                temperature2mMaximum: [22.4, 18.8],
                temperature2mMinimum: [14.1, 12.0],
                apparentTemperature2mMaximum: [24.0, 17.5],
                precipitationProbabilityMaximum: [10, 70],
                precipitationSum: [0.0, 8.1],
                snowfallSum: [0.0, 0.0],
                windSpeed10mMaximum: [12.0, 28.5],
                windGusts10mMaximum: [20.0, 45.0],
                windDirection10mDominant: [180, 220],
                uvIndexMaximum: [5.2, 2.1]
            )
        )

        let forecast = try mapper.mapForecast(from: response, city: city)

        XCTAssertEqual(forecast.city, city)
        XCTAssertEqual(forecast.timezone, "Europe/London")
        XCTAssertEqual(forecast.days.count, 2)
        XCTAssertEqual(forecast.days[0].weatherCode, 1)
        XCTAssertEqual(forecast.days[0].temperatureMaximum, 22.4)
        XCTAssertEqual(forecast.days[0].apparentTemperatureMaximum, 24.0)
        XCTAssertEqual(forecast.days[1].windGustsMaximum, 45.0)
    }

    func testMapForecast_throwsWhenDailyArrayLengthsDoNotMatchTime() {
        let response = OpenMeteoForecastResponseDTO(
            timezone: "Europe/London",
            dailyUnits: nil,
            daily: OpenMeteoDailyForecastDTO(
                time: ["2026-09-09", "2026-09-10"],
                weatherCode: [1],
                temperature2mMaximum: [22.4, 18.8],
                temperature2mMinimum: [14.1, 12.0],
                apparentTemperature2mMaximum: nil,
                precipitationProbabilityMaximum: nil,
                precipitationSum: nil,
                snowfallSum: nil,
                windSpeed10mMaximum: nil,
                windGusts10mMaximum: nil,
                windDirection10mDominant: nil,
                uvIndexMaximum: nil
            )
        )

        XCTAssertThrowsError(try mapper.mapForecast(from: response, city: makeCity())) { error in
            XCTAssertEqual(
                error as? OpenMeteoMappingError,
                .mismatchedDailyArrayLength(fieldName: "weather_code", expectedCount: 2, actualCount: 1)
            )
        }
    }

    func testMapForecast_throwsWhenDateIsInvalid() {
        let response = OpenMeteoForecastResponseDTO(
            timezone: "Europe/London",
            dailyUnits: nil,
            daily: OpenMeteoDailyForecastDTO(
                time: ["invalid-date"],
                weatherCode: [1],
                temperature2mMaximum: [22.4],
                temperature2mMinimum: [14.1],
                apparentTemperature2mMaximum: nil,
                precipitationProbabilityMaximum: nil,
                precipitationSum: nil,
                snowfallSum: nil,
                windSpeed10mMaximum: nil,
                windGusts10mMaximum: nil,
                windDirection10mDominant: nil,
                uvIndexMaximum: nil
            )
        )

        XCTAssertThrowsError(try mapper.mapForecast(from: response, city: makeCity())) { error in
            XCTAssertEqual(error as? OpenMeteoMappingError, .invalidDailyDate("invalid-date"))
        }
    }

    private func makeCity() -> City {
        City(
            id: 2643743,
            name: "London",
            latitude: 51.5085,
            longitude: -0.1257,
            elevation: 25,
            region: "England",
            countryCode: "GB",
            country: "United Kingdom",
            timezone: "Europe/London"
        )
    }
}
