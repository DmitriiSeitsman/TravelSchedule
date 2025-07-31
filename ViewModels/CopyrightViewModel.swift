import Foundation
import OpenAPIRuntime

final class CopyrightViewModel: ObservableObject {
    @Published var copyright: String = ""
    @Published var url: String = ""
    
    private let api: YandexScheduleAPI
    
    init(api: YandexScheduleAPI) {
        self.api = api
    }
    
    func load() {
        Task {
            do {
                let result = try await api.copyright.getCopyright()
                await MainActor.run {
                    self.copyright = result.text ?? "Нет текста"
                    self.url = result.url ?? ""
                }
            } catch {
                print("❌ Ошибка загрузки авторских прав: \(error)")
            }
        }
    }
}
