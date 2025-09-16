import SwiftUI
// MARK: - Struct
struct Filters {
    var morning: Bool
    var dayTime: Bool
    var evening: Bool
    var night: Bool
    var transfers: Bool?
}

// MARK: - Results
struct ResultsView: View {
    let fromCode: String
    let toCode: String
    let fromTitle: String
    let toTitle: String
    let api: YandexScheduleAPIProtocol
    @Environment(\.dismiss) private var dismiss
    
    @State private var showFilters = false
    @State private var items: [SegmentItem] = []
    @State private var isLoading = false
    @State private var error: String?
    @State private var filtersApplied = false
    @State private var selectedItem: SegmentItem?
    @State private var allItems: [SegmentItem] = []
    @State private var currentFilters: Filters?
    @State private var didLoad = false
    
    
    var body: some View {
        ZStack {
            if isLoading {
                ProgressView("Загружаем рейсы…")
            } else if let error {
                VStack(spacing: 12) {
                    Text("Не удалось загрузить расписание").font(.headline)
                    Text(error).foregroundStyle(.secondary)
                    Button("Повторить") { load() }
                        .buttonStyle(.borderedProminent)
                }
                .padding()
            } else if items.isEmpty {
                ContentPlaceholder(
                    systemImage: "train.side.front.car",
                    title: "Пока пусто",
                    subtitle: "Попробуйте другую дату или фильтры."
                )
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(items) { item in
                            SegmentCard(item: item)
                                .contentShape(Rectangle())
                                .onTapGesture { selectedItem = item }
                        }
                    }
                    .padding([.horizontal, .vertical], 16)
                }
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .semibold))
                        .frame(width: 44, height: 44)
                        .foregroundColor(.ypBlack)
                }
            }
        }
        .safeAreaInset(edge: .top, alignment: .leading) {
            if !items.isEmpty {
                VStack(alignment: .leading, spacing: 0) {
                    Text("\(fromTitle) → \(toTitle)")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.ypBlack)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.ypWhite)
            }
        }
        .safeAreaInset(edge: .bottom) {
            if !items.isEmpty {
                VStack(spacing: 0) {
                    Button { showFilters = true } label: {
                        HStack(spacing: 4) {
                            Text("Уточнить время")
                                .font(.system(size: 17, weight: .bold))
                            if filtersApplied {
                                Circle()
                                    .fill(Color.redUniversal)
                                    .frame(width: 8, height: 8)
                            }
                        }
                        .frame(maxWidth: .infinity, minHeight: 60)
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(.white)
                    .background(.blueUniversal)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
                }
            }
        }
        .navigationDestination(item: $selectedItem) { item in
            if let (code, system) = item.carrierPreferredCodeAndSystem {
                CarrierInfoView(
                    api: api,
                    carrierCode: code,
                    system: system,
                    fallbackCarrier: item.carrierCodes
                )
                .toolbar(.hidden, for: .tabBar)
            } else {
                Text("Нет данных о перевозчике")
            }
        }
        .navigationDestination(isPresented: $showFilters) {
            FiltersView(
                onBack: { showFilters = false },
                onApply: { filters in currentFilters = filters
                    applyFilters()
                    filtersApplied = !(filters.morning == false &&
                                       filters.dayTime == false &&
                                       filters.evening == false &&
                                       filters.night == false &&
                                       filters.transfers == nil)
                    showFilters = false
                }
            )
        }
        .onAppear {
            if !didLoad {
                didLoad = true
                load()
            } else if currentFilters != nil {
                applyFilters()
            }
        }
    }
    
    private func applyFilters() {
        guard let filters = currentFilters else {
            items = sortByDeparture(allItems)
            return
        }
        
        let filtered = allItems.filter { item in
            
            if filters.morning || filters.dayTime || filters.evening || filters.night {
                guard let dep = timeFormatter.date(from: item.departureTime) else { return false }
                let hour = Calendar.current.component(.hour, from: dep)
                var ok = false
                if filters.morning, (6..<12).contains(hour) { ok = true }
                if filters.dayTime, (12..<18).contains(hour) { ok = true }
                if filters.evening, (18..<24).contains(hour) { ok = true }
                if filters.night, (0..<6).contains(hour) { ok = true }
                if !ok { return false }
            }
            
            if let needTransfers = filters.transfers {
                if item.hasTransfers != needTransfers {
                    return false
                }
            }
            
            return true
        }
        
        items = sortByDeparture(filtered)
        print("Всего рейсов: \(allItems.count), после фильтра: \(filtered.count)")
    }
    
    private func load() {
        isLoading = true
        error = nil
        Task {
            do {
                let segments = try await api.searchRoutes(from: fromCode, to: toCode)
                print("🔎 Запрос в API: from=\(fromCode), to=\(toCode)")
                
                print("✅ Ответ API: \(segments)") // лог всего ответа
                print("➡️ Получено сегментов: \(segments.segments?.count ?? 0)")
                
                let mapped = (segments.segments ?? []).compactMap { SegmentItem(from: $0) }
                print("➡️ Получено сегментов: \(mapped.count)")
                
                await MainActor.run {
                    self.allItems = mapped
                    if currentFilters != nil {
                        self.applyFilters()
                    } else {
                        self.items = sortByDeparture(mapped)
                    }
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.error = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
    
    private func sortByDeparture(_ array: [SegmentItem]) -> [SegmentItem] {
        array.sorted {
            (timeFormatter.date(from: $0.departureTime) ?? .distantPast) <
                (timeFormatter.date(from: $1.departureTime) ?? .distantPast)
        }
    }
}

// MARK: - Card
private struct SegmentCard: View {
    let item: SegmentItem
    
    private var transportIcon: String {
        switch item.transportType {
        case "plane": return "airplane"
        case "train": return "train.side.front.car"
        case "suburban": return "tram.fill"
        case "bus": return "bus"
        case "water": return "ferry"
        case "helicopter": return "helicopter"
        default: return "questionmark.circle"
        }
    }
    
    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8).fill(Color.clear)
                    
                    if let logo = item.carrierLogo, let url = URL(string: logo) {
                        AsyncImage(url: url) { image in
                            image.resizable()
                                .scaledToFit()
                                .frame(width: 38, height: 38)
                        } placeholder: {
                            ProgressView().frame(width: 38, height: 38)
                        }
                    } else {
                        Image(systemName: transportIcon)
                            .resizable()
                            .scaledToFit()
                            .foregroundStyle(.secondary)
                            .frame(width: 38, height: 38)
                    }
                }
                .frame(width: 38, height: 38)
                
                VStack(alignment: .leading, spacing: 0) {
                    Text(item.carrierName)
                        .font(.system(size: 17, weight: .regular))
                        .foregroundColor(.blackUniversal)
                    if let transfer = item.transferText {
                        Text(transfer)
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(.redUniversal)
                    }
                }
                
                Spacer()
                Text(item.departureDateShort)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.blackUniversal)
            }
            
            HStack {
                Text(item.departureTime)
                    .font(.system(size: 17, weight: .regular))
                    .foregroundColor(.blackUniversal)
                
                ZStack {
                    Capsule()
                        .fill(Color.grayUniversal)
                        .frame(height: 1)
                    
                    Text(item.durationText)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.blackUniversal)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 3)
                        .background(.simpleGray)
                }
                
                Text(item.arrivalTime)
                    .font(.system(size: 17, weight: .regular))
                    .foregroundColor(.blackUniversal)
            }
            .frame(height: 40)
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.simpleGray))
                .frame(height: 104)
        )
    }
}

// MARK: - Segment mapping
fileprivate let shortDateFormatter: DateFormatter = {
    let f = DateFormatter()
    f.dateFormat = "dd.MM"
    return f
}()

fileprivate let timeFormatter: DateFormatter = {
    let f = DateFormatter()
    f.dateFormat = "HH:mm"
    f.timeZone = TimeZone.current
    f.locale = Locale(identifier: "ru_RU")
    return f
}()


// MARK: - SegmentItem Extension
extension SegmentItem {
    var carrierPreferredCodeAndSystem: (code: String, system: String)? {
        if let iata = carrierCodes.codes?.iata {
            return (iata, "iata")
        }
        if let icao = carrierCodes.codes?.icao {
            return (icao, "icao")
        }
        if let sirena = carrierCodes.codes?.sirena {
            return (sirena, "sirena")
        }
        if let code = carrierCodes.code {
            return (String(describing: code), "internal")
        }
        return nil
    }
    
    init?(from segment: Components.Schemas.Segment) {
        guard
            let thread = segment.thread,
            let dep = segment.departure,
            let arr = segment.arrival
        else { return nil }
        
        let carrier = thread.carrier ?? Components.Schemas.Carrier(
            code: nil,
            contacts: nil,
            url: nil,
            title: "Железная дорога",
            phone: nil,
            address: nil,
            logo: nil,
            email: nil,
            codes: nil
        )
        
        self.init(
            id: UUID().uuidString,
            carrierName: carrier.title ?? "Без названия",
            carrierCode: carrier.codes?.iata ?? carrier.codes?.icao ?? carrier.codes?.sirena ?? (carrier.code.map { String(describing: $0) }) ?? "",
            carrierLogo: carrier.logo,
            departureDateShort: shortDateFormatter.string(from: dep),
            departureTime: timeFormatter.string(from: dep),
            arrivalTime: timeFormatter.string(from: arr),
            durationText: "\((segment.duration ?? 0) / 60) мин",
            transferText: (segment.has_transfers == true) ? "С пересадкой" : nil,
            hasTransfers: segment.has_transfers,
            carrierCodes: carrier,
            transportType: thread.transport_type
        )
    }
    
}



