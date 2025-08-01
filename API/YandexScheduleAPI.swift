final class YandexScheduleAPI {
    let nearestStations: NearestStationsServiceProtocol
    let nearestCity: NearestCityServiceProtocol
    let routeSearch: RouteSearchServiceProtocol
    let copyright: CopyrightServiceProtocol
    let carrierInfo: CarrierInfoServiceProtocol
    let allStations: AllStationsServiceProtocol
    let stationSchedule: StationScheduleServiceProtocol
    let threadStations: ThreadStationsServiceProtocol

    init(client: Client, apikey: String) {
        self.nearestStations = NearestStationsService(client: client, apikey: apikey)
        self.nearestCity = NearestCityService(client: client, apikey: apikey)
        self.routeSearch = RouteSearchService(client: client, apikey: apikey)
        self.copyright = CopyrightService(client: client, apikey: apikey)
        self.carrierInfo = CarrierInfoService(client: client, apikey: apikey)
        self.allStations = AllStationsService(client: client, apikey: apikey)
        let stationScheduleService = StationScheduleService(client: client, apikey: apikey)
        self.stationSchedule = stationScheduleService
        self.threadStations = ThreadStationsService(
            client: client,
            apikey: apikey,
            stationScheduleService: stationScheduleService
        )
    }
}


