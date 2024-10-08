import App
import ComposableArchitecture
import SwiftUI

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView(
      store: Store(initialState: .init(appState: .installFailed(.configurationPermissionDenied))) {
        AppReducer()
      }
    )
  }
}
