import Foundation
import Combine

@MainActor
final class ScheduleViewModel: ObservableObject {
    @Published var from = StationSelection()
    @Published var to   = StationSelection()
    
    
    @Published var viewedStories: Set<Int> = []
    @Published var currentStoryIndex: Int? = nil
    @Published var showStory = false
    
    @Published var showFromSearch = false
    @Published var showToSearch = false
    
    let stories: [Stories] = [.story1, .story2, .story3, .story4, .story5, .story6]
    let stationsVM: AllStationsViewModel
    let api: YandexScheduleAPI
    let locationService: LocationServiceProtocol
    
    init(api: YandexScheduleAPI) {
        self.api = api
        self.locationService = LocationService()
        self.stationsVM = AllStationsViewModel(api: api)
    }
    
    var canSearch: Bool { !from.isEmpty && !to.isEmpty }
    
    func swapStations() {
        swap(&from, &to)
    }
    
    func openStory(at index: Int) {
        viewedStories.insert(index)
        currentStoryIndex = index
        showStory = true
    }
    
    func closeStory() {
        showStory = false
    }
}
