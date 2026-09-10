////
//  OpenMeteoWeatherRepository.swift
//  WeatherActivityRanker
//
//  Created by Prashant Shrivastava on 09/09/26.
//

import Foundation

nonisolated final class OpenMeteoWeatherRepository: WeatherRepository {
    private let httpClient: HTTPClient
    private let decoder: JSONDecoder
    private let mapper: OpenMeteoMapper

    init(
        httpClient: HTTPClient = URLSessionHTTPClient(),
        decoder: JSONDecoder = JSONDecoder(),
        mapper: OpenMeteoMapper = OpenMeteoMapper()
    ) {
        self.httpClient = httpClient
        self.decoder = decoder
        self.mapper = mapper
    }

    func searchCities(query: String) async throws -> [City] {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)

        guard trimmedQuery.count >= 2 else {
            throw OpenMeteoRepositoryError.emptyQuery
        }

        let response: OpenMeteoGeocodingResponseDTO = try await request(
            OpenMeteoEndpoint.geocoding(query: trimmedQuery)
        )

        let cities = mapper.mapCities(from: response)

        guard cities.isEmpty == false else {
            throw OpenMeteoRepositoryError.emptySearchResults
        }

        return cities
    }

    func forecast(for city: City) async throws -> Forecast {
        let response: OpenMeteoForecastResponseDTO = try await request(
            OpenMeteoEndpoint.forecast(latitude: city.latitude, longitude: city.longitude)
        )

        do {
            return try mapper.mapForecast(from: response, city: city)
        } catch let error as OpenMeteoMappingError {
            throw OpenMeteoRepositoryError.mappingFailed(error)
        } catch {
            throw OpenMeteoRepositoryError.mappingFailed(.unexpected(error.localizedDescription))
        }
    }

    func activityAvailability(for city: City) async -> ActivityAvailabilitySet {
        async let surfing = surfingAvailability(for: city)

        return await ActivityAvailabilitySet(
            skiing: skiingAvailability(for: city),
            surfing: surfing,
            outdoorSightseeing: .available,
            indoorSightseeing: .available
        )
    }

    private func request<Response: Decodable>(_ endpoint: OpenMeteoEndpoint) async throws -> Response {
        guard let url = endpoint.url else {
            throw OpenMeteoRepositoryError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 20
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let data: Data
        let response: HTTPURLResponse

        do {
            (data, response) = try await httpClient.data(for: request)
        } catch HTTPClientError.invalidResponse {
            throw OpenMeteoRepositoryError.invalidResponse
        } catch let error as OpenMeteoRepositoryError {
            throw error
        } catch {
            throw OpenMeteoRepositoryError.networkFailed(error.localizedDescription)
        }

        guard (200...299).contains(response.statusCode) else {
            throw OpenMeteoRepositoryError.httpError(statusCode: response.statusCode)
        }

        do {
            return try decoder.decode(Response.self, from: data)
        } catch {
            throw OpenMeteoRepositoryError.decodingFailed(error.localizedDescription)
        }
    }

    private func skiingAvailability(for city: City) -> ActivityAvailability {
        guard let elevation = city.elevation else {
            return .available
        }

        guard elevation >= 800 else {
            return .unavailable(reason: "No mountain terrain indicated near this city.")
        }

        return .available
    }

    private func surfingAvailability(for city: City) async -> ActivityAvailability {
        do {
            let marineResponse: OpenMeteoMarineResponseDTO = try await request(
                OpenMeteoEndpoint.marine(latitude: city.latitude, longitude: city.longitude)
            )
            let distanceToSea = GeoDistance.kilometersBetween(
                latitude: city.latitude,
                longitude: city.longitude,
                andLatitude: marineResponse.latitude,
                longitude: marineResponse.longitude
            )

            guard distanceToSea <= 75 else {
                return .unavailable(reason: "No sea or ocean within roughly 75 km of this location.")
            }

            return .available
        } catch {
            return .available
        }
    }
}
