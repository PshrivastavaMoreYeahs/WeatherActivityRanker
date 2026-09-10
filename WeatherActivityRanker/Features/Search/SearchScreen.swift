////
//  SearchScreen.swift
//  WeatherActivityRanker
//
//  Created by Prashant Shrivastava on 10/09/26.
//

import SwiftUI

struct SearchScreen: View {
    @ObservedObject var viewModel: SearchViewModel

    var body: some View {
        List {
            Section {
                searchField
            }

            Section {
                searchContent
            } header: {
                Text("Cities")
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Find a city")
        .overlay {
            forecastLoadingOverlay
        }
        .navigationDestination(isPresented: $viewModel.isShowingForecast) {
            if let forecast = viewModel.rankedForecast {
                ForecastListScreen(forecast: forecast)
            }
        }
    }

    private var searchField: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)

            TextField("City or town", text: $viewModel.query)
                .textInputAutocapitalization(.words)
                .autocorrectionDisabled()
                .submitLabel(.search)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Search city or town")
    }

    @ViewBuilder
    private var searchContent: some View {
        switch viewModel.searchState {
        case .idle:
            ContentUnavailableView(
                "Search for a city",
                systemImage: "magnifyingglass",
                description: Text("Type at least two characters to find matching cities and towns.")
            )
        case .loading:
            HStack {
                ProgressView()
                Text("Searching")
                    .foregroundStyle(.secondary)
            }
        case let .loaded(cities):
            ForEach(cities) { city in
                Button {
                    viewModel.selectCity(city)
                } label: {
                    CityResultRow(city: city)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Select \(city.displayName)")
            }
        case .empty:
            ContentUnavailableView(
                "No matches",
                systemImage: "location.slash",
                description: Text("Try a different city or town name.")
            )
        case let .failed(error):
            ErrorStateView(message: error.localizedDescription)
        }
    }

    @ViewBuilder
    private var forecastLoadingOverlay: some View {
        switch viewModel.forecastState {
        case .loading:
            ZStack {
                Color.black.opacity(0.12)
                    .ignoresSafeArea()

                VStack(spacing: 12) {
                    ProgressView()
                    Text("Loading 7-day forecast")
                        .font(.headline)
                }
                .padding(20)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8))
            }
        case let .failed(error):
            VStack(spacing: 12) {
                ErrorStateView(message: error.localizedDescription)
                Button("Try again") {
                    viewModel.retryForecast()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8))
            .padding()
        default:
            EmptyView()
        }
    }
}

private struct CityResultRow: View {
    let city: City

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(city.displayName)
                    .font(.headline)
                    .foregroundStyle(.primary)

                Text(city.countryCode)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 6)
    }
}

#Preview {
    NavigationStack {
        SearchScreen(viewModel: SearchViewModel())
    }
}
