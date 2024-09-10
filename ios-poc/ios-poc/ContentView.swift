import FamilyControls
import NetworkExtension
import SwiftUI

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
  _ = try? await NEFilterManager.shared().loadFromPreferences()
  do {
    try await NEFilterManager.shared().removeFromPreferences()
  } catch {
    dump(error)
    print("err is \(error)")
  }
  if NEFilterManager.shared().providerConfiguration == nil {
    let newConfiguration = NEFilterProviderConfiguration()
    newConfiguration.username = "IOSPoc"
    newConfiguration.organization = "Gertrude"
    newConfiguration.filterBrowsers = true
    newConfiguration.filterSockets = true
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
