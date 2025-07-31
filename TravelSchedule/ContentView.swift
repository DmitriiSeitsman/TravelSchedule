import SwiftUI
import OpenAPIURLSession

struct ContentView: View {
    private let api = YandexScheduleAPI(
        client: Client(
            serverURL: URL(string: "https://api.rasp.yandex.net")!,
            transport: URLSessionTransport()
        ),
        apikey: API.key
    )

    private let locationService = LocationService()

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Информация")) {
                    NavigationLink("Ближайший город") {
                        NearestCityView(api: api, locationService: locationService)
                    }
                    NavigationLink("Ближайшие станции") {
                        NearestStationsView()
                    }
                    NavigationLink("Посмотреть маршрут") {
                        RouteSearchView()
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
