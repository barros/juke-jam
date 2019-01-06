//
//  DeeplinkManager.swift
//  Juke Jam
//
//  Created by jeff on 12/29/18.
//  Copyright © 2018 Barros Peña. All rights reserved.
//

import Foundation

class DeeplinkManager {
  public init() {}
  private var deeplinkType: DeeplinkType?
  
  
  // check existing deepling and perform action
  func checkDeepLink() {
    guard let deeplinkType = deeplinkType else {
      return
    }
    
    DeeplinkNavigator.shared.proceedToDeeplink(deeplinkType)
    // reset deeplink after handling
    self.deeplinkType = nil
  }
  
  @discardableResult
  func handleDeeplink(url: URL) -> Bool {
    deeplinkType = DeeplinkParser.shared.parseDeepLink(url)
    return deeplinkType != nil
  }
}
