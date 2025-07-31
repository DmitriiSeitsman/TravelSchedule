import SwiftUI
import CoreLocation
import OpenAPIURLSession

struct NearestCityView: View {
    @State private var city: Components.Schemas.NearestCityResponse?
    @State private var errorMessage: String?
    @State private var isLoading = false

    let api: YandexScheduleAPI
    let locationService: LocationServiceProtocol

    var body: some View {
        VStack(spacing: 16) {
            Text("Ближайший город")
                .font(.title2)
                .bold()

            if isLoading {
                ProgressView("Определяем местоположение...")
            } else if let city = city {
                VStack(alignment: .leading, spacing: 8) {
                    Text("🏙️ \(city.title ?? "Неизвестно")")
                        .font(.title3)

                    if let distance = city.distance {
                        Text("📍 Расстояние: \(String(format: "%.1f", distance)) км")
                    } else {
                        Text("📍 Расстояние: неизвестно")
                    }

                    if let lat = city.lat, let lng = city.lng {
                        Text("🧭 Координаты: \(lat), \(lng)")
                    } else {
                        Text("🧭 Координаты: неизвестны")
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(12)
            } else if let errorMessage = errorMessage {
                Text("Ошибка: \(errorMessage)")
                    .foregroundColor(.red)
            }

            Spacer()
        }
        .padding()
        .onAppear {
            Task {
                await loadNearestCity()
            }
        }
    }

    private func loadNearestCity() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let coordinate = try await locationService.requestCurrentLocation()

            let result = try await api.nearestCity.getNearestCity(
                lat: coordinate.latitude,
                lng: coordinate.longitude,
                distance: 50
            )

            city = result
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
