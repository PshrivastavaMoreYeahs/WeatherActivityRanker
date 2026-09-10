////
//  SearchViewModel.swift
//  WeatherActivityRanker
//
//  Created by Prashant Shrivastava on 10/09/26.
//

import Combine
import Foundation

@MainActor
final class SearchViewModel: ObservableObject {
    @Published var query = "" {
        didSet {
            scheduleSearch()
        }
    }
    @Published private(set) var searchState: LoadingState<[City]> = .idle
    @Published private(set) var forecastState: LoadingState<RankedForecast> = .idle
    @Published var isShowingForecast = false

    private let weatherRepository: any WeatherRepository
    private let suitabilityScorer: any SuitabilityScoring
    private var searchTask: Task<Void, Never>?
    private var selectedCity: City?

    convenience init() {
        self.init(
            weatherRepository: OpenMeteoWeatherRepository(),
            suitabilityScorer: SuitabilityScorer()
        )
    }

    init(
        weatherRepository: any WeatherRepository,
        suitabilityScorer: any SuitabilityScoring
    ) {
        self.weatherRepository = weatherRepository
        self.suitabilityScorer = suitabilityScorer
    }

    var rankedForecast: RankedForecast? {
        guard case let .loaded(forecast) = forecastState else {
            return nil
        }

        return forecast
    }

    func selectCity(_ city: City) {
        selectedCity = city
        forecastState = .loading

        Task {
            do {
                async let forecast = weatherRepository.forecast(for: city)
                async let availability = weatherRepository.activityAvailability(for: city)
                let loadedForecast = try await forecast
                let loadedAvailability = await availability
                let rankedForecast = suitabilityScorer.rankedForecast(
                    from: loadedForecast,
                    availability: loadedAvailability
                )
                forecastState = .loaded(rankedForecast)
                isShowingForecast = true
            } catch {
                forecastState = .failed(error)
            }
        }
    }

    func retryForecast() {
        guard case .failed = forecastState,
              let selectedCity else {
            return
        }

        selectCity(selectedCity)
    }

    private func scheduleSearch() {
        searchTask?.cancel()

        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)

        guard trimmedQuery.count >= 2 else {
            searchState = trimmedQuery.isEmpty ? .idle : .empty
            forecastState = .idle
            isShowingForecast = false
            return
        }

        searchState = .loading

        searchTask = Task {
            do {
                try await Task.sleep(nanoseconds: 350_000_000)
                try Task.checkCancellation()

                let cities = try await weatherRepository.searchCities(query: trimmedQuery)
                try Task.checkCancellation()

                guard trimmedQuery == query.trimmingCharacters(in: .whitespacesAndNewlines) else {
                    return
                }

                searchState = cities.isEmpty ? .empty : .loaded(cities)
            } catch is CancellationError {
                return
            } catch OpenMeteoRepositoryError.emptySearchResults {
                searchState = .empty
            } catch {
                searchState = .failed(error)
            }
        }
    }
}
