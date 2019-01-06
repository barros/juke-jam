//
//  DeeplinkNavigator.swift
//  Juke Jam
//
//  Created by jeff on 12/29/18.
//  Copyright © 2018 Barros Peña. All rights reserved.
//

class DeeplinkNavigator {
  static let shared = DeeplinkNavigator()
  private init() { }
  
  func proceedToDeeplink(_ type: DeeplinkType) {
    switch type {
    case .guestRecommend:
      // perform segue
      break
    default:
      break
    }
  }
}
