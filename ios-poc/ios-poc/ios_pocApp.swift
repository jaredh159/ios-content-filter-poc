import App
import SwiftUI
import ComposableArchitecture

@main
struct ios_pocApp: App {
  var body: some Scene {
    WindowGroup {
      ContentView(store: Store(initialState: .init()) {
        AppReducer()
      })
    }
  }
}
