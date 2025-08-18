import SwiftUI

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
