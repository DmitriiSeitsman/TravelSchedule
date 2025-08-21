import SwiftUI

struct ConnectionErrorView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image("ConnectionError")
                .resizable()
                .scaledToFit()
                .frame(width: 223, height: 223)
                .accessibilityHidden(true)

            Text("нет интернета")
                .font(.system(size: 24, weight: .bold))
                .multilineTextAlignment(.center)
        }
        .padding(24)
    }
}
