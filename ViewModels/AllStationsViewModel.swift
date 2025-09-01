import Foundation
import Combine

@MainActor
final class AllStationsViewModel: ObservableObject {
    typealias Country = Components.Schemas.Country
    typealias Region = Components.Schemas.Region
    typealias Settlement = Components.Schemas.Settlement
    typealias Station = Components.Schemas.Station

    @Published var countries: [Country] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    private(set) var didLoad = false

    private let api: YandexScheduleAPI
    
    init(api: YandexScheduleAPI) {
        self.api = api
    }

    func loadStations() async {
        guard !didLoad else { return }
        didLoad = true

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let response = try await api.allStations.getAllStations()
            
            countries = (response.countries ?? [])
                .sorted { ($0.title ?? "") < ($1.title ?? "") }
                .map { country in
                    var sortedCountry = country
                    sortedCountry.regions = country.regions?
                        .sorted { ($0.title ?? "") < ($1.title ?? "") }
                        .map { region in
                            var sortedRegion = region
                            sortedRegion.settlements = region.settlements?
                                .sorted { ($0.title ?? "") < ($1.title ?? "") }
                                .map { settlement in
                                    var sortedSettlement = settlement
                                    sortedSettlement.stations = settlement.stations?
                                        .sorted { ($0.title ?? "") < ($1.title ?? "") }
                                    return sortedSettlement
                                }
                            return sortedRegion
                        }
                    return sortedCountry
                }
        } catch {
            print("❌ Ошибка загрузки станций: \(error)")
            errorMessage = "Не удалось загрузить станции"
        }
    }
}

extension AllStationsViewModel {
    func stations(forCityCode cityCode: String) -> [StationItem] {
        let settlements = countries
            .flatMap { $0.regions ?? [] }
            .flatMap { $0.settlements ?? [] }
            .filter { $0.codes?.yandex_code == cityCode }

        let items = settlements
            .flatMap { $0.stations ?? [] }
            .compactMap { st -> StationItem? in
                guard let code = st.codes?.yandex_code, let title = st.title else { return nil }
                return StationItem(
                    id: code,
                    title: title,
                    transportType: st.transport_type,
                    stationType: st.station_type
                )
            }

        return items.sorted {
            $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending
        }
    }
}
