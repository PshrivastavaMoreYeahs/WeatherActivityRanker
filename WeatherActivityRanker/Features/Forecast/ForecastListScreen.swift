////
//  ForecastListScreen.swift
//  WeatherActivityRanker
//
//  Created by Prashant Shrivastava on 10/09/26.
//

import SwiftUI

struct ForecastListScreen: View {
    let forecast: RankedForecast

    var body: some View {
        List {
            Section {
                ForEach(forecast.days) { day in
                    NavigationLink {
                        DayDetailScreen(city: forecast.city, day: day)
                    } label: {
                        ForecastDayRow(day: day)
                    }
                    .accessibilityLabel(accessibilityLabel(for: day))
                }
            } header: {
                Text("Next 7 days")
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(forecast.city.name)
        .navigationBarTitleDisplayMode(.large)
    }

    private func accessibilityLabel(for day: RankedForecastDay) -> String {
        let ratings = day.activitySuitabilities
            .map {
                $0.availability.isAvailable
                    ? "\($0.activity.displayName): \($0.rating.rawValue)"
                    : "\($0.activity.displayName): unavailable"
            }
            .joined(separator: ", ")

        return "\(day.forecastDay.weekdayText), \(ratings)"
    }
}

private struct ForecastDayRow: View {
    let day: RankedForecastDay

    var body: some View {
        HStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 5) {
                Text(day.forecastDay.weekdayText)
                    .font(.headline)

                Text(day.forecastDay.temperatureRangeText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(minWidth: 66, alignment: .leading)

            Spacer(minLength: 8)

            HStack(spacing: 8) {
                ForEach(day.activitySuitabilities) { suitability in
                    ActivityBadge(suitability: suitability)
                }
            }
        }
        .padding(.vertical, 8)
    }
}
