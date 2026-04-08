import Foundation
import SwiftUI

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var isAuthenticated: Bool = false

    var isLoginValid: Bool {
        !email.isEmpty && !password.isEmpty && password.count >= 6
    }

    var isRegisterValid: Bool {
        !email.isEmpty && 
        !password.isEmpty && 
        !confirmPassword.isEmpty &&
        password == confirmPassword &&
        password.count >= 6
    }

    func login() async -> Bool {
        isLoading = true
        errorMessage = nil

        defer { isLoading = false }

        guard isLoginValid else {
            errorMessage = "Email y contraseña son requeridos"
            return false
        }

        return true
    }

    func register() async -> Bool {
        isLoading = true
        errorMessage = nil

        defer { isLoading = false }

        guard isRegisterValid else {
            if password != confirmPassword {
                errorMessage = "Las contraseñas no coinciden"
            } else if password.count < 6 {
                errorMessage = "La contraseña debe tener al menos 6 caracteres"
            } else {
                errorMessage = "Todos los campos son requeridos"
            }
            return false
        }

        return true
    }

    func logout() {
        isAuthenticated = false
        email = ""
        password = ""
        confirmPassword = ""
    }

    func clearError() {
        errorMessage = nil
    }
}