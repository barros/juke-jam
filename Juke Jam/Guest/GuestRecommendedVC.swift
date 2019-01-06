//
//  GuestRecommendedVC.swift
//  Juke Jam
//
//  Created by Jeffrey Barros Peña on 7/18/18.
//  Copyright © 2018 Barros Peña. All rights reserved.
//

import UIKit

class GuestRecommendedVC: UIViewController {

  var recommended = [Song]()
  
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var backBtn: DesignableButton!

  var backX: CGFloat = 0.0
  var backY: CGFloat = 0.0
  
  override func viewDidLoad() {
    super.viewDidLoad()
  
    tableView.delegate = self
    tableView.dataSource = self
  
    backX = backBtn.frame.midX
    backY = backBtn.frame.midY
  
    backBtn.frame.origin = CGPoint(x: (backX) , y: backY+100)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    UIView.animate(withDuration: 0.6, delay: 0.0, usingSpringWithDamping: 1, initialSpringVelocity: 0.2, options: [], animations: {
        self.backBtn.frame.origin = CGPoint(x: (self.backX) , y: self.backY)
    }, completion: nil)
  }
}
extension GuestRecommendedVC: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
  
    let songLabel = cell?.viewWithTag(1) as! UILabel
    songLabel.text = recommended[indexPath.row].name
    songLabel.sizeToFit()
  
    let artistLabel = cell?.viewWithTag(2) as! UILabel
    artistLabel.text = recommended[indexPath.row].artist
  
    let explicitTag = cell?.viewWithTag(3) as! UIImageView
    if recommended[indexPath.row].explicit {
      explicitTag.isHidden = false
    } else {
      explicitTag.isHidden = true
    }
  
    return cell!
  }
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return recommended.count
  }
}
