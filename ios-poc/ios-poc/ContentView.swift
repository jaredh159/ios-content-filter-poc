import SwiftUI
import FamilyControls
import NetworkExtension


struct ContentView: View {
  @State private var authorized: Bool? = nil
  
  var body: some View {
    VStack {
      if authorized == nil {
        ProgressView()
      } else if authorized == false {
        Button("Request auth") {
          print("requesting authorization...")
          Task { self.authorized = await requestAuthorization() }
        }
      } else {
        Button("Try save filter config") {
          print("Saving configuration...")
          Task { try await saveConfiguration() }
        }
      }
    }
    .padding()
    .task {
      self.authorized = await requestAuthorization()
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}


func requestAuthorization() async -> Bool {
  let center = AuthorizationCenter.shared
  do {
    try await center.requestAuthorization(for: .individual)
    return true
  } catch {
    return false
  }
}

func saveConfiguration() async throws {
  try await NEFilterManager.shared().removeFromPreferences()
  if NEFilterManager.shared().providerConfiguration == nil {
    let newConfiguration = NEFilterProviderConfiguration()
    newConfiguration.filterBrowsers = true
    NEFilterManager.shared().providerConfiguration = newConfiguration
  }
  NEFilterManager.shared().isEnabled = true
  NEFilterManager.shared().saveToPreferences { error in
    if let error {
      dump(error)
      // 3 is stale?
      print("Failed to save the filter configuration: \(error)")
    } else {
      print("Saved filter config successfully")
    }
  }
}

