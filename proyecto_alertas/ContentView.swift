import SwiftUI
import FirebaseAuth

struct ContentView: View {
    @State private var isAuthenticated: Bool = false
    @State private var showRegister: Bool = false

    var body: some View {
        Group {
            if isAuthenticated {
                DashboardView(isAuthenticated: $isAuthenticated)
            } else if showRegister {
                RegisterView(isAuthenticated: $isAuthenticated) {
                    showRegister = false
                }
            } else {
                LoginView(isAuthenticated: $isAuthenticated) {
                    showRegister = true
                }
            }
        }
        .onAppear {
            isAuthenticated = Auth.auth().currentUser != nil
        }
        .animation(.easeInOut, value: isAuthenticated)
    }
}

#Preview {
    ContentView()
}
