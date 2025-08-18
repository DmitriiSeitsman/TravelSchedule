import SwiftUI

// MARK: - Root

struct ContentView: View {
    enum Tab { case schedule, settings }
    @State private var tab: Tab = .schedule

    var body: some View {
        TabView(selection: $tab) {
            ScheduleScreen()
                .tabItem {
                    Image("Schedule").renderingMode(.template)
                    Text("Расписание")
                }
                .tag(Tab.schedule)

            SettingsScreen()
                .tabItem {
                    Image("Settings").renderingMode(.template)
                    Text("Настройки")
                }
                .tag(Tab.settings)
        }
        .tint(.black)
    }
}

// MARK: - Schedule (первая вкладка)

struct ScheduleScreen: View {
    @State private var from: String = ""
    @State private var to: String = ""

    private let stories: [Story] = [
        .init(image: "story1", title: "Text Text"),
        .init(image: "story2", title: "Text Text"),
        .init(image: "story3", title: ""),
        .init(image: "story4", title: ""),
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(stories) { story in
                            StoryCard(story: story)
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.top, 24)

                SearchPanel(
                    from: $from,
                    to: $to,
                    onSwap: { swap(&from, &to) },
                    onSubmit: { /* вызвать поиск */ }
                )
                .padding(.horizontal, 20)
            }
        }
        .background(Color(.systemBackground))
    }
}

// MARK: - Settings (вторая вкладка, заглушка)

struct SettingsScreen: View {
    var body: some View {
        VStack(spacing: 12) {
            Image("Settings").renderingMode(.template)
                .font(.system(size: 36))
            Text("Настройки")
                .font(.title3.weight(.semibold))
        }
        .foregroundStyle(.secondary)
    }
}

// MARK: - Вью карточки

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
                .stroke(Color.blue.opacity(0.7), lineWidth: 3) // как на макете
        )
    }
}

// MARK: - Панель поиска (Откуда/Куда)

struct SearchPanel: View {
    @Binding var from: String
    @Binding var to: String
    var onSwap: () -> Void
    var onSubmit: () -> Void = {}

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
                .padding(.trailing, 68) // место под круглую кнопку

            // Поля ввода
            VStack(alignment: .leading) {
                TextField("", text: $from, prompt: Text("Откуда").foregroundStyle(.gray))
                    .font(.system(size: 17, weight: .regular))
                    .textFieldStyle(.plain)
                    .padding(.horizontal, 16)
                    .frame(height: 48)

                TextField("", text: $to, prompt: Text("Куда").foregroundStyle(.gray))
                    .font(.system(size: 17, weight: .regular))
                    .textFieldStyle(.plain)
                    .padding(.horizontal, 16)
                    .frame(height: 48)
            }
            .padding(.horizontal, 16)
        }
        // Кнопка по центру справа
        .overlay(alignment: .trailing) {
            Button(action: onSwap) {
                ZStack {
                    Image("ChangeButton")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 36, height: 36)
                        .foregroundColor(.blue)
                }
            }
            .padding(.trailing, 16)
        }

        .padding(.top, 20)
    }
}

// MARK: - Preview

#Preview {
    ContentView()
}
