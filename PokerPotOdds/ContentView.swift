import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            SimulationView()
                .tabItem {
                    Label("Simulation", systemImage: "die.face.5")
                }
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}


#Preview {
    ContentView()
}

