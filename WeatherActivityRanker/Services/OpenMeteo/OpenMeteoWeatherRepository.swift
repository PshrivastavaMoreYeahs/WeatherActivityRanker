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

}
