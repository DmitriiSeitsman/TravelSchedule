import OpenAPIURLSession

struct APIProvider {
    static func makeDefault() -> YandexScheduleAPI {
        let client = Client(
            serverURL: try! Servers.Server1.url(),
            transport: URLSessionTransport()
        )
        let apikey = API.key
        return YandexScheduleAPI(client: client, apikey: apikey)
    }
}
