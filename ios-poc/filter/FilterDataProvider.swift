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
    var hostname: String?
    var url: String?
    let sourceId: String? = flow.sourceAppIdentifier
    if let browserFlow = flow as? NEFilterBrowserFlow {
      url = browserFlow.url?.absoluteString
      os_log("[G•] handle new BROWSER flow (data) : %{public}s", String(describing: browserFlow))
    } else if let socketFlow = flow as? NEFilterSocketFlow {
      hostname = socketFlow.remoteHostname
      os_log("[G•] handle new SOCKET flow (data) : %{public}s", String(describing: socketFlow))
    } else {
      os_log("[G•] flow is NEITHER subclass (unreachable?) id: %{public}s", String(describing: flow.identifier))
    }
    return allow(hostname: hostname, url: url, sourceId: sourceId) ? .allow() : .drop()
  }
}

func allow(hostname: String?, url: String?, sourceId: String?) -> Bool {
  if sourceId?.contains("HashtagImagesExtension") == true {
    return false
  } else if sourceId?.contains("com.apple.Spotlight") == true {
    return false
  }

  if url?.contains("tenor.co") == true {
    return false
  }

  if let target = url ?? hostname {
    if target.contains("cdn2.smoot.apple.com") {
      return false
    } else if target.contains("media.tenor.co") {
      return false
    } else if target.contains("wa.tenor.co") {
      return false
    } else if target.contains("giphy.com") {
      return false
    } else if target.contains("media.fosu2-1.fna.whatsapp.net") {
      return false
    }
  }
  return true
}

#if DEBUG
  func testAllow() {
    let cases: [(host: String?, url: String?, src: String, allow: Bool)] = [
      (host: nil, url: nil, src: "HashtagImagesExtension", allow: false),
      (host: nil, url: nil, src: ".com.apple.Spotlight", allow: false),
      (host: nil, url: nil, src: "com.widget", allow: true),
      (host: "cdn2.smoot.apple.com", url: nil, src: "com.widget", allow: false),
      (host: "media.tenor.co", url: nil, src: "com.widget", allow: false),
      (host: "wa.tenor.co", url: nil, src: "com.widget", allow: false),
      (host: "giphy.com", url: nil, src: "com.widget", allow: false),
      (host: "media0.giphy.com", url: nil, src: "com.widget", allow: false),
      (host: "media.fosu2-1.fna.whatsapp.net", url: nil, src: "", allow: false),
    ]

    for (host, url, src, expected) in cases {
      assert(allow(hostname: host, url: url, sourceId: src))
    }
  }
#endif
