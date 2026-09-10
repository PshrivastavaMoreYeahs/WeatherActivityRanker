# Weather Activity Ranking App - Decisions Before Implementation

## 1. Product Goal

Build a native iOS application that lets a user search for a city or town and see how suitable the next 7 days are for:

- Skiing
- Surfing
- Outdoor sightseeing
- Indoor sightseeing

The app will use Open-Meteo for weather data:

- Geocoding API
- Forecast API

The output should help users compare days quickly, understand the reason behind each score, and avoid treating a raw number as unexplained truth.

## 2. Platform And Stack

**Decision:** Use iOS, Swift, SwiftUI, MVVM, `async/await`, and no third-party dependencies.

**Reasoning:**

- SwiftUI with `async/await` keeps the app small and avoids unnecessary UIKit lifecycle or Combine boilerplate.
- Open-Meteo responses are simple enough for `URLSession` and `Codable`.
- Avoiding SPM/CocoaPods dependencies makes the project easier to build and review.
- MVVM is sufficient for this scope. A heavier Clean Architecture split would add indirection before the app needs it.
- The scoring engine will be isolated as pure logic, which provides the main testable business layer.

**Trade-off accepted:** No dependency injection framework. Use protocol-based constructor injection where needed, for example injecting a `WeatherServicing` dependency into view models.

## 3. Scope Boundaries

These decisions clarify behavior not fully specified in the original requirement.

### Ambiguous City Search

**Decision:** Show up to 5 geocoding matches with region and country, then let the user choose.

**Reason:** Open-Meteo can return multiple matches for the same query. Asking the user to select the intended location avoids silently choosing the wrong city.

### Next 7 Days

**Decision:** Use `forecast_days=7` and `timezone=auto`.

**Reason:** Forecast days should be based on the selected location's local time, not the device's current timezone.

### Units

**Decision:** Use metric units: Celsius, km/h, cm/mm.

**Reason:** This keeps the first version simple and consistent without adding a settings screen.

### Persistence

**Decision:** Do not add persistence, recent searches, favorites, or caching in v1.

**Reason:** The brief does not require persistence, and adding it would expand the scope beyond weather lookup, scoring, and presentation.

### Historical Weather

**Decision:** Keep historical and past weather out of scope.

**Reason:** The requirement is specifically about ranking the next 7 days.

### Offline Behavior

**Decision:** Show an error state with retry.

**Reason:** No offline cache is planned for v1, so the app should fail clearly and let the user try again.

### Accessibility

**Decision:** Use standard SwiftUI controls and add meaningful labels where scores or icons appear.

**Reason:** SwiftUI provides a useful baseline, while a dedicated accessibility audit can remain future work.

## 4. Activity Scoring Model

**Decision:** Each activity receives a 0-100 suitability score for each forecast day.

Scores should be produced by deterministic, pure functions using normalized weather signals and fixed weights. Each score should also include a short rationale string so users and reviewers can understand why a day ranked well or poorly.

### Score Buckets

Use consistent score buckets across activities:

- `0-39`: Poor
- `40-59`: Fair
- `60-79`: Good
- `80-100`: Excellent

### Skiing

Signals:

- `snowfall_sum`: positive signal
- `temperature_2m_min` and `temperature_2m_max`: reward cold but reasonable ski conditions
- `wind_speed_10m_max`: penalize high wind
- `weather_code`: penalize severe weather

Known limitation:

Open-Meteo Forecast API does not indicate whether a city has ski infrastructure. Skiing score means "conditions would be suitable if skiing were available nearby," not "this city is a ski destination."

Availability:

Use the elevation returned by Open-Meteo Geocoding as a first-pass mountain-terrain proxy. If elevation is below roughly 800 m, mark Skiing unavailable and grey it out in the UI. If elevation is missing, keep Skiing available rather than making an unsupported negative claim.

### Surfing

Signals:

- `wind_speed_10m_max`: proxy signal
- `wind_direction_10m_dominant`: proxy signal if useful
- `precipitation_probability_max`: penalty
- Temperature: mild bonus only

Known limitation:

Real surf quality depends on swell height, swell period, and wave direction. Surfing score remains a weather-based proxy, not a true surf forecast. Marine data is used only as a lightweight coastal availability check in v1.

Availability:

Use Open-Meteo Marine API as a lightweight geography check. Request a sea grid cell near the selected city and compare its returned coordinate with the city coordinate. If the nearest sea grid cell is more than roughly 75 km away, mark Surfing unavailable and grey it out in the UI. If the marine check fails, keep Surfing available rather than blocking the forecast experience.

### Outdoor Sightseeing

Signals:

- `precipitation_probability_max`: penalty
- `weather_code`: clear or partly cloudy weather is positive; rain, storm, fog, or snow are negative
- `temperature_2m_max`: reward comfortable temperatures, roughly 15-28C
- `wind_speed_10m_max`: mild penalty for high wind
- `uv_index_max`: slight penalty for very high UV

### Indoor Sightseeing

Signals:

- Rain, storms, extreme heat, high wind, and generally poor outdoor weather should increase indoor suitability.
- Indoor score should not simply be `100 - outdoorScore`.
- Indoor sightseeing should have a reasonable floor because museums, galleries, and indoor attractions remain viable in many conditions.
- Indoor score should have a practical ceiling when outdoor conditions are only mildly inconvenient.

## 5. Architecture Decisions

### App Structure

Use a small MVVM structure:

- SwiftUI Views
- ViewModels
- Services / Networking
- Models / DTOs
- Scoring domain logic

Suggested grouping:

```text
WeatherActivityRanker/
  App/
  Features/
    Search/
    Forecast/
  Services/
    OpenMeteo/
  Domain/
    Scoring/
  Models/
  Shared/
```

### Networking

**Decision:** Create an `OpenMeteoClient` with typed async methods:

- `geocode(query:)`
- `forecast(latitude:longitude:)`

Forecast requests should use these daily fields:

```text
weather_code,temperature_2m_max,temperature_2m_min,snowfall_sum,
precipitation_probability_max,wind_speed_10m_max,wind_gusts_10m_max,
wind_direction_10m_dominant,uv_index_max
```

Use `URLSession`, `URLComponents`, and `Codable`.

Use typed errors instead of exposing raw strings everywhere. Example categories:

- Network failure
- Invalid URL
- Decoding failure
- Empty geocoding results
- Unexpected API response

### Models

Separate API DTOs from app/domain models where it improves clarity.

The API response structs can mirror Open-Meteo JSON closely. The UI and scoring layer should receive cleaner app-level models where possible.

### ViewModel State

Represent screen state with explicit enums rather than multiple booleans.

Examples:

```swift
enum LoadingState<Value> {
    case idle
    case loading
    case loaded(Value)
    case empty
    case failed(Error)
}
```

This prevents invalid combinations like loading and error at the same time.

### Dependency Injection

Use protocol-based constructor injection.

Example:

```swift
protocol WeatherServicing {
    func searchCities(query: String) async throws -> [City]
    func forecast(for city: City) async throws -> Forecast
}
```

No DI container is needed for v1.

## 6. UI Decisions

Initial app flow:

1. Search screen with city/town query input.
2. Search results list showing city, region, and country.
3. Forecast ranking screen for selected city.
4. 7-day list with activity scores and labels.

**Decision:** Use a separate day detail screen instead of in-place expansion.

**Reason:** The forecast list remains easy to scan across all 7 days, while the detail screen gives each activity enough space for score, label, and rationale on smaller devices.

For each day, show:

- Date
- Weather summary
- Four activity scores
- Suitability label: Poor, Fair, Good, or Excellent
- Short rationale for each activity, either inline or in an expanded detail state

Keep the UI simple and reviewer-friendly. Avoid adding features not requested by the brief, such as favorites, maps, account login, or settings.

## 7. Testing Strategy

Prioritize tests for business logic and deterministic behavior.

### Unit Tests

Focus on:

- `SuitabilityScorer`
- Score boundaries and bucket mapping
- Edge cases such as high snowfall plus unsafe wind
- Indoor sightseeing not being a naive inverse of outdoor sightseeing
- Empty and ambiguous city search handling

### Decoding Tests

Use local fixture JSON copied from real Open-Meteo responses.

Do not rely on live API calls in tests.

### ViewModel Tests

Use mock implementations of `WeatherServicing`.

Cover:

- Idle to loading to loaded
- Empty geocoding results
- Network error path
- Forecast scoring path

### Not Planned For V1

- UI snapshot tests
- End-to-end tests against live Open-Meteo APIs
- Persistence tests

## 8. Known Limitations

- Surf score is only a weather-based proxy because Marine Weather API is not included in v1.
- Ski score does not know whether ski slopes or resorts exist near the searched location.
- Metric units only.
- No offline cache.
- No recent search history.
- No full accessibility audit in the initial version.

## 9. Future Work

Potential improvements after v1:

- Add Open-Meteo Marine Weather API for real surf scoring.
- Add lightweight local caching for last successful forecasts.
- Add recent searches or favorites.
- Add metric/imperial unit toggle.
- Add detailed score breakdown by signal.
- Add stronger accessibility testing for VoiceOver and Dynamic Type.
- Consider a repository layer if persistence or multiple weather providers are introduced.

## 10. Implementation Readiness Checklist

Before coding starts, confirm:

- Bundle identifier and app name.
- Minimum iOS version.
- Whether metric-only units are acceptable.
- Whether the surf limitation is acceptable for the first version.
- Whether the app should display all activity scores equally or emphasize the best activity per day.
- Whether city search should trigger automatically with debounce or only after tapping Search.

Current recommended defaults:

- Minimum iOS version: iOS 17 unless project constraints require lower.
- Search behavior: debounce while typing, then show selectable results.
- Ranking presentation: show all four activities per day and visually highlight the best score.
- API scope: Open-Meteo Geocoding API and Forecast API only.
