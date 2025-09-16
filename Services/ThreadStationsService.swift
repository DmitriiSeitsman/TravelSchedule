import Foundation
import OpenAPIURLSession
import OpenAPIRuntime

protocol ThreadStationsServiceProtocol {
    func getRouteStations(fromStationCode: String) async throws -> Components.Schemas.ThreadStationsResponse
    func getRouteStationsRaw(uid: String) async throws -> Components.Schemas.ThreadStationsResponse
}


final class ThreadStationsService: ThreadStationsServiceProtocol, @unchecked Sendable {
    private let client: Client
    private let apikey: String
    private let stationScheduleService: StationScheduleServiceProtocol
    
    init(client: Client, apikey: String, stationScheduleService: StationScheduleServiceProtocol) {
        self.client = client
        self.apikey = apikey
        self.stationScheduleService = stationScheduleService
    }
    
    func getRouteStations(fromStationCode: String) async throws -> Components.Schemas.ThreadStationsResponse {
        let scheduleResponse = try await stationScheduleService.getStationSchedule(
            station: fromStationCode,
            date: nil,
            transport: nil
        )
        
        guard let firstUID = scheduleResponse.schedule?.first?.thread?.uid else {
            throw URLError(.badServerResponse)
        }
        print("🔍 UID найден:", firstUID)
        
        return try await getRouteStationsRaw(uid: firstUID)
    }
    
    //Почему собираем запрос вручную:
    // Автогенерированный метод getRouteStations из swift-openapi-generator
    // сразу пытается декодировать ответ в Components.Schemas.ThreadStationsResponse
    // используя стандартный ISO8601-декодер. Но Яндекс.Расписание в этом методе
    // возвращает даты в формате "yyyy-MM-dd HH:mm:ss", что ломает декодирование.
    //
    // Из-за этого мы теряем доступ к "сырым" данным в сгенерированном клиенте.
    // Поэтому мы формируем URL вручную и используем URLSession, чтобы получить
    // чистый JSON и раскодировать его через наш кастомный JSONDecoder.yandex,
    // который умеет работать с обоими форматами дат.
    func getRouteStationsRaw(uid: String) async throws -> Components.Schemas.ThreadStationsResponse {
        var components = URLComponents(string: "https://api.rasp.yandex.net/v3.0/thread/")!
        components.queryItems = [
            URLQueryItem(name: "apikey", value: apikey),
            URLQueryItem(name: "uid", value: uid),
            URLQueryItem(name: "format", value: "json"),
            URLQueryItem(name: "lang", value: "ru_RU"),
            URLQueryItem(name: "show_systems", value: "all")
        ]
        
        let (data, _) = try await URLSession.shared.data(from: components.url!)
        
        if let jsonString = String(data: data, encoding: .utf8) {
            print("📦 RAW JSON:\n\(jsonString)")
        }
        
        return try JSONDecoder.yandex.decode(Components.Schemas.ThreadStationsResponse.self, from: data)
    }
}
