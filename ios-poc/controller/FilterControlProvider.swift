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
    // called when control class says `.needRules()`
    completionHandler(.allow(withUpdateRules: false))
  }
}

//os_log("[G•] handle new flow (control) : %{public}s", String(describing: flow))
//if let browserFlow = flow as? NEFilterBrowserFlow {
//  os_log("[G•] handle new BROWSER flow (control) : %{public}s", String(describing: browserFlow))
//} else if let socketFlow = flow as? NEFilterSocketFlow {
//  os_log("[G•] handle new SOCKET flow (control) : %{public}s", String(describing: socketFlow))
//} else {
//  os_log("[G•] flow is NEITHER subclass (unreachable?) id: %{public}s", String(describing: flow.identifier))
//}
