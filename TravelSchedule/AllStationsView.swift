import SwiftUI

struct AllStationsView: View {
    @StateObject private var viewModel: AllStationsViewModel
    
    init(api: YandexScheduleAPI) {
        _viewModel = StateObject(wrappedValue: AllStationsViewModel(api: api))
    }
    
    var body: some View {
        NavigationView {
            Group {
                if viewModel.isLoading {
                    ProgressView("Загрузка...")
                } else if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                } else {
                    List {
                        ForEach(viewModel.countries.indices, id: \.self) { index in
                            let country = viewModel.countries[index]
                            CountrySectionView(country: country)
                        }
                    }
                }
            }
            .navigationTitle("Все станции")
            .task {
                if !viewModel.didLoad {
                    await viewModel.loadStations()
                }
            }
        }
    }
}

struct StationRowView: View {
    let station: Components.Schemas.Station
    
    var body: some View {
        Text(station.title ?? "Без названия")
            .font(.subheadline)
            .foregroundColor(.secondary)
    }
}

struct SettlementView: View {
    let settlement: Components.Schemas.Settlement
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(settlement.title ?? "—")
                .font(.headline)
            
            let stations = settlement.stations?.compactMap { $0 } ?? []
            
            ForEach(stations.indices, id: \.self) { index in
                StationRowView(station: stations[index])
            }
        }
        .padding(.vertical, 4)
    }
}

struct RegionView: View {
    let region: Components.Schemas.Region
    
    var body: some View {
        DisclosureGroup(region.title ?? "Регион") {
            let settlements = region.settlements?.compactMap { $0 } ?? []
            
            ForEach(settlements.indices, id: \.self) { index in
                SettlementView(settlement: settlements[index])
            }
            
        }
    }
}

struct CountrySectionView: View {
    let country: Components.Schemas.Country
    
    var body: some View {
        Section(header: Text(country.title ?? "Страна")) {
            ForEach(country.regions ?? [], id: \.codes?.yandex_code) { region in
                RegionView(region: region)
            }
        }
    }
}


