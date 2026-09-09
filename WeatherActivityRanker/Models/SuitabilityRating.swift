////
//  SuitabilityRating.swift
//  WeatherActivityRanker
//
//  Created by Prashant Shrivastava on 09/09/26.
//

import Foundation

enum SuitabilityRating: String, Equatable, Sendable {
    case poor = "Poor"
    case fair = "Fair"
    case good = "Good"
    case excellent = "Excellent"

    init(score: Int) {
        switch score {
        case ...39:
            self = .poor
        case 40...59:
            self = .fair
        case 60...79:
            self = .good
        default:
            self = .excellent
        }
    }
}
