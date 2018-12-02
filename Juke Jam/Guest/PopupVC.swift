//
//  PopupVC.swift
//  Juke Jam
//
//  Created by Jeffrey Barros Peña on 7/17/18.
//  Copyright © 2018 Barros Peña. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class PopupVC: UIViewController {

  var song = SearchResult()
  var recommended = false
  
  @IBOutlet weak var songName: UILabel!
  @IBOutlet weak var artistName: UILabel!
  @IBOutlet weak var albumName: UILabel!
  @IBOutlet weak var artwork: UIImageView!
  @IBOutlet weak var explicitTag: UIImageView!
  @IBOutlet weak var recommendBtn: DesignableButton!
  @IBOutlet weak var backBtn: DesignableButton!
  
  var backX: CGFloat = 0.0
  var backY: CGFloat = 0.0
  var recX: CGFloat = 0.0
  var recY: CGFloat = 0.0
  
  var playlistID = ""
  
  override func viewDidLoad() {
    super.viewDidLoad()
  
    backX = backBtn.frame.midX
    backY = backBtn.frame.midY
    recX = recommendBtn.frame.midX
    recY = recommendBtn.frame.midY
  
    backBtn.frame.origin = CGPoint(x: (backX) , y: backY+100)
    recommendBtn.frame.origin = CGPoint(x: recX, y: (recY+200))
  
    songName.text = song.name
    artistName.text = song.artist
    albumName.text = song.album
  
  
    var artworkURLString = song.imageURLString.replacingOccurrences(of: "{h}", with: "500")
    artworkURLString = artworkURLString.replacingOccurrences(of: "{w}", with: "500")
    let artworkURL = URL(string: artworkURLString)
    let artworkImage = UIImage(data: (NSData(contentsOf: artworkURL!))! as Data)
    artwork.image = artworkImage
    artwork.layer.cornerRadius = 7.0
  
    if song.explicit {
      explicitTag.isHidden = false
    }
  }
  override func viewWillAppear(_ animated: Bool) {
    UIView.animate(withDuration: 0.6, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.2, options: [], animations: {
      self.backBtn.frame.origin = CGPoint(x: (self.backX) , y: self.backY)
    }, completion: nil)
    UIView.animate(withDuration: 0.6, delay: 0.2, usingSpringWithDamping: 1, initialSpringVelocity: 0.2, options: [], animations: {
      self.recommendBtn.frame.origin = CGPoint(x: self.recX, y: self.recY)
    }, completion: nil)
  }
  
  @IBAction func songRecommended(_ sender: DesignableButton) {
    recommended = true
    requestSongToServer(id: song.id)
    performSegue(withIdentifier: "songRecommendedUnwind", sender: self)
  }
  
  func requestSongToServer(id: String) {
    let ip = Routing().getIP()
    let port = Routing().getPort()
    
    let tempURL = "http://\(ip):\(port)/recommend"
    let postURL = URL(string: tempURL)!
    var request = URLRequest(url: postURL)
    request.httpMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    let parameters = ["songID": song.id, "playlistID": playlistID]
    guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else { return }
    request.httpBody = httpBody
    
    Alamofire.request(request).responseJSON { response in
      if response.response?.statusCode == 200 {
        print("\(id) has been recommended to playlist: \(self.playlistID)")
      } else {
        print("Response code: \(response.response?.statusCode ?? (410))")
      }
    }
  
  }
  
}
