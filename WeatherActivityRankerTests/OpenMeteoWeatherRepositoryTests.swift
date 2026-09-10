////
//  OpenMeteoWeatherRepositoryTests.swift
//  WeatherActivityRankerTests
//
//  Created by Prashant Shrivastava on 09/09/26.
//

import Foundation
import XCTest
@testable import WeatherActivityRanker

final class OpenMeteoWeatherRepositoryTests: XCTestCase {
    func testSearchCities_buildsGeocodingRequestAndMapsCities() async throws {
        let httpClient = MockHTTPClient(
            result: .success(
                (
                    makeHTTPResponse(statusCode: 200),
                    """
                    {
                      "results": [
                        {
                          "id": 2643743,
                          "name": "London",
                          "latitude": 51.5085,
                          "longitude": -0.1257,
                          "admin1": "England",
                          "country_code": "GB",
                          "country": "United Kingdom",
                          "timezone": "Europe/London"
                        }
                      ]
                    }
                    """.data(using: .utf8)!
                )
            )
        )
        let repository = OpenMeteoWeatherRepository(httpClient: httpClient)

        let cities = try await repository.searchCities(query: " London ")

        XCTAssertEqual(cities.first?.displayName, "London, England, United Kingdom")
        XCTAssertEqual(cities.first?.countryCode, "GB")
        XCTAssertEqual(httpClient.lastRequest?.url?.host, "geocoding-api.open-meteo.com")
        XCTAssertEqual(httpClient.lastRequest?.url?.path, "/v1/search")
        XCTAssertEqual(queryValue("name", in: httpClient.lastRequest), "London")
        XCTAssertEqual(queryValue("count", in: httpClient.lastRequest), "5")
    }

    func testForecast_buildsForecastRequestAndMapsForecast() async throws {
        let httpClient = MockHTTPClient(
            result: .success(
                (
                    makeHTTPResponse(statusCode: 200),
                    """
                    {
                      "timezone": "Europe/London",
                      "daily": {
                        "time": ["2026-09-09"],
                        "weather_code": [1],
                        "temperature_2m_max": [22.4],
                        "temperature_2m_min": [14.1],
                        "apparent_temperature_max": [24.0],
                        "precipitation_probability_max": [10],
                        "precipitation_sum": [0.0],
                        "snowfall_sum": [0.0],
                        "wind_speed_10m_max": [12.0],
                        "wind_gusts_10m_max": [20.0],
                        "wind_direction_10m_dominant": [180],
                        "uv_index_max": [5.2]
                      }
                    }
                    """.data(using: .utf8)!
                )
            )
        )
        let repository = OpenMeteoWeatherRepository(httpClient: httpClient)

        let forecast = try await repository.forecast(for: makeCity())

        XCTAssertEqual(forecast.days.count, 1)
        XCTAssertEqual(forecast.days[0].apparentTemperatureMaximum, 24.0)
        XCTAssertEqual(forecast.days[0].windGustsMaximum, 20.0)
        XCTAssertEqual(httpClient.lastRequest?.url?.host, "api.open-meteo.com")
        XCTAssertEqual(httpClient.lastRequest?.url?.path, "/v1/forecast")
        XCTAssertEqual(queryValue("forecast_days", in: httpClient.lastRequest), "7")
        XCTAssertEqual(queryValue("timezone", in: httpClient.lastRequest), "auto")
        XCTAssertTrue(queryValue("daily", in: httpClient.lastRequest)?.contains("wind_gusts_10m_max") == true)
    }

    func testSearchCities_throwsForShortQueryBeforeNetworkRequest() async {
        let httpClient = MockHTTPClient(result: .failure(TestError.unexpectedRequest))
        let repository = OpenMeteoWeatherRepository(httpClient: httpClient)

        await XCTAssertThrowsErrorAsync(try await repository.searchCities(query: "L")) { error in
            XCTAssertEqual(error as? OpenMeteoRepositoryError, .emptyQuery)
        }
        XCTAssertNil(httpClient.lastRequest)
    }

    func testSearchCities_throwsEmptySearchResultsWhenResponseHasNoResults() async {
        let httpClient = MockHTTPClient(
            result: .success((makeHTTPResponse(statusCode: 200), #"{"results":[]}"#.data(using: .utf8)!))
        )
        let repository = OpenMeteoWeatherRepository(httpClient: httpClient)

        await XCTAssertThrowsErrorAsync(try await repository.searchCities(query: "Atlantis")) { error in
            XCTAssertEqual(error as? OpenMeteoRepositoryError, .emptySearchResults)
        }
    }

    func testRequest_throwsHTTPErrorForNonSuccessStatusCode() async {
        let httpClient = MockHTTPClient(
            result: .success((makeHTTPResponse(statusCode: 500), Data()))
        )
        let repository = OpenMeteoWeatherRepository(httpClient: httpClient)

        await XCTAssertThrowsErrorAsync(try await repository.searchCities(query: "London")) { error in
            XCTAssertEqual(error as? OpenMeteoRepositoryError, .httpError(statusCode: 500))
        }
    }

    func testRequest_throwsDecodingFailedForInvalidJSON() async {
        let httpClient = MockHTTPClient(
            result: .success((makeHTTPResponse(statusCode: 200), Data("not-json".utf8)))
        )
        let repository = OpenMeteoWeatherRepository(httpClient: httpClient)

        await XCTAssertThrowsErrorAsync(try await repository.searchCities(query: "London")) { error in
            guard case .decodingFailed = error as? OpenMeteoRepositoryError else {
                return XCTFail("Expected decodingFailed, got \(error)")
            }
        }
    }

    private func makeCity() -> City {
        City(
            id: 2643743,
            name: "London",
            latitude: 51.5085,
            longitude: -0.1257,
            region: "England",
            countryCode: "GB",
            country: "United Kingdom",
            timezone: "Europe/London"
        )
    }

    private func queryValue(_ name: String, in request: URLRequest?) -> String? {
        guard let url = request?.url,
              let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return nil
        }

        return components.queryItems?.first { $0.name == name }?.value
    }

    private func makeHTTPResponse(statusCode: Int) -> HTTPURLResponse {
        HTTPURLResponse(
            url: URL(string: "https://example.com")!,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: nil
        )!
    }
}

private final class MockHTTPClient: HTTPClient {
    private let result: Result<(HTTPURLResponse, Data), Error>
    private(set) var lastRequest: URLRequest?

    init(result: Result<(HTTPURLResponse, Data), Error>) {
        self.result = result
    }

    func data(for request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        lastRequest = request

        switch result {
        case let .success((response, data)):
            return (data, response)
        case let .failure(error):
            throw error
        }
    }
}

private enum TestError: Error {
    case unexpectedRequest
}

private func XCTAssertThrowsErrorAsync(
    _ expression: @autoclosure () async throws -> some Any,
    _ errorHandler: (Error) -> Void,
    file: StaticString = #filePath,
    line: UInt = #line
) async {
    do {
        _ = try await expression()
        XCTFail("Expected expression to throw", file: file, line: line)
    } catch {
        errorHandler(error)
    }
}
