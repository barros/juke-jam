//
//  Tokens.swift
//  Juke Jam
//
//  Created by jeff on 1/3/19.
//  Copyright © 2019 Barros Peña. All rights reserved.
//

import UIKit

class Tokens {
  
  init() {
  }
  
  func getMusicToken() -> String {
    let savedMusicToken = UserDefaults.standard.string(forKey: "musicToken")
    if savedMusicToken != nil {
      return savedMusicToken!
    }
    return ""
  }
  func setMusicToken(newToken: String) {
    UserDefaults.standard.set(newToken, forKey: "musicToken")
    //self.musicToken = newToken
  }
  
  func getDevToken() -> String {
    let savedDevToken = UserDefaults.standard.string(forKey: "devToken")
    if savedDevToken != nil {
      return savedDevToken!
    }
    return ""
  }
  func setDevToken(newToken: String) {
    UserDefaults.standard.set(newToken, forKey: "devToken")
    //self.devToken = newToken
  }
}
