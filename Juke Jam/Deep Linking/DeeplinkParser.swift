//
//  DeeplinkParser.swift
//  Juke Jam
//
//  Created by jeff on 12/29/18.
//  Copyright © 2018 Barros Peña. All rights reserved.
//

import Foundation

class DeeplinkParser {
  static let shared = DeeplinkParser()
  private init() { }
  
  func parseDeepLink(_ url: URL) -> DeeplinkType? {
    guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true), let host = components.host else {
      return nil
    }
    var pathComponents = components.path.components(separatedBy: "/")
    // the first component is empty
    pathComponents.removeFirst()
    print("pathComponents.first: " + (pathComponents.first ?? "nil"))
    print("host: " + host)
    if host == "juke-jam.herokuapp.com" {
      if let recCom = pathComponents.first {
        return DeeplinkType.guestRecommend
      }
    }
//    switch host {
//    case "messages":
//      if let messageId = pathComponents.first {
//        return DeeplinkType.guestRecommend
//      }
//    default:
//      break
//    }
    return nil
  }
}
