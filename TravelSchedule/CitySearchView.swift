import SwiftUI

struct CitySearchView: View {

    let title: String
    @Binding var selection: String
    @Environment(\.dismiss) private var dismiss

    @State private var query: String = ""

    // Stub-данные
    private let allCities: [String]

    init(title: String, selection: Binding<String>, allCities: [String] = [
        "Москва", "Санкт Петербург", "Сочи", "Красноярск",
        "Краснодар", "Казань", "Омск"
    ]) {
        self.title = title
        self._selection = selection
        self.allCities = allCities
    }

    private var filtered: [String] {
        guard !query.isEmpty else { return allCities }
        return allCities.filter { $0.localizedCaseInsensitiveContains(query) }
    }

    var body: some View {
        VStack(spacing: 16) {

            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)

                TextField("Введите запрос", text: $query)
                    .font(.system(size: 17, weight: .regular))
                    .textInputAutocapitalization(.words)
                    .autocorrectionDisabled(true)
            }
            .padding(.vertical, 7)
            .padding(.horizontal, 8)
            .background(Color(.systemGray5))
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .padding(.horizontal, 16)

            List {
                ForEach(filtered, id: \.self) { city in
                    Button {
                        selection = city
                        dismiss()
                    } label: {
                        HStack {
                            Text(city)
                                .foregroundStyle(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 17, weight: .regular))
                                .foregroundStyle(.primary)
                                .foregroundColor(.primary)
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
            .listStyle(.plain)
            .overlay {
                if filtered.isEmpty {
                    ContentUnavailableView(
                        "Город не найден",
                        systemImage: ""
                    )
                    .font(.system(size: 24, weight: .bold))
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.primary)
                        .foregroundColor(.primary)
                        .frame(width: 44, height: 44, alignment: .leading)
                        .contentShape(Rectangle())
                }
            }
            ToolbarItem(placement: .principal) {
                Text("Выбор города")
                    .font(.system(size: 17, weight: .bold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.9)
            }
        }
        .navigationTitle("Выбор города")
        .font(.system(size: 17, weight: .regular))
        .scrollDismissesKeyboard(.immediately)
        .background(Color(.systemBackground))
    }
}

#Preview {
    NavigationStack {
        CitySearchView(title: "Откуда", selection: .constant(""))
    }
}
