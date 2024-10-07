import ComposableArchitecture
import FamilyControls
import NetworkExtension

@Reducer public struct AppReducer {
  @ObservableState
  public struct State: Equatable {
    public var appState: AppState

    public init(appState: AppState = .unknown) {
      self.appState = appState
    }
  }

  // TODO: figure out why i can't use a root store enum
  public enum AppState: Equatable {
    case unknown
    case unauthorized
    case authorizing
    case authorizationFailed(AuthFailureReason)
    case authorized
    case installFailed(FilterInstallError)
    case running
  }

  public enum Action: Equatable {
    case authorizeTapped
    case authorizationFailed(AuthFailureReason)
    case authorizationSucceeded
    case authorizationFailedTryAgainTapped
    case installFailed(FilterInstallError)
    case installSucceeded
    case installFilterTapped
  }

  public var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {

      case .authorizeTapped:
        guard state.appState == .unauthorized else {
          return .none
        }
        state.appState = .authorizing
        return .run { send in
          switch await requestAuthorization() {
          case .success:
            await send(.authorizationSucceeded)
          case .failure(let reason):
            await send(.authorizationFailed(reason))
          }
        }

      case .authorizationSucceeded:
        state.appState = .authorized
        return .none

      case .authorizationFailed(let reason):
        state.appState = .authorizationFailed(reason)
        return .none

      case .authorizationFailedTryAgainTapped:
        state.appState = .unauthorized
        return .none

      case .installFilterTapped:
        return .run { send in
          switch await saveConfiguration() {
          case .success:
            await send(.installSucceeded)
          case .failure(let error):
            await send(.installFailed(error))
          }
        }

      case .installFailed(let error):
        state.appState = .installFailed(error)
        return .none

      case .installSucceeded:
        state.appState = .running
        return .none
      }
    }
  }

  public init() {}
}

// TODO: extract into @Dependency
func requestAuthorization() async -> Result<Void, AuthFailureReason> {
  // TODO: figure out SPM things...
  #if os(iOS)
    do {
      try await AuthorizationCenter.shared.requestAuthorization(for: .child)
    } catch let familyError as FamilyControlsError {
      switch familyError {
      case .invalidAccountType:
        return .failure(.invalidAccountType)
      case .authorizationConflict:
        return .failure(.authorizationConflict)
      case .authorizationCanceled:
        return .failure(.authorizationCanceled)
      case .networkError:
        return .failure(.networkError)
      case .authenticationMethodUnavailable:
        return .failure(.passcodeRequired)
      case .restricted:
        return .failure(.unexpected(.restricted))
      case .unavailable:
        return .failure(.unexpected(.unavailable))
      case .invalidArgument:
        return .failure(.unexpected(.invalidArgument))
      @unknown default:
        return .failure(.other(String(reflecting: familyError)))
      }
    } catch {
      return .failure(.other(String(reflecting: error)))
    }
  #endif
  return .success(())
}

// @see https://developer.apple.com/documentation/familycontrols/familycontrolserror
public enum AuthFailureReason: Error, Equatable {
  // The device isn't signed into a valid iCloud account (also? .individual?)
  case invalidAccountType
  /// Another authorized app already provides parental controls
  case authorizationConflict
  case unexpected(Unexpected)
  case other(String)
  /// Device must be connected to the network in order to enroll with parental controls
  case networkError
  /// The device must have a passcode set in order for an individual to enroll with parental controls
  case passcodeRequired
  /// The parent or guardian cancelled a request for authorization
  case authorizationCanceled

  public enum Unexpected: Equatable {
    /// The method's arguments are invalid
    case invalidArgument
    /// The system failed to set up the Family Control famework
    case unavailable
    /// A restriction prevents your app from using Family Controls on this device
    case restricted
  }
}

public enum FilterInstallError: Error, Equatable {
  case configurationInvalid
  case configurationDisabled
  /// another process modified the filter configuration
  /// since the last time the app loaded the configuration
  case configurationStale
  /// removing the configuration isn't allowed
  case configurationCannotBeRemoved
  case configurationPermissionDenied
  case configurationInternalError
  case unexpected(String)
}

func saveConfiguration() async -> Result<Void, FilterInstallError> {
  // not sure this is necessary, but doesn't seem to hurt and might ensure clean slate
  try? await NEFilterManager.shared().removeFromPreferences()

  if NEFilterManager.shared().providerConfiguration == nil {
    let newConfiguration = NEFilterProviderConfiguration()
    newConfiguration.username = "IOSPoc"
    newConfiguration.organization = "GertrudeSkunk"
    #if os(iOS)
      newConfiguration.filterBrowsers = true
    #endif
    newConfiguration.filterSockets = true
    NEFilterManager.shared().providerConfiguration = newConfiguration
  }
  NEFilterManager.shared().isEnabled = true
  do {
    try await NEFilterManager.shared().saveToPreferences()
    return .success(())
  } catch {
    switch NEFilterManagerError(rawValue: (error as NSError).code) {
    case .some(.configurationInvalid):
      return .failure(.configurationInvalid)
    case .some(.configurationDisabled):
      return .failure(.configurationDisabled)
    case .some(.configurationStale):
      return .failure(.configurationStale)
    case .some(.configurationCannotBeRemoved):
      return .failure(.configurationCannotBeRemoved)
    case .some(.configurationPermissionDenied):
      return .failure(.configurationPermissionDenied)
    case .some(.configurationInternalError):
      return .failure(.configurationInternalError)
    case .none:
      return .failure(.unexpected(String(reflecting: error)))
    @unknown default:
      return .failure(.unexpected(String(reflecting: error)))
    }
  }
}

func checkConfiguration() async {
  // below might be how we can figure out on launch if we're already installed
  // let error = try? await NEFilterManager.shared().loadFromPreferences()
}
