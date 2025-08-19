import Foundation
import Combine

@MainActor
final class CitySearchViewModel: ObservableObject {
    @Published var query: String = ""
    @Published private(set) var cities: [City] = []
    @Published private(set) var filtered: [City] = []
    @Published var isLoading: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    private let locationService: LocationServiceProtocol

    let stationsVM: AllStationsViewModel
    
    init(stationsVM: AllStationsViewModel, locationService: LocationServiceProtocol) {
        self.stationsVM = stationsVM
        self.locationService = locationService

        // подписка на поиск
        $query
            .debounce(for: .milliseconds(200), scheduler: RunLoop.main)
            .sink { [weak self] text in
                self?.applyFilter(query: text)
            }
            .store(in: &cancellables)
    }

    func loadCities() {
        guard cities.isEmpty else { return }
        isLoading = true

        Task {
            if !stationsVM.didLoad {
                await stationsVM.loadStations()
            }

            let currentCountry = (try? await locationService.currentCountryCode()) ?? "RU"


            var all: [City] = []
            for country in stationsVM.countries {
                let countryName = country.title ?? ""
                for region in country.regions ?? [] {
                    for settlement in region.settlements ?? [] {
                        if let code = settlement.yandexID,
                           let title = settlement.title {
                            all.append(City(id: code, title: title, country: countryName))
                        }
                    }
                }
            }

            // сортировка: сначала города текущей страны
            let sorted = all.sorted { lhs, rhs in
                if lhs.country == currentCountry && rhs.country != currentCountry {
                    return true
                }
                if lhs.country != currentCountry && rhs.country == currentCountry {
                    return false
                }
                return lhs.title.localizedCaseInsensitiveCompare(rhs.title) == .orderedAscending
            }

            self.cities = sorted
            self.filtered = sorted
            self.isLoading = false
        }
    }

    private func applyFilter(query: String) {
        guard !query.isEmpty else {
            filtered = cities
            return
        }
        filtered = cities.filter { $0.title.localizedCaseInsensitiveContains(query) }
    }
}
