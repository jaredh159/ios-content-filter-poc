import ComposableArchitecture
import SwiftUI

public struct ContentView: View {
  let store: StoreOf<AppReducer>

  public init(store: StoreOf<AppReducer>) {
    self.store = store
  }

  public var body: some View {
    VStack {
      switch self.store.appState {
      case .unknown, .authorizing:
        ProgressView()
      case .authorized:
        VStack(spacing: 20) {
          Text("Authorization granted! One more step: install the content filter.")
          Button("Install Filter") {}
        }
      case .authorizationFailed(let reason):
        VStack(spacing: 20) {
          switch reason {
          case .networkError:
            Text(
              "You must be connected to the internet in order to complete the parent/guardian authorization step."
            )
          case .authorizationConflict:
            Text(
              "Failed to authenticate due to conflict. You might already have another app managing parental controls. Disable that app to continue using Gertrude."
            )
          case .invalidAccountType:
            Text("Failed to authenticate. Please confirm that:")
            VStack(alignment: .leading) {
              Text("The user is logged into iCloud")
              Text("The user is under 18")
              Text("The user is enrolled in an Apple Family")
            }.font(.footnote)
          case .unexpected, .other:
            // TODO: log, contact support, etc.
            Text("An unexpected error occurred, please try again.")
          case .passcodeRequired:
            Text(
              "Failed to authenticate. A passcode is required in order to enable parental controls."
            )
          case .authorizationCanceled:
            Text("Failed to authenticate. The parent/guardian canceled the authorization.")
          }
          Button("OK") {
            self.store.send(.authorizationFailedTryAgainTapped)
          }
        }
      case .installFailed(let error):
        VStack(spacing: 20) {
          Text("Sorry, the installation failed")
          Text(String(reflecting: error))
        }
      default:
        VStack(spacing: 15) {
          Text("Welcome to Gertrude!")
            .font(.title)
          Text("Click below to authorize")
          Button("Authorize") {
            self.store.send(.authorizeTapped)
          }
        }
      }
    }
    .padding()
  }
}
