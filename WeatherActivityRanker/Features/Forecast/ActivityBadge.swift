////
//  ActivityBadge.swift
//  WeatherActivityRanker
//
//  Created by Prashant Shrivastava on 10/09/26.
//

import SwiftUI

struct ActivityBadge: View {
    let suitability: ActivitySuitability

    var body: some View {
        VStack(spacing: 3) {
            Image(systemName: suitability.activity.symbolName)
                .font(.caption.weight(.bold))
                .imageScale(.small)

            Text(suitability.availability.isAvailable ? "\(suitability.score)" : "--")
                .font(.caption2.weight(.bold))
                .monospacedDigit()
        }
        .foregroundStyle(suitability.availability.isAvailable ? suitability.rating.foregroundColor : .secondary)
        .frame(width: 44, height: 44)
        .background(
            suitability.availability.isAvailable ? suitability.rating.backgroundColor : Color.gray.opacity(0.16),
            in: RoundedRectangle(cornerRadius: 8)
        )
        .opacity(suitability.availability.isAvailable ? 1 : 0.55)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel)
    }

    private var accessibilityLabel: String {
        guard suitability.availability.isAvailable else {
            return "\(suitability.activity.displayName): unavailable. \(suitability.rationale)"
        }

        return "\(suitability.activity.displayName): \(suitability.rating.rawValue), score \(suitability.score)"
    }
}
