import SwiftUI
import Foundation

import FamilyControls
import NetworkExtension



struct ContentView: View {
  var body: some View {
    VStack {
      Button("request auth") {
        // todo:
        print("do it")
        Task {
         try? await reqAuth()
        }
      }
      Button("install filter") {
        // todo:
        print("but how?")
        activateExt()
      }
    }
    .padding()
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}


//@MainActor
func reqAuth() async throws {
  let center = AuthorizationCenter.shared
  
  // this might be ios16 only, possibly use request.authorization (comphandler)
  // see https://developer.apple.com/documentation/technotes/tn3134-network-extension-provider-deployment#Deploying-a-content-filter-provider
  try await center.requestAuthorization(for: .individual)
}

func activateExt() {
  if NEFilterManager.shared().providerConfiguration == nil {
    let newConfiguration = NEFilterProviderConfiguration()
    newConfiguration.username = "UserName"
    newConfiguration.organization = "ContentFilterDemoApp "
    newConfiguration.filterBrowsers = true
    newConfiguration.filterSockets = true
    newConfiguration.serverAddress = "http://192.168.100.48:3000" //url of server from where rules will be fetched
    NEFilterManager.shared().providerConfiguration = newConfiguration
  }
  NEFilterManager.shared().isEnabled = true //self.statusCell.isOn
  NEFilterManager.shared().saveToPreferences { error in
    if let  saveError = error {
      print("Failed to save the filter configuration: \(saveError)")
    }
  }
//  let manager = NEFilterManager.shared()
//  let activationRequest = OSSystemExtensionRequest.activationRequest(
//    forExtensionWithIdentifier: FILTER_EXT_BUNDLE_ID,
//    queue: .main
//  )
//  activationRequest.delegate = delegate
//  OSSystemExtensionManager.shared.submitRequest(activationRequest)
//
}

