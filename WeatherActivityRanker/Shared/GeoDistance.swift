////
//  GeoDistance.swift
//  WeatherActivityRanker
//
//  Created by Prashant Shrivastava on 10/09/26.
//

import Foundation

nonisolated enum GeoDistance {
    static func kilometersBetween(
        latitude firstLatitude: Double,
        longitude firstLongitude: Double,
        andLatitude secondLatitude: Double,
        longitude secondLongitude: Double
    ) -> Double {
        let earthRadiusKilometers = 6_371.0
        let latitudeDelta = degreesToRadians(secondLatitude - firstLatitude)
        let longitudeDelta = degreesToRadians(secondLongitude - firstLongitude)
        let firstLatitudeRadians = degreesToRadians(firstLatitude)
        let secondLatitudeRadians = degreesToRadians(secondLatitude)

        let a = sin(latitudeDelta / 2) * sin(latitudeDelta / 2)
            + cos(firstLatitudeRadians) * cos(secondLatitudeRadians)
            * sin(longitudeDelta / 2) * sin(longitudeDelta / 2)
        let c = 2 * atan2(sqrt(a), sqrt(1 - a))

        return earthRadiusKilometers * c
    }

    private static func degreesToRadians(_ degrees: Double) -> Double {
        degrees * .pi / 180
    }
}
