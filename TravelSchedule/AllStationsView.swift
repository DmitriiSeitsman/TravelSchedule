import SwiftUI

struct AllStationsView: View {
    @StateObject private var viewModel: AllStationsViewModel

    init(api: YandexScheduleAPI) {
        _viewModel = StateObject(wrappedValue: AllStationsViewModel(api: api))
    }

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView("Загрузка...")
                } else if let error = viewModel.errorMessage {
                    VStack(spacing: 12) {
                        Text(error)
                            .foregroundColor(.red)
                        Button("Повторить") {
                            Task { await viewModel.loadStations() }
                        }
                    }
                    .padding()
                } else {
                    List {
                        let countries = viewModel.countries.compactMap { c -> (id: String, c: Components.Schemas.Country)? in
                            guard let id = c.codes?.yandex_code ?? c.title else { return nil }
                            return (id, c)
                        }

                        ForEach(countries, id: \.id) { pair in
                            CountrySectionView(country: pair.c)
                        }
                    }
                }
            }
            .navigationTitle("Все станции")

            .onAppear {
                guard !viewModel.didLoad else { return }
                Task {
                    try? await Task.sleep(nanoseconds: 150_000_000)
                    await viewModel.loadStations()
                }
            }
        }
    }
}

// MARK: - Subviews

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
        VStack(alignment: .leading, spacing: 4) {
            Text(settlement.title ?? "—")
                .font(.headline)
            let stations = (settlement.stations ?? []).compactMap { st -> (id: String, st: Components.Schemas.Station)? in
                guard let id = st.codes?.yandex_code ?? st.title else { return nil }
                return (id, st)
            }

            ForEach(stations, id: \.id) { pair in
                StationRowView(station: pair.st)
            }
        }
        .padding(.vertical, 4)
    }
}

struct RegionView: View {
    let region: Components.Schemas.Region

    var body: some View {
        DisclosureGroup(region.title ?? "Регион") {
            let settlements = (region.settlements ?? []).compactMap { s -> (id: String, s: Components.Schemas.Settlement)? in
                guard let id = s.codes?.yandex_code ?? s.title else { return nil }
                return (id, s)
            }

            ForEach(settlements, id: \.id) { pair in
                SettlementView(settlement: pair.s)
            }
        }
    }
}

struct CountrySectionView: View {
    let country: Components.Schemas.Country

    var body: some View {
        Section(header: Text(country.title ?? "Страна")) {
            let regions = (country.regions ?? []).compactMap { r -> (id: String, r: Components.Schemas.Region)? in
                guard let id = r.codes?.yandex_code ?? r.title else { return nil }
                return (id, r)
            }

            ForEach(regions, id: \.id) { pair in
                RegionView(region: pair.r)
            }
        }
    }
}
