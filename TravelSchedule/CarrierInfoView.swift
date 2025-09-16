import SwiftUI
import OpenAPIURLSession

struct CarrierInfoView: View {
    let api: YandexScheduleAPIProtocol
    let carrierCode: String
    let system: String
    let fallbackCarrier: Components.Schemas.Carrier?
    
    @State private var carrier: Components.Schemas.Carrier?
    @State private var isLoading = false
    @State private var showConnectionError = false
    @State private var showServerError = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                
                // Логотип
                if let logo = carrier?.logo,
                   let url = URL(string: logo.hasPrefix("http") ? logo : "https:" + logo) {
                    HStack {
                        Spacer()
                        AsyncImage(url: url) { image in
                            image.resizable()
                                .scaledToFit()
                                .frame(height: 104)
                        } placeholder: {
                            ProgressView()
                        }
                        Spacer()
                    }
                    .padding(.top, 16)
                }
                
                // Название
                Text(formattedTitle(carrier?.title ?? "Без названия"))
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.ypBlack)
                    .padding(.top, 8)
                
                // Email
                infoBlock(title: "E-mail", value: extractedEmail(), linkPrefix: "mailto:")
                    .padding(.top, 8)
                
                // Телефон
                infoBlock(title: "Телефон", value: extractedPhone(), linkPrefix: "tel:", applyDigits: true)
                
                // Сайт
                if let urlString = carrier?.url,
                   let url = URL(string: urlString) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Сайт")
                            .font(.system(size: 17))
                            .foregroundColor(.ypBlack)
                        
                        Link(urlString, destination: url)
                            .font(.system(size: 12))
                            .foregroundColor(.blueUniversal)
                    }
                }
                
                Spacer(minLength: 24)
            }
            .padding(.horizontal, 16)
        }
        .navigationTitle("Информация о перевозчике")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemBackground))
        .onAppear { loadCarrierInfo() }
        // Навигация на экраны ошибок
        .navigationDestination(isPresented: $showConnectionError) {
            ConnectionErrorView()
                .toolbar(.hidden, for: .tabBar)
        }
        .navigationDestination(isPresented: $showServerError) {
            ServerErrorView()
                .toolbar(.hidden, for: .tabBar)
        }
    }
    
    // MARK: - Helpers
    private func loadCarrierInfo() {
        isLoading = true
        
        let api = self.api
        
        Task {
            if carrierCode.isEmpty || !["iata", "icao", "sirena"].contains(system.lowercased()) {
                await MainActor.run {
                    self.carrier = fallbackCarrier
                    self.isLoading = false
                }
                return
            }
            
            do {
                let result = try await api.getCarrierInfo(code: carrierCode, system: system)
                await MainActor.run {
                    if let carrier = result.carrier {
                        self.carrier = carrier
                    } else if let carriers = result.carriers, !carriers.isEmpty {
                        self.carrier = carriers.first
                    } else {
                        self.carrier = fallbackCarrier
                    }
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                    if let urlError = error as? URLError {
                        switch urlError.code {
                        case .notConnectedToInternet, .timedOut, .cannotFindHost, .cannotConnectToHost:
                            self.showConnectionError = true
                        default:
                            self.showServerError = true
                        }
                    } else {
                        self.showServerError = true
                    }
                }
            }
        }
    }

    
    private func formattedTitle(_ raw: String) -> String {
        let cleaned = raw.replacingOccurrences(of: "/ФПК", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
        if cleaned.lowercased().contains("ржд") {
            return "ОАО «РЖД»"
        }
        return cleaned
    }
    
    private func extractedEmail() -> String? {
        if let email = carrier?.email, !email.isEmpty {
            return email
        }
        if let contacts = carrier?.contacts,
           let match = contacts.range(
            of: "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}",
            options: .regularExpression
           ) {
            return String(contacts[match])
        }
        return nil
    }
    
    private func extractedPhone() -> String? {
        if let phone = carrier?.phone, !phone.isEmpty {
            return phone
        }
        if let contacts = carrier?.contacts,
           let match = contacts.range(
            of: "\\+?[0-9][0-9\\-\\s()]{5,}",
            options: .regularExpression
           ) {
            return String(contacts[match])
        }
        return nil
    }
    
    private func digits(from phone: String) -> String {
        phone.filter { "0123456789+".contains($0) }
    }
    
    @ViewBuilder
    private func infoBlock(title: String, value: String?, linkPrefix: String, applyDigits: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 17))
                .foregroundColor(.ypBlack)
            
            if let value = value, !value.isEmpty {
                let linkValue = applyDigits ? digits(from: value) : value
                if let url = URL(string: "\(linkPrefix)\(linkValue)") {
                    Link(value, destination: url)
                        .font(.system(size: 12))
                        .foregroundColor(.blueUniversal)
                } else {
                    Text(value)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
            } else {
                Text("—")
                    .foregroundStyle(.secondary)
                    .font(.system(size: 17))
            }
        }
    }
}
