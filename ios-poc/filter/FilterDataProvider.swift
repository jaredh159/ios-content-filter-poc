import NetworkExtension
import os.log

class FilterDataProvider: NEFilterDataProvider {
  override func startFilter(completionHandler: @escaping (Error?) -> Void) {
    // Add code to initialize the filter.
    os_log("[G•] start filter (data)")
    completionHandler(nil)
  }

  override func stopFilter(
    with reason: NEProviderStopReason,
    completionHandler: @escaping () -> Void
  ) {
    // Add code to clean up filter resources.
    os_log("[G•] stop filter (data) reason: %{public}s", String(describing: reason))
    completionHandler()
  }

  override func handleNewFlow(_ flow: NEFilterFlow) -> NEFilterNewFlowVerdict {
    // Add code to determine if the flow should be dropped or not, downloading new rules if required.
    os_log("[G•] handle new flow (data) : %{public}s", String(describing: flow))
    if let url = flow.url {
      os_log("[G•] handle new URL (data) : %{public}s", url.absoluteString)
      if url.absoluteString.hasPrefix("https://x.com") {
        return .drop()
      }
    }
    return .allow()
  }
}
