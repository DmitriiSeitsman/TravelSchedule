import SwiftUI

struct SettingsScreen: View {
    @State private var showConnectionError = false
    @State private var showServerError = false

    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 12) {
                Image("Settings").renderingMode(.template)
                    .font(.system(size: 36))
                    .foregroundColor(.ypBlack)
                Text("Настройки")
                    .font(.title3.weight(.semibold))
                    .foregroundColor(.ypBlack)
            }
            .foregroundStyle(.secondary)

            VStack(spacing: 12) {
                Button("Показать «нет интернета»") {
                    showConnectionError = true
                }
                .buttonStyle(.bordered)

                Button("Показать «ошибка сервера»") {
                    showServerError = true
                }
                .buttonStyle(.bordered)
            }

            Spacer()
        }
        .padding()
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
