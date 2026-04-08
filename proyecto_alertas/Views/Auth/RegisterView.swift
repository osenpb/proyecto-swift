import SwiftUI

struct RegisterView: View {
    @StateObject private var viewModel = AuthViewModel()
    @Binding var isAuthenticated: Bool
    var onShowLogin: (() -> Void)?

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "1A1A2E")
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        Spacer()

                        VStack(spacing: 8) {
                            Image(systemName: "person.badge.plus")
                                .font(.system(size: 60))
                                .foregroundStyle(.orange)

                            Text("Crear Cuenta")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundStyle(.white)

                            Text("Regístrate para reportar incidentes")
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

                            CustomTextField(
                                placeholder: "Confirmar Contraseña",
                                text: $viewModel.confirmPassword,
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
                                    if await viewModel.register() {
                                        isAuthenticated = true
                                    }
                                }
                            } label: {
                                PrimaryButton(title: "Crear Cuenta", isLoading: viewModel.isLoading)
                            }
                            .disabled(!viewModel.isRegisterValid)
                            .opacity(viewModel.isRegisterValid ? 1 : 0.6)
                        }
                        .padding(.horizontal, 24)

                        Spacer()

                        HStack {
                            Text("¿Ya tienes cuenta?")
                                .foregroundStyle(.gray)
                            Button("Inicia Sesión") {
                                onShowLogin?()
                            }
                            .foregroundStyle(.orange)
                            .fontWeight(.semibold)
                        }
                        .padding(.bottom, 32)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    RegisterView(isAuthenticated: .constant(false), onShowLogin: {})
}