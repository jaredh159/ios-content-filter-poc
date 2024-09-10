import NetworkExtension
import os.log

class FilterControlProvider: NEFilterControlProvider {

  override func startFilter(completionHandler: @escaping (Error?) -> Void) {
    // Add code to initialize the filter
    os_log("[G•] start filter (control)")
    completionHandler(nil)
  }

  override func stopFilter(
    with reason: NEProviderStopReason,
    completionHandler: @escaping () -> Void
  ) {
    // Add code to clean up filter resources
    os_log("[G•] stop filter (control) reason: %{public}s", String(describing: reason))
    completionHandler()
  }

  override func handleNewFlow(
    _ flow: NEFilterFlow,
    completionHandler: @escaping (NEFilterControlVerdict) -> Void
  ) {
    // Add code to determine if the flow should be dropped or not, downloading new rules if required
    os_log("[G•] handle new flow (control) : %{public}s", String(describing: flow))
    if let url = flow.url {
      os_log("[G•] handle new URL (control) : %{public}s", url.absoluteString)
      if url.absoluteString.hasPrefix("https://www.apple.com") {
        completionHandler(.drop(withUpdateRules: false))
      }
    }
    completionHandler(.allow(withUpdateRules: false))
  }
}
