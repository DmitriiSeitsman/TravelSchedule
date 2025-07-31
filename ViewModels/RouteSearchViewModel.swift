//import SwiftUI
//import OpenAPIURLSession
//import OpenAPIRuntime
//
//struct RouteSearchView: View {
//    @State private var isLoading = false
//    @State private var segments: [Components.Schemas.Segment] = []
//    @State private var errorMessage: String?
//    private let api: YandexScheduleAPI
//
//    var body: some View {
//        VStack {
//            if isLoading {
//                ProgressView("Загружаем маршруты...")
//            } else if let errorMessage {
//                Text("Ошибка: \(errorMessage)")
//                    .foregroundColor(.red)
//            } else if segments.isEmpty {
//                Text("Нет данных для отображения")
//            } else {
//                List(segments, id: \.thread?.uid) { segment in
//                    VStack(alignment: .leading, spacing: 4) {
//                        if let fromTitle = segment.from?.title,
//                           let toTitle = segment.to?.title {
//                            Text("\(fromTitle) → \(toTitle)")
//                                .font(.headline)
//                        }
//
//                        if let departure = segment.departure, let arrival = segment.arrival {
//                            Text("Отправление: \(formatDate(departure))")
//                            Text("Прибытие: \(formatDate(arrival))")
//                        }
//                        Text("Маршрут: \(segment.thread?.title ?? "маршрут не найден")")
//                    }
//                    .padding(.vertical, 4)
//                }
//            }
//        }
//        .navigationTitle("Поиск маршрута")
//        .onAppear {
//            Task {
//                await loadMockedRoute()
//            }
//        }
//    }
//
//    private func loadMockedRoute() async {
//        isLoading = true
//        defer { isLoading = false }
//
//        do {
//            let client = Client(
//                serverURL: URL(string: "https://api.rasp.yandex.net")!,
//                transport: URLSessionTransport()
//            )
//            let api = YandexScheduleAPI(client: client, apikey: API.key)
//
//            let result = try await api.routeSearch.getRoutes(
//                from: "s9600213",
//                to: "s9600663"
//            )
//
//            segments = result.segments ?? []
//        } catch {
//            errorMessage = error.localizedDescription
//        }
//    }
//
//
//    func formatDate(_ date: Date) -> String {
//        let formatter = DateFormatter()
//        formatter.dateStyle = .medium
//        formatter.timeStyle = .short
//        formatter.locale = Locale(identifier: "ru_RU")
//        return formatter.string(from: date)
//    }
//
//}
