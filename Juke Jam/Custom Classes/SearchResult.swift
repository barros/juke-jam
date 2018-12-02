//
//  SearchResult.swift
//  Juke Jam
//
//  Created by Jeffrey Barros Peña on 7/13/18.
//  Copyright © 2018 Barros Peña. All rights reserved.
//

import Foundation

class SearchResult {
  var name: String
  var artist: String
  var album: String
  var id: String
  var imageURLString: String
  var explicit: Bool
  
  init(name: String, artist: String, album: String, id: String, imageURLString: String, explicit: Bool) {
    self.name = name
    self.artist = artist
    self.album = album
    self.id = id
    self.imageURLString = imageURLString
    self.explicit = explicit
  }
  
  convenience init() {
    self.init(name: "", artist: "", album: "", id: "", imageURLString: "", explicit: false)
  }

}
