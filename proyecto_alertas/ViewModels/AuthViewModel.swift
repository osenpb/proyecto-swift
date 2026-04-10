import Foundation
import SwiftUI
import Combine
import FirebaseAuth

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

        do {
            try await Auth.auth().signIn(withEmail: email, password: password)
            isAuthenticated = true
            return true
        } catch let error as NSError {
            errorMessage = mapFirebaseError(error)
            return false
        }
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

        do {
            try await Auth.auth().createUser(withEmail: email, password: password)
            isAuthenticated = true
            return true
        } catch let error as NSError {
            errorMessage = mapFirebaseError(error)
            return false
        }
    }

    func logout() {
        do {
            try Auth.auth().signOut()
        } catch {
            print("Error al cerrar sesión: \(error)")
        }
        isAuthenticated = false
        email = ""
        password = ""
        confirmPassword = ""
    }

    func clearError() {
        errorMessage = nil
    }

    // MARK: - Mapeo de errores Firebase → español
    private func mapFirebaseError(_ error: NSError) -> String {
        guard let code = AuthErrorCode(rawValue: error.code) else {
            return "Ocurrió un error inesperado. Intenta de nuevo."
        }
        switch code {
        case .emailAlreadyInUse:  return "Este email ya está registrado."
        case .invalidEmail:       return "El formato del email no es válido."
        case .weakPassword:       return "La contraseña debe tener al menos 6 caracteres."
        case .wrongPassword:      return "Contraseña incorrecta."
        case .userNotFound:       return "No existe una cuenta con este email."
        case .networkError:       return "Error de conexión. Verifica tu internet."
        case .tooManyRequests:    return "Demasiados intentos. Intenta más tarde."
        default:                  return "Ocurrió un error inesperado. Intenta de nuevo."
        }
    }
}
