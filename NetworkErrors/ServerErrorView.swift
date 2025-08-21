import SwiftUI

struct ServerErrorView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image("ServerError")
                .resizable()
                .scaledToFit()
                .frame(width: 223, height: 223)
                .accessibilityHidden(true)

            Text("ошибка сервера")
                .font(.system(size: 24, weight: .bold))
                .multilineTextAlignment(.center)
        }
        .padding(24)
    }
}
