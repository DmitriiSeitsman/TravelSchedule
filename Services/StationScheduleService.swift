import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

typealias StationSchedule = Components.Schemas.ScheduleResponse

protocol StationScheduleServiceProtocol {
    func getStationSchedule() async throws -> StationSchedule
}

final class StationScheduleService: StationScheduleServiceProtocol {
    private let client: Client
    private let apikey: String
    
    init(client: Client, apikey: String) {
        self.client = client
        self.apikey = apikey
    }
    
    func getStationSchedule() async throws -> StationSchedule {
        let today = ISO8601DateFormatter().string(from: Date()).prefix(10)
        
        let response = try await client.getStationSchedule(
            query: .init(
                apikey: apikey,
                station: "s2006004",
                format: "json",
                date: String(today),
                transport_types: "train",
            )
        )
        
        guard case let .ok(okResponse) = response else {
            throw URLError(.badServerResponse)
        }
        
        return try okResponse.body.json
    }
}
