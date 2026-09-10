////
//  ForecastDateFormatting.swift
//  WeatherActivityRanker
//
//  Created by Prashant Shrivastava on 10/09/26.
//

import Foundation

extension ForecastDay {
    var weekdayText: String {
        date.formatted(.dateTime.weekday(.abbreviated))
    }

    var listDateText: String {
        date.formatted(.dateTime.weekday(.abbreviated).month(.abbreviated).day())
    }

    var fullDateText: String {
        date.formatted(.dateTime.weekday(.wide).month(.wide).day())
    }
}
