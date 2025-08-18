import SwiftUI

// MARK: - Root
struct ContentView: View {
    enum Tab { case schedule, settings }
    @State private var tab: Tab = .schedule

    var body: some View {
        TabView(selection: $tab) {
            NavigationStack { ScheduleScreen() }
                .tabItem {
                    Image("Schedule").renderingMode(.template)
                    Text("Расписание")
                }
                .tag(Tab.schedule)

            NavigationStack { SettingsScreen() }
                .tabItem {
                    Image("Settings").renderingMode(.template)
                    Text("Настройки")
                }
                .tag(Tab.settings)
        }
        .tint(.black)
    }
}

// MARK: - Schedule
struct ScheduleScreen: View {
    @State private var from: String = ""
    @State private var to: String = ""

    @State private var showFromSearch = false
    @State private var showToSearch = false

    private let stories: [Story] = [
        .init(image: "story1", title: "Text Text"),
        .init(image: "story2", title: "Text Text"),
        .init(image: "story3", title: "Text Text"),
        .init(image: "story4", title: "Text Text"),
    ]

    var canSearch: Bool { !from.isEmpty && !to.isEmpty }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {

                // Сторис (пока без действия)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(stories) { story in
                            StoryCard(story: story)
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.top, 24)

                // Панель "Откуда / Куда"
                SearchPanel(
                    from: $from,
                    to: $to,
                    onSwap: { swap(&from, &to) },
                    onFromTap: { showFromSearch = true },
                    onToTap:   { showToSearch = true }
                )
                .padding(.horizontal, 20)

                // Кнопка "Найти" (когда оба поля заполнены)
                if canSearch {
                    NavigationLink {
                        ResultsView(from: from, to: to)
                    } label: {
                        Text("Найти")
                            .font(.headline)
                            .frame(maxWidth: .infinity, minHeight: 52)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
                    }
                    .padding(.horizontal, 20)
                    .transition(.opacity)
                }
            }
        }
        .background(Color(.systemBackground))
        .animation(.easeInOut, value: canSearch)

        .navigationDestination(isPresented: $showFromSearch) {
            CitySearchView(title: "Откуда", selection: $from)
        }
        .navigationDestination(isPresented: $showToSearch) {
            CitySearchView(title: "Куда", selection: $to)
        }
    }
}

// MARK: - Story
struct Story: Identifiable { let id = UUID(); let image: String; let title: String }

struct StoryCard: View {
    let story: Story

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Image(story.image)
                .resizable()
                .scaledToFill()
                .clipped()

            Text(story.title)
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(.white)
                .padding(8)
        }
        .frame(width: 92, height: 140)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.blue.opacity(0.7), lineWidth: 3)
        )
    }
}

// MARK: - Панель поиска
struct SearchPanel: View {
    @Binding var from: String
    @Binding var to: String
    var onSwap: () -> Void
    var onFromTap: () -> Void
    var onToTap: () -> Void

    var body: some View {
        ZStack {
            // Внешний синий контейнер
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .foregroundColor(.blueUniversal)
                .frame(height: 128)

            // Белая вставка
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.white)
                .padding(.vertical, 16)
                .padding(.leading, 16)
                .padding(.trailing, 68)

            // Кликабельные строки
            VStack(alignment: .leading, spacing: 0) {
                Button(action: onFromTap) {
                    HStack {
                        Text(from.isEmpty ? "Откуда" : from)
                            .font(.system(size: 17, weight: .regular))
                            .foregroundStyle(from.isEmpty ? .gray : .primary)
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
                            .foregroundStyle(to.isEmpty ? .gray : .primary)
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
        .padding(.top, 20)
    }
}

// MARK: - Результаты (заглушка)
struct ResultsView: View {
    let from: String
    let to: String

    var body: some View {
        VStack(spacing: 12) {
            Text("Результаты")
                .font(.title2.weight(.semibold))
            Text("\(from) → \(to)")
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

// MARK: - Preview
#Preview { ContentView() }
