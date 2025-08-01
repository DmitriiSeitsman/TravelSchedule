import SwiftUI
import OpenAPIURLSession

struct MainView: View {
    private let api: YandexScheduleAPI
    private let locationService = LocationService()

    init() {
        self.api = YandexScheduleAPI(
            client: Client(
                serverURL: URL(string: "https://api.rasp.yandex.net")!,
                transport: URLSessionTransport()
            ),
            apikey: API.key
        )
    }

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Информация:"),
                        footer: Text("Дизайн временный, только для теста сетевых запросов.")) {
                    NavigationLink("Все станции") {
                        AllStationsView(api: api)
                    }
                    NavigationLink("Ближайший город") {
                        NearestCityView(api: api, locationService: locationService)
                    }
                    NavigationLink("Ближайшие станции") {
                        NearestStationsView()
                    }
                    NavigationLink("Расписание станции") {
                        StationScheduleView(api: api)
                    }
                    NavigationLink("Посмотреть маршрут") {
                        RouteSearchView()
                    }
                    NavigationLink("Станции по маршруту") {
                        ThreadStationsView(api: api, from: "s2006004")
                    }
                    NavigationLink("Перевозчик") {
                        CarrierInfoView(api: api)
                    }
                    NavigationLink("Авторские права") {
                        CopyrightView()
                    }
                }
            }
            .navigationTitle("Расписание")
        }
    }
}
