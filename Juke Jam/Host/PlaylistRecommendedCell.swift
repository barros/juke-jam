//
//  PlaylistRecommendedCell.swift
//  Juke Jam
//
//  Created by Jeffrey Barros Peña on 7/25/18.
//  Copyright © 2018 Barros Peña. All rights reserved.
//

import UIKit

protocol PlaylistRecommendedCellDelegate {
  func addBtnPressed(songID: String)
}

class PlaylistRecommendedCell: UITableViewCell {

  @IBOutlet weak var songNameLabel: UILabel!
  @IBOutlet weak var artistNameLabel: UILabel!
  @IBOutlet weak var explicitTag: UIImageView!
  @IBOutlet weak var addButton: DesignableButton!
  
  var delegate: PlaylistRecommendedCellDelegate?
  
  var songID: String?
  
  func setUpCell(with recommendation: Song) {
    songID = recommendation.id
  
    songNameLabel.text = recommendation.name
    songNameLabel.sizeToFit()
  
    artistNameLabel.text = recommendation.artist
    artistNameLabel.sizeToFit()
  
    if recommendation.explicit {
      explicitTag.isHidden = false
    } else {
      explicitTag.isHidden = true
    }
  }
  
  @IBAction func addBtnPressed(_ sender: DesignableButton) {
    delegate?.addBtnPressed(songID: songID!)
  }
  
}
