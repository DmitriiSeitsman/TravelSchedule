import OpenAPIRuntime

struct ScheduleResponse: Codable {
    let search: SearchInfo
    let segments: [Segment]
    let intervalSegments: [Segment]
    let pagination: Pagination
}
struct TicketsInfo: Codable {
    let etMarker: Bool
    let places: [TicketPlace]
}

struct TicketPlace: Codable {
    let currency: String
    let price: Price
    let name: String
}

struct Price: Codable {
    let whole: Int
    let cents: Int
}

struct SearchInfo: Codable {
    let from: Station
    let to: Station
    let date: String
}

struct Station: Codable {
    let code: String
    let title: String
    let stationType: String
    let transportType: String
}

struct Segment: Codable {
    let thread: ThreadInfo
    let from: Station
    let to: Station
    let departure: String
    let arrival: String
    let duration: Double
    let ticketsInfo: TicketsInfo?
}

struct ThreadInfo: Codable {
    let number: String
    let title: String
    let transportType: String
}

struct Pagination: Codable {
    let total: Int
    let limit: Int
    let offset: Int
}
