import SwiftUI
import OpenAPIURLSession

// MARK: - Root
struct ContentView: View {
    enum selectedTab { case schedule, settings }
    @State private var tab: selectedTab = .schedule
    
    var body: some View {
        TabView(selection: $tab) {
            NavigationStack { ScheduleScreen() }
                .tabItem { Image("Schedule").renderingMode(.template) }
                .tag(selectedTab.schedule)
            
            NavigationStack { SettingsScreen() }
                .tabItem { Image("Settings").renderingMode(.template) }
                .tag(selectedTab.settings)
        }
        .tint(.ypBlack)
    }
}

// MARK: - Schedule
struct ScheduleScreen: View {
    @State private var from = StationSelection()
    @State private var to   = StationSelection()
    
    // stories
    @State private var viewedStories: Set<Int> = []
    @State private var currentStoryIndex: Int? = nil
    @State private var showStory = false
    
    private let stories: [Stories] = [.story1, .story2, .story3, .story4, .story5, .story6]
    
    @State private var showFromSearch = false
    @State private var showToSearch = false
    @StateObject private var stationsVM: AllStationsViewModel
    private let api: YandexScheduleAPI
    
    private var fromText: Binding<String> {
        Binding(get: { from.displayText }, set: { from.displayText = $0 })
    }
    private var toText: Binding<String> {
        Binding(get: { to.displayText }, set: { to.displayText = $0 })
    }
    
    init() {
        guard let url = URL(string: "https://api.rasp.yandex.net") else {
            fatalError("Invalid base URL for YandexScheduleAPI")
        }
        let api = YandexScheduleAPI(
            client: Client(serverURL: url, transport: URLSessionTransport()),
            apikey: API.key
        )
        self.api = api
        _stationsVM = StateObject(wrappedValue: AllStationsViewModel(api: api))
    }
    
    private let locationService: LocationServiceProtocol = LocationService()
    var canSearch: Bool { !from.isEmpty && !to.isEmpty }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(stories.indices, id: \.self) { i in
                            let s = stories[i]
                            StoryCard(story: s, isViewed: viewedStories.contains(i))
                                .onTapGesture {
                                    viewedStories.insert(i)
                                    currentStoryIndex = i
                                    showStory = true
                                }
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.vertical, 24)
                
                SearchPanel(
                    from: fromText,
                    to: toText,
                    onSwap: { swap(&from, &to) },
                    onFromTap: { showFromSearch = true },
                    onToTap: { showToSearch = true }
                )
                .padding(.top, 20)
                .padding([.horizontal, .bottom], 16)
                if canSearch {
                    NavigationLink {
                        ResultsView(from: from.displayText, to: to.displayText)
                    } label: {
                        Text("Найти")
                            .font(.system(size: 17, weight: .bold))
                            .frame(width: 150, height: 60)
                            .background(.blueUniversal)
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                }
            }
        }
        
        .navigationDestination(isPresented: $showFromSearch) {
            CitySearchView(
                title: "Откуда",
                selection: fromText,
                stationsVM: stationsVM,
                locationService: locationService,
                api: api
            )
            .toolbar(.hidden, for: .tabBar)
        }
        .navigationDestination(isPresented: $showToSearch) {
            CitySearchView(
                title: "Куда",
                selection: toText,
                stationsVM: stationsVM,
                locationService: locationService,
                api: api
            )
            .toolbar(.hidden, for: .tabBar)
        }
        .fullScreenCover(isPresented: $showStory) {
            if let idx = currentStoryIndex {
                MainStoryView(
                    stories: stories,
                    startIndex: idx,
                    onClose: { showStory = false }
                )
            }
        }
    }
}


// MARK: - Story card
struct StoryCard: View {
    let story: Stories
    let isViewed: Bool
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            if let img = story.backgroundImage {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 92, height: 140)
                    .clipped()
            } else {
                story.backgroundColor
            }
            
            if !isViewed {
                Color.white.opacity(0.5)
            }
            
            Text(story.description)
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(.white)
                .lineLimit(3)
                .multilineTextAlignment(.leading)
                .padding(.horizontal, 8)
                .padding(.bottom, 12)
                .shadow(radius: 2)
        }
        .frame(width: 92, height: 140)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(isViewed ? Color.blueUniversal : Color.clear, lineWidth: 3)
        )
    }
}

// MARK: - Панель поиска
struct SearchPanel: View {
    @Binding var from: String
    @Binding var to: String
    let onSwap: () -> Void
    let onFromTap: () -> Void
    let onToTap: () -> Void
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .foregroundColor(.blueUniversal)
                .frame(height: 128)
            
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.whiteUniversal)
                .padding([.vertical, .leading], 16)
                .padding(.trailing, 68)
            
            VStack(alignment: .leading, spacing: 0) {
                Button(action: onFromTap) {
                    HStack {
                        Text(from.isEmpty ? "Откуда" : from)
                            .font(.system(size: 17, weight: .regular))
                            .foregroundStyle(from.isEmpty ? .gray : .blackUniversal)
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .frame(height: 48)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                
                Button(action: onToTap) {
                    HStack {
                        Text(to.isEmpty ? "Куда" : to)
                            .font(.system(size: 17, weight: .regular))
                            .foregroundStyle(to.isEmpty ? .gray : .blackUniversal)
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .frame(height: 48)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
        }
        .overlay(alignment: .trailing) {
            Button(action: onSwap) {
                Image("ChangeButton")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 36, height: 36)
            }
            .padding(.trailing, 16)
        }
    }
}

// MARK: - Preview
#Preview { ContentView() }
