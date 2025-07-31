import OpenAPIRuntime
import Foundation
import OpenAPIURLSession

typealias NearestStations = Components.Schemas.Stations

protocol NearestStationsServiceProtocol {
  
  func getNearestStations(lat: Double, lng: Double, distance: Int) async throws -> NearestStations
}

final class NearestStationsService: NearestStationsServiceProtocol {

  private let client: Client 

  private let apikey: String 
  
  init(client: Client, apikey: String) {
    self.client = client
    self.apikey = apikey
  }
  
  func getNearestStations(lat: Double, lng: Double, distance: Int) async throws -> NearestStations {

      let response = try await client.getNearestStations(query: .init(
          apikey: apikey,
          lat: lat,
          lng: lng,
          distance: distance
      ))

      guard case let .ok(okResponse) = response else {
          throw URLError(.badServerResponse)
      }

      return try okResponse.body.json
  }
}
