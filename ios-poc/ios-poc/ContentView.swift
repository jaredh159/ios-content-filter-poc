import App
import ComposableArchitecture
import SwiftUI

struct Foo: View {
  var body: some View {
    Image("GertrudeIcon")
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    Foo()
//    ContentView(
//      store: Store(initialState: .init(appState: .installFailed(.configurationPermissionDenied))) {
//        AppReducer()
//      }
//    )
  }
}
