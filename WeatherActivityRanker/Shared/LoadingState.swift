////
//  LoadingState.swift
//  WeatherActivityRanker
//
//  Created by Prashant Shrivastava on 10/09/26.
//

import Foundation

nonisolated enum LoadingState<Value> {
    case idle
    case loading
    case loaded(Value)
    case empty
    case failed(Error)
}
