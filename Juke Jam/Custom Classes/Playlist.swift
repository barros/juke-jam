//
//  Playlist.swift
//  Juke Jam
//
//  Created by Jeffrey Barros Peña on 7/13/18.
//  Copyright © 2018 Barros Peña. All rights reserved.
//

import Foundation
import UIKit

class Playlist: NSObject, NSCoding {
  func encode(with aCoder: NSCoder) {
    aCoder.encode(self.name, forKey: "name")
    aCoder.encode(self.id, forKey: "id")
    aCoder.encode(self.image, forKey: "image")
  }
  
  required init?(coder aDecoder: NSCoder) {
    self.name = (aDecoder.decodeObject(forKey: "name") as? String)!
    self.id = (aDecoder.decodeObject(forKey: "id") as? String)!
    self.image = (aDecoder.decodeObject(forKey: "image") as? UIImage)!
  }
  
  var name = ""
  var id = ""
  var image = UIImage()
  
  func playlistInit(name: String, id: String, image: UIImage) {
    self.name = name
    self.id = id
    self.image = image
  }
  
  override init() {
    super.init()
    self.playlistInit(name: "", id: "", image: UIImage())
  }
}
