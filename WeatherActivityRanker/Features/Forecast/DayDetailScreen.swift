////
//  DayDetailScreen.swift
//  WeatherActivityRanker
//
//  Created by Prashant Shrivastava on 10/09/26.
//

import SwiftUI

struct DayDetailScreen: View {
    let city: City
    let day: RankedForecastDay

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 6) {
                    Text(city.displayName)
                        .font(.headline)
                    Text(day.forecastDay.fullDateText)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text(day.forecastDay.temperatureRangeText)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
            }

            Section {
                ForEach(day.activitySuitabilities) { suitability in
                    ActivityDetailCard(suitability: suitability)
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                        .listRowBackground(Color.clear)
                }
            } header: {
                Text("Activity suitability")
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(day.forecastDay.weekdayText)
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct ActivityDetailCard: View {
    let suitability: ActivitySuitability

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Image(systemName: suitability.activity.symbolName)
                    .font(.title3.weight(.semibold))

                VStack(alignment: .leading, spacing: 2) {
                    Text("\(suitability.activity.displayName) · \(suitability.rating.rawValue)")
                        .font(.headline)
                    Text("\(suitability.score)/100")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
            }

            Text(suitability.rationale)
                .font(.subheadline)
                .foregroundStyle(.primary)
        }
        .foregroundStyle(suitability.rating.foregroundColor)
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(suitability.rating.backgroundColor, in: RoundedRectangle(cornerRadius: 8))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(suitability.activity.displayName): \(suitability.rating.rawValue), score \(suitability.score) out of 100. \(suitability.rationale)")
    }
}
