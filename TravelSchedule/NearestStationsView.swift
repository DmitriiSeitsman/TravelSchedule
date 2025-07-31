import OpenAPIURLSession
import SwiftUI

struct NearestStationsView: View {
    @StateObject private var viewModel = NearestStationsViewModel(
        api: YandexScheduleAPI(
            client: Client(
                serverURL: URL(string: "https://api.rasp.yandex.net")!,
                transport: URLSessionTransport()
            ),
            apikey: API.key
        )
    )
    
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Ближайшие станции")
                .font(.largeTitle)
                .bold()
            
            if viewModel.stations.isEmpty {
                Spacer()
                VStack {
                    ProgressView()
                    Text("Загрузка станций...")
                        .foregroundColor(.secondary)
                        .padding(.top, 8)
                }
                Spacer()
            } else {
                List(viewModel.stations, id: \.code) { station in
                    VStack(alignment: .leading) {
                        if let title = station.title {
                            Text(title)
                                .font(.headline)
                        }
                        if let code = station.code {
                            Text("Код: \(code)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
        }
        .padding()
        .navigationTitle("Станции")
    }
}
