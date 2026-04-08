import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = AuthViewModel()
    @Binding var isAuthenticated: Bool
    var onShowRegister: (() -> Void)?

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "1A1A2E")
                    .ignoresSafeArea()

                VStack(spacing: 24) {
                    Spacer()

                    VStack(spacing: 8) {
                        Image(systemName: "shield.checkered")
                            .font(.system(size: 60))
                            .foregroundStyle(.orange)

                        Text("Alertas de Robo")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)

                        Text("Ingresa para reportar y ver incidentes")
                            .font(.subheadline)
                            .foregroundStyle(.gray)
                    }

                    Spacer()

                    VStack(spacing: 16) {
                        CustomTextField(
                            placeholder: "Email",
                            text: $viewModel.email,
                            icon: "envelope.fill",
                            keyboardType: .emailAddress,
                            autocapitalization: .never
                        )

                        CustomTextField(
                            placeholder: "Contraseña",
                            text: $viewModel.password,
                            icon: "lock.fill",
                            isSecure: true
                        )

                        if let error = viewModel.errorMessage {
                            Text(error)
                                .font(.caption)
                                .foregroundStyle(.red)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }

                        Button {
                            Task {
                                if await viewModel.login() {
                                    isAuthenticated = true
                                }
                            }
                        } label: {
                            PrimaryButton(title: "Iniciar Sesión", isLoading: viewModel.isLoading)
                        }
                        .disabled(!viewModel.isLoginValid)
                        .opacity(viewModel.isLoginValid ? 1 : 0.6)
                    }
                    .padding(.horizontal, 24)

                    Spacer()

                    HStack {
                        Text("¿No tienes cuenta?")
                            .foregroundStyle(.gray)
                        Button("Regístrate") {
                            onShowRegister?()
                        }
                        .foregroundStyle(.orange)
                        .fontWeight(.semibold)
                    }
                    .padding(.bottom, 32)
                }
            }
        }
    }
}

struct CustomTextField: View {
    let placeholder: String
    @Binding var text: String
    var icon: String?
    var keyboardType: UIKeyboardType = .default
    var autocapitalization: TextInputAutocapitalization = .sentences
    var isSecure: Bool = false

    var body: some View {
        HStack(spacing: 12) {
            if let icon = icon {
                Image(systemName: icon)
                    .foregroundStyle(.gray)
            }

            if isSecure {
                SecureField(placeholder, text: $text)
                    .foregroundStyle(.white)
            } else {
                TextField(placeholder, text: $text)
                    .keyboardType(keyboardType)
                    .textInputAutocapitalization(autocapitalization)
                    .foregroundStyle(.white)
            }
        }
        .padding()
        .background(Color(hex: "2D2D44"))
        .cornerRadius(12)
    }
}

struct PrimaryButton: View {
    let title: String
    var isLoading: Bool = false

    var body: some View {
        ZStack {
            if isLoading {
                ProgressView()
                    .tint(.white)
            } else {
                Text(title)
                    .fontWeight(.semibold)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.orange)
        .foregroundStyle(.white)
        .cornerRadius(12)
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    LoginView(isAuthenticated: .constant(false), onShowRegister: {})
}