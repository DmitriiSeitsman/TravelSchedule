import SwiftUI

//struct SettingsScreen: View {
//    @AppStorage("isDarkMode") private var isDarkMode = false
//    @State private var showAgreement = false
//
//    var body: some View {
//        NavigationStack {
//            VStack(spacing: 0) {
//                HStack(spacing: 0) {
//                    Text("Тёмная тема")
//                        .font(.system(size: 17, weight: .regular))
//                        .foregroundColor(.ypBlack)
//                        .frame(maxWidth: .infinity, alignment: .leading)
//
//                    Toggle("", isOn: $isDarkMode)
//                        .labelsHidden()
//                        .tint(.blueUniversal)
//                }
//                .frame(height: 56)
//                .padding(.horizontal, 16)
//
//                Button {
//                    showAgreement = true
//                } label: {
//                    HStack(spacing: 0) {
//                        Text("Пользовательское соглашение")
//                            .font(.system(size: 17, weight: .regular))
//                            .foregroundColor(.ypBlack)
//                            .frame(maxWidth: .infinity, alignment: .leading)
//
//                        Image(systemName: "chevron.right")
//                            .font(.system(size: 17, weight: .regular))
//                            .foregroundColor(.ypBlack)
//                    }
//                    .contentShape(Rectangle())
//                }
//                .buttonStyle(.plain)
//                .frame(height: 56)
//                .padding(.horizontal, 16)
//
//                Spacer()
//            }
//            .navigationTitle("")
//            .navigationBarTitleDisplayMode(.inline)
//            .background(Color(.systemBackground))
//
//            .safeAreaInset(edge: .bottom) {
//                VStack(spacing: 6) {
//                    Text("Приложение использует API «Яндекс.Расписания»")
//                        .font(.system(size: 12, weight: .regular))
//                        .foregroundColor(.ypBlack)
//
//                    Text("Версия 1.0 (beta)")
//                        .font(.system(size: 12, weight: .regular))
//                        .foregroundColor(.ypBlack)
//                }
//                .frame(maxWidth: .infinity, alignment: .center)
//                .padding(.vertical, 12)
//            }
//            .navigationDestination(isPresented: $showAgreement) {
//                UserAgreementView()
//            }
//        }
//    }
//}
//
//// Заглушка экрана соглашения
//private struct UserAgreementView: View {
//    var body: some View {
//        ScrollView {
//            Text("Текст пользовательского соглашения…")
//                .padding(16)
//        }
//        .navigationTitle("Пользовательское соглашение")
//        .navigationBarTitleDisplayMode(.inline)
//    }
//}
//

struct SettingsScreen: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    @State private var showAgreement = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // контент
                VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        Text("Тёмная тема")
                            .font(.system(size: 17, weight: .regular))
                            .foregroundColor(.ypBlack)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Toggle("", isOn: $isDarkMode)
                            .labelsHidden()
                            .tint(.blueUniversal)
                    }
                    .frame(height: 56)
                    .padding(.horizontal, 16)

                    Button {
                        showAgreement = true
                    } label: {
                        HStack(spacing: 0) {
                            Text("Пользовательское соглашение")
                                .font(.system(size: 17, weight: .regular))
                                .foregroundColor(.ypBlack)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            Image(systemName: "chevron.right")
                                .font(.system(size: 17, weight: .regular))
                                .foregroundColor(.ypBlack)
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .frame(height: 56)
                    .padding(.horizontal, 16)
                }
                .padding(.top, 24) // отступ сверху от status bar

                Spacer()
            }
            .padding(.bottom, 24) // отступ сверху от tab bar
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color(.systemBackground))
            .safeAreaInset(edge: .bottom) {
                VStack(spacing: 6) {
                    Text("Приложение использует API «Яндекс.Расписания»")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.ypBlack)

                    Text("Версия 1.0 (beta)")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.ypBlack)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 12)
            }
            .navigationDestination(isPresented: $showAgreement) {
                CopyrightView()
            }
        }
    }
}

#Preview {
    SettingsScreen()
}
