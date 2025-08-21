import SwiftUI

struct SettingsScreen: View {
    @State private var showConnectionError = false
    @State private var showServerError = false

    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 12) {
                Image("Settings").renderingMode(.template)
                    .font(.system(size: 36))
                Text("Настройки")
                    .font(.title3.weight(.semibold))
            }
            .foregroundStyle(.secondary)

            // Кнопки вызова заглушек
            VStack(spacing: 12) {
                Button("Показать «нет интернета»") {
                    showConnectionError = true
                }
                .buttonStyle(.borderedProminent)

                Button("Показать «ошибка сервера»") {
                    showServerError = true
                }
                .buttonStyle(.bordered)
            }

            Spacer()
        }
        .padding()
        // Открываем как sheet — можно смахнуть вниз
        .sheet(isPresented: $showConnectionError) {
            ConnectionErrorView()
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showServerError) {
            ServerErrorView()
                .presentationDragIndicator(.visible)
        }
    }
}
#Preview {
    SettingsScreen()
}
