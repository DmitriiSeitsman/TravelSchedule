import Foundation
import CoreLocation

final class NearestStationsViewModel: ObservableObject {
    @Published var stations: [Components.Schemas.Station] = []

    private let api: YandexScheduleAPI
    private let locationService: LocationServiceProtocol

    init(api: YandexScheduleAPI, locationService: LocationServiceProtocol = LocationService()) {
        self.api = api
        self.locationService = locationService

        Task {
            await self.load()
        }
    }

    @MainActor
    func load() async {
        do {
            let location = try await locationService.requestCurrentLocation()
            print("🌍 Локация: \(location.latitude), \(location.longitude)")

            let result = try await api.nearestStations.getNearestStations(
                lat: location.latitude,
                lng: location.longitude,
                distance: 50
            )

            print("✅ Найдено станций: \(result.stations?.count ?? 0)")
            stations = (result.stations ?? []).compactMap { $0 }
        } catch {
            print("❌ Ошибка получения станций: \(error)")
        }
    }
}
