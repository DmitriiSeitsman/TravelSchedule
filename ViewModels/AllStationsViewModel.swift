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
        guard !didLoad else { return } // защита от повторной загрузки
        isLoading = true
        errorMessage = nil

        do {
            let response = try await api.allStations.getAllStations()

            // Автоматическая сортировка стран и их вложенных данных
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

            didLoad = true
        } catch {
            print("❌ Ошибка загрузки станций: \(error)")
            errorMessage = "Не удалось загрузить станции"
        }

        isLoading = false
    }
}
