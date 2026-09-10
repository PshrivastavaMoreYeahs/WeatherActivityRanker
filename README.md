# Weather Activity Ranker

Native iOS app that lets a user search for a city or town, select the intended location from Open-Meteo geocoding results, and view a 7-day suitability ranking for:

- Skiing
- Surfing
- Outdoor sightseeing
- Indoor sightseeing

The app uses Open-Meteo directly from the client. No backend, account system, persistence, or third-party dependencies are required.

## What We Built

- Debounced city/town search using the Open-Meteo Geocoding API.
- Disambiguated search results with city, region, and country.
- Forecast loading using the Open-Meteo Forecast API.
- A 7-day forecast overview with one row per day.
- Four activity badges per day, each showing an icon, score, and accessible label.
- Day detail screen with larger activity cards, score bucket, and rationale.
- Deterministic suitability scoring isolated in a pure scoring layer.
- DTO-to-domain mapping layer for Open-Meteo responses.
- Protocol-based repository and HTTP client abstraction for testability.
- Typed repository errors and explicit loading/error UI states.
- Unit tests for mapping and repository request/error behavior.

## How To Run

1. Open `WeatherActivityRanker.xcodeproj` in Xcode.
2. Select the `WeatherActivityRanker` scheme.
3. Choose an iOS Simulator or connected iPhone.
4. Build and run with `Cmd + R`.

From the command line:

```sh
xcodebuild build -project WeatherActivityRanker.xcodeproj -scheme WeatherActivityRanker -destination 'generic/platform=iOS Simulator'
```

Run the focused unit tests:

```sh
xcodebuild test -project WeatherActivityRanker.xcodeproj -scheme WeatherActivityRanker -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:WeatherActivityRankerTests
```

If the named simulator is not available on your machine, replace `iPhone 17` with an installed simulator from Xcode.

## Assumptions

- Metric units are used: Celsius, km/h, and millimeters.
- The forecast is based on the selected location's local timezone using `timezone=auto`.
- The app shows the next 7 forecast days using `forecast_days=7`.
- Activity scores are weather suitability proxies, not guarantees that an activity is physically available in or near the city.
- Skiing does not currently verify nearby ski resorts, slopes, or mountain access.
- Surfing does not currently verify sea/ocean access, swell, wave period, or surf breaks.
- No offline cache, recent searches, favorites, or settings are included in this version.
- Tests use mocked responses rather than live Open-Meteo calls.

## Project Structure

```text
WeatherActivityRanker/
  Domain/Scoring/        Suitability scoring protocols and implementation
  Features/Search/       Search screen and view model
  Features/Forecast/     Forecast overview, badges, date formatting, detail screen
  Models/                App/domain models
  Services/Networking/   HTTP client abstraction
  Services/OpenMeteo/    Open-Meteo endpoints, DTOs, mapper, repository
  Shared/                Shared UI/state helpers
```

See `WeatherActivityRanker/DECISIONS_PRODUCT-PLAN.md` for product and architecture decisions.
