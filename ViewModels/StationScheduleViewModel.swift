import Foundation
import Combine

final class StationScheduleViewModel: ObservableObject {
    @Published var trips: [Components.Schemas.Schedule] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published private(set) var didLoad = false

    private let api: YandexScheduleAPI
    private var cancellables = Set<AnyCancellable>()

    init(api: YandexScheduleAPI) {
        self.api = api
    }

    func loadSchedule() {
        guard !didLoad else { return }
        didLoad = true

        isLoading = true
        errorMessage = nil

        Task {
            do {
                print("🚀 Отправляем запрос")
                let response = try await api.stationSchedule.getStationSchedule()
                let trips = response.schedule ?? []

                await MainActor.run {
                    print("✅ Обновляем данные на главном потоке")
                    self.trips = trips
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    print("❌ Ошибка: \(error)")
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }



}
