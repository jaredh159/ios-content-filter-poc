import FamilyControls
import NetworkExtension
import SwiftUI

struct ContentView: View {
  @State private var authorized: Bool? = nil
  @State private var messages: [String] = []
  @State private var isChild = true

  var body: some View {
    VStack {
      if authorized != true {
        VStack {
          Toggle(self.isChild ? "Child" : "Individual", isOn: self.$isChild)
          Spacer().frame(height: 20)
          Button("Request permission to block images") {
            print("requesting authorization...")
            Task { self.authorized = await requestAuthorization() }
          }
        }
      } else {
        Button("Block unwanted images") {
          print("Saving configuration...")
          Task { try await saveConfiguration() }
        }
      }
      Spacer().frame(height: 20)
      ForEach(self.messages, id: \.self) { msg in
        Text(msg).font(.footnote)
      }
    }
    .padding()
  }

  func requestAuthorization() async -> Bool {
    let center = AuthorizationCenter.shared
    do {
      try await center.requestAuthorization(for: self.isChild ? .child : .individual)
      self.messages.append("reqAuthorization success")
      return true
    } catch {
      self.messages.append("reqAuthorization failure")
      self.messages.append("error \(error)")
      self.messages.append("e reflect: \(String(reflecting: error))")
      return false
    }
  }

  func saveConfiguration() async throws {
    _ = try? await NEFilterManager.shared().loadFromPreferences()
    do {
      try await NEFilterManager.shared().removeFromPreferences()
      self.messages.append("saveConfiguration removeFromPrefs success")
    } catch {
      dump(error)
      print("err is \(error)")
      self.messages.append("saveConfiguration removeFromPrefs error: \(error)")
    }
    if NEFilterManager.shared().providerConfiguration == nil {
      self.messages.append("providerConfiguration == nil")
      let newConfiguration = NEFilterProviderConfiguration()
      newConfiguration.username = "IOSPoc"
      newConfiguration.organization = "GertrudeSkunk"
      newConfiguration.filterBrowsers = true
      newConfiguration.filterSockets = true
      NEFilterManager.shared().providerConfiguration = newConfiguration
    } else {
      self.messages.append("providerConfiguration != nil")
    }
    NEFilterManager.shared().isEnabled = true
    NEFilterManager.shared().saveToPreferences { error in
      if let error {
        dump(error)
        // 3 is stale?
        print("Failed to save the filter configuration: \(error)")
        self.messages.append("failed to save filter config \(error)")
        self.messages.append("e2 reflect: \(String(reflecting: error))")
      } else {
        print("Saved filter config successfully")
        self.messages.append("saved filter config success")
      }
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
