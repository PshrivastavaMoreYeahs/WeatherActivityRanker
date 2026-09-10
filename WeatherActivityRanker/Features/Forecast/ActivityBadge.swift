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

            Text("\(suitability.score)")
                .font(.caption2.weight(.bold))
                .monospacedDigit()
        }
        .foregroundStyle(suitability.rating.foregroundColor)
        .frame(width: 44, height: 44)
        .background(suitability.rating.backgroundColor, in: RoundedRectangle(cornerRadius: 8))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(suitability.activity.displayName): \(suitability.rating.rawValue), score \(suitability.score)")
    }
}
