////
//  SuitabilityScorer.swift
//  WeatherActivityRanker
//
//  Created by Prashant Shrivastava on 10/09/26.
//

import Foundation

nonisolated struct SuitabilityScorer: SuitabilityScoring {
    func rankedForecast(from forecast: Forecast, availability: ActivityAvailabilitySet = .allAvailable) -> RankedForecast {
        RankedForecast(
            city: forecast.city,
            timezone: forecast.timezone,
            days: forecast.days.map { day in
                RankedForecastDay(
                    forecastDay: day,
                    activitySuitabilities: ActivityType.allCases.map {
                        score($0, for: day, availability: availability.availability(for: $0))
                    }
                )
            }
        )
    }

    private func score(_ activity: ActivityType, for day: ForecastDay, availability: ActivityAvailability) -> ActivitySuitability {
        guard availability.isAvailable else {
            return ActivitySuitability(
                activity: activity,
                score: 0,
                rating: .poor,
                rationale: availability.reason ?? "This activity is not available for the selected location.",
                availability: availability
            )
        }

        switch activity {
        case .skiing:
            return skiingScore(for: day)
        case .surfing:
            return surfingScore(for: day)
        case .outdoorSightseeing:
            return outdoorSightseeingScore(for: day)
        case .indoorSightseeing:
            return indoorSightseeingScore(for: day)
        }
    }

    private func skiingScore(for day: ForecastDay) -> ActivitySuitability {
        let snow = day.snowfallSum ?? 0
        let wind = max(day.windSpeedMaximum ?? 0, (day.windGustsMaximum ?? 0) * 0.7)
        let temperatureScore = scoreRange(value: day.temperatureMaximum, idealMin: -8, idealMax: 2, hardMin: -18, hardMax: 8)
        let snowScore = min(100, Int(snow * 28))
        let windScore = inverseScore(value: wind, idealMax: 20, hardMax: 55)
        let weatherScore = severeWeatherPenaltyScore(weatherCode: day.weatherCode)
        let score = clamp(Int(Double(snowScore) * 0.35 + Double(temperatureScore) * 0.30 + Double(windScore) * 0.20 + Double(weatherScore) * 0.15))
        let rationale = snow > 0 ? "Fresh snow with \(rounded(wind)) km/h wind" : "No snowfall, \(day.temperatureRangeText.lowercased())"

        return makeSuitability(activity: .skiing, score: score, rationale: rationale)
    }

    private func surfingScore(for day: ForecastDay) -> ActivitySuitability {
        let wind = day.windSpeedMaximum ?? 0
        let temperature = day.apparentTemperatureMaximum ?? day.temperatureMaximum
        let windScore = scoreRange(value: wind, idealMin: 12, idealMax: 28, hardMin: 0, hardMax: 45)
        let temperatureScore = scoreRange(value: temperature, idealMin: 18, idealMax: 30, hardMin: 8, hardMax: 38)
        let precipitationScore = inverseScore(value: Double(day.precipitationProbabilityMaximum ?? 0), idealMax: 25, hardMax: 95)
        let weatherScore = severeWeatherPenaltyScore(weatherCode: day.weatherCode)
        let directionScore = day.windDirectionDominant == nil ? 60 : 70
        let score = clamp(Int(Double(windScore) * 0.35 + Double(temperatureScore) * 0.20 + Double(precipitationScore) * 0.20 + Double(weatherScore) * 0.15 + Double(directionScore) * 0.10))
        let rationale = "Weather proxy: \(rounded(wind)) km/h wind, \(day.precipitationProbabilityMaximum ?? 0)% rain risk"

        return makeSuitability(activity: .surfing, score: score, rationale: rationale)
    }

    private func outdoorSightseeingScore(for day: ForecastDay) -> ActivitySuitability {
        let temperature = day.apparentTemperatureMaximum ?? day.temperatureMaximum
        let wind = day.windSpeedMaximum ?? 0
        let precipitationScore = inverseScore(value: Double(day.precipitationProbabilityMaximum ?? 0), idealMax: 20, hardMax: 90)
        let temperatureScore = scoreRange(value: temperature, idealMin: 15, idealMax: 28, hardMin: 0, hardMax: 38)
        let weatherScore = outdoorWeatherScore(weatherCode: day.weatherCode)
        let windScore = inverseScore(value: wind, idealMax: 18, hardMax: 50)
        let uvScore = inverseScore(value: day.uvIndexMaximum ?? 0, idealMax: 6, hardMax: 11)
        let score = clamp(Int(Double(precipitationScore) * 0.30 + Double(temperatureScore) * 0.30 + Double(weatherScore) * 0.20 + Double(windScore) * 0.10 + Double(uvScore) * 0.10))
        let rationale = "\(weatherSummary(for: day.weatherCode)), \(day.precipitationProbabilityMaximum ?? 0)% rain risk"

        return makeSuitability(activity: .outdoorSightseeing, score: score, rationale: rationale)
    }

    private func indoorSightseeingScore(for day: ForecastDay) -> ActivitySuitability {
        let temperature = day.apparentTemperatureMaximum ?? day.temperatureMaximum
        let rain = day.precipitationProbabilityMaximum ?? 0
        let wind = max(day.windSpeedMaximum ?? 0, (day.windGustsMaximum ?? 0) * 0.7)
        var score = 55

        score += rain >= 70 ? 20 : rain >= 40 ? 12 : 0
        score += isPoorOutdoorWeather(day.weatherCode) ? 15 : 0
        score += temperature < 5 || temperature > 32 ? 12 : 0
        score += wind > 40 ? 8 : 0
        score = min(score, isPoorOutdoorWeather(day.weatherCode) || rain >= 60 ? 92 : 78)

        let rationale = rain >= 40 || isPoorOutdoorWeather(day.weatherCode) ? "Indoor plans benefit from poor outdoor conditions" : "Comfortable fallback with decent outdoor weather"
        return makeSuitability(activity: .indoorSightseeing, score: clamp(score), rationale: rationale)
    }

    private func makeSuitability(activity: ActivityType, score: Int, rationale: String) -> ActivitySuitability {
        let clampedScore = clamp(score)
        return ActivitySuitability(
            activity: activity,
            score: clampedScore,
            rating: SuitabilityRating(score: clampedScore),
            rationale: rationale,
            availability: .available
        )
    }

    private func scoreRange(value: Double, idealMin: Double, idealMax: Double, hardMin: Double, hardMax: Double) -> Int {
        if value >= idealMin && value <= idealMax {
            return 100
        }

        if value < idealMin {
            return clamp(Int(((value - hardMin) / (idealMin - hardMin)) * 100))
        }

        return clamp(Int(((hardMax - value) / (hardMax - idealMax)) * 100))
    }

    private func inverseScore(value: Double, idealMax: Double, hardMax: Double) -> Int {
        guard value > idealMax else { return 100 }
        return clamp(Int(((hardMax - value) / (hardMax - idealMax)) * 100))
    }

    private func severeWeatherPenaltyScore(weatherCode: Int) -> Int {
        switch weatherCode {
        case 95...99:
            return 5
        case 71...86:
            return 50
        case 51...67:
            return 60
        case 45, 48:
            return 65
        default:
            return 90
        }
    }

    private func outdoorWeatherScore(weatherCode: Int) -> Int {
        switch weatherCode {
        case 0:
            return 100
        case 1...3:
            return 88
        case 45, 48:
            return 45
        case 51...57:
            return 55
        case 61...67, 80...82:
            return 30
        case 71...86:
            return 25
        case 95...99:
            return 5
        default:
            return 60
        }
    }

    private func isPoorOutdoorWeather(_ weatherCode: Int) -> Bool {
        switch weatherCode {
        case 45, 48, 61...67, 71...86, 95...99:
            return true
        default:
            return false
        }
    }

    private func weatherSummary(for weatherCode: Int) -> String {
        switch weatherCode {
        case 0:
            return "Clear skies"
        case 1...3:
            return "Partly cloudy"
        case 45, 48:
            return "Foggy"
        case 51...57:
            return "Drizzle"
        case 61...67, 80...82:
            return "Rain likely"
        case 71...86:
            return "Snowy"
        case 95...99:
            return "Storm risk"
        default:
            return "Mixed conditions"
        }
    }

    private func clamp(_ value: Int) -> Int {
        min(100, max(0, value))
    }

    private func rounded(_ value: Double) -> String {
        String(format: "%.0f", value)
    }
}
