////
//  ContentView.swift
//  WeatherActivityRanker
//
//  Created by Prashant Shrivastava on 09/09/26.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel: SearchViewModel

    init() {
        _viewModel = StateObject(wrappedValue: SearchViewModel())
    }

    init(viewModel: SearchViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            SearchScreen(viewModel: viewModel)
        }
    }
}

#Preview {
    ContentView()
}
