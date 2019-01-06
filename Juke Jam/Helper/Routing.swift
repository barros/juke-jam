//
//  Routing.swift
//  Juke Jam
//
//  Created by Jeffrey Barros Peña on 11/17/18.
//  Copyright © 2018 Barros Peña. All rights reserved.
//

//import Foundation

class Routing {
  private var ip = "" // insert IP address here
  private var port = "" // insert port number here
  
  init() {
  }
  
  func getIP() -> String {
    return ip
  }
  func setIP(newIP: String) {
    self.ip = newIP
  }
  
  func getPort() -> String {
    return port
  }
  func setPort(newPort: String) {
    self.port = newPort
  }
  
}
