final class YandexScheduleAPI {
    let nearestStations: NearestStationsServiceProtocol
    let nearestCity: NearestCityServiceProtocol
    let routeSearch: RouteSearchServiceProtocol
    let copyright: CopyrightServiceProtocol
    let carrierInfo: CarrierInfoServiceProtocol

    init(client: Client, apikey: String) {
        self.nearestStations = NearestStationsService(client: client, apikey: apikey)
        self.nearestCity = NearestCityService(client: client, apikey: apikey)
        self.routeSearch = RouteSearchService(client: client, apikey: apikey)
        self.copyright = CopyrightService(client: client, apikey: apikey)
        self.carrierInfo = CarrierInfoService(client: client, apikey: apikey)
    }
}
