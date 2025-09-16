import SwiftUI

// MARK: - Models + Mock
struct SegmentItem: Identifiable, Hashable {
    let id: String
    let carrierName: String
    let carrierCode: String
    let carrierLogo: String?
    let departureDateShort: String
    let departureTime: String
    let arrivalTime: String
    let durationText: String
    let transferText: String?
    let hasTransfers: Bool?
    let carrierCodes: Components.Schemas.Carrier
    let transportType: String?
}


// MARK: - Placeholder
struct ContentPlaceholder: View {
    let systemImage: String
    let title: String
    let subtitle: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: systemImage).font(.system(size: 44))
                .foregroundStyle(.secondary)
            Text(title).font(.headline)
            Text(subtitle)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

//// MARK: - Preview
//#Preview {
//    ResultsView(from: "Москва (Ярославский вокзал)", to: "Санкт-Петербург (Балтийский вокзал)")
//}
