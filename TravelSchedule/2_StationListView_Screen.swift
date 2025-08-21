import SwiftUI

struct StationListView: View {
    
    let city: City
    let cityTitle: String
    let cityCode: String
    @ObservedObject var stationsVM: AllStationsViewModel
    @Binding var selection: String
    
    @Environment(\.dismiss) private var dismiss
    @State private var query: String = ""
    
    private var allStations: [StationItem] {
        var settlements: [Components.Schemas.Settlement] = []
        
        for country in stationsVM.countries {
            for region in country.regions ?? [] {
                for settlement in region.settlements ?? [] {
                    if settlement.codes?.yandex_code == city.id {
                        settlements.append(settlement)
                    }
                }
            }
        }
        
        var result: [StationItem] = []
        for settlement in settlements {
            for st in settlement.stations ?? [] {
                if let code = st.codes?.yandex_code,
                   let title = st.title {
                    result.append(
                        StationItem(
                            id: code,
                            title: title,
                            transportType: st.transport_type,
                            stationType: st.station_type
                        )
                    )
                }
            }
        }
        
        return result.sorted {
            $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending
        }
    }
    
    private var filtered: [StationItem] {
        guard !query.isEmpty else { return allStations }
        return allStations.filter { $0.title.localizedCaseInsensitiveContains(query) }
    }
    
    var body: some View {
        VStack(spacing: 12) {
            
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                
                TextField("Введите запрос", text: $query)
                    .font(.system(size: 17, weight: .regular))
                    .textInputAutocapitalization(.words)
                    .autocorrectionDisabled(true)
                
                if !query.isEmpty {
                    Button {
                        query = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.tertiary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 12)
            .background(Color(.systemGray5))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .padding(.horizontal, 16)
            
            // Список станций
            List {
                ForEach(filtered) { st in
                    Button {
                        selection = "\(cityTitle) (\(st.title))"
                        dismiss()
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(st.title)
                                    .foregroundStyle(.primary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 17))
                                .foregroundStyle(.secondary)
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .listRowSeparator(.hidden)
                }
            }
            .listStyle(.plain)
            .overlay {
                if allStations.isEmpty {
                    ContentUnavailableView(
                        "Станции не найдены",
                        systemImage: ""
                    )
                    .font(.system(size: 24, weight: .bold))
                } else if filtered.isEmpty {
                    ContentUnavailableView(
                        "Не найдено",
                        systemImage: ""
                    )
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .semibold))
                        .frame(width: 44, height: 44)
                }
            }
            ToolbarItem(placement: .principal) {
                Text("Выбор станции")
                    .font(.system(size: 17, weight: .bold))
            }
        }
        .scrollDismissesKeyboard(.immediately)
        .background(Color(.systemBackground))
    }
}
