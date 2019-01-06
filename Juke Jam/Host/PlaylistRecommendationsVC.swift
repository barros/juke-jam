//
//  PlaylistRecommendationsViewController.swift
//  Juke Jam
//
//  Created by Jeffrey Barros Peña on 7/24/18.
//  Copyright © 2018 Barros Peña. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import MessageUI
import SKActivityIndicatorView

class PlaylistRecommendationsVC: UIViewController, MFMessageComposeViewControllerDelegate {
  
  func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
    self.dismiss(animated: true, completion: nil)
  }

  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var noRecsLabel1: UILabel!
  @IBOutlet weak var noRecsLabel2: UILabel!
  @IBOutlet weak var playlistTitleLabel: UILabel!
  @IBOutlet weak var popUpView: DesignablePopup!
  @IBOutlet weak var backBtn: DesignableButton!
  @IBOutlet weak var shareBtn: DesignableButton!
  
  var backX: CGFloat = 0.0
  var backY: CGFloat = 0.0
  var shareX: CGFloat = 0.0
  var shareY: CGFloat = 0.0
  var animate = true
  
  var recommendations = [Song]()
  var playlistID = ""
  var playlistTitle = ""
  var activeLobby = false
  var devToken = ""
  var musicToken = ""
  var ip = Routing().getIP()
  var port = Routing().getPort()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.delegate = self
    tableView.dataSource = self
    playlistTitleLabel.text = playlistTitle
    
    backBtn.frame.origin = CGPoint(x: (backX) , y: backY+100)
    shareBtn.frame.origin = CGPoint(x: shareX, y: (shareY+200))
  
    SKActivityIndicator.show("", userInteractionStatus: false)
    checkLobbyStatus()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    if animate {
      UIView.animate(withDuration: 0.6, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.2, options: [], animations: {
        self.backBtn.frame.origin = CGPoint(x: (self.backX) , y: self.backY)
      }, completion: nil)
      UIView.animate(withDuration: 0.6, delay: 0.2, usingSpringWithDamping: 1, initialSpringVelocity: 0.2, options: [], animations: {
        self.shareBtn.frame.origin = CGPoint(x: self.shareX, y: self.shareY)
      }, completion: nil)
      animate = false
    }
  }
  
  // check that playlist lobby exists
  func checkLobbyStatus() {
    let reqURL = URL(string: "http://\(ip):\(port)/exists?lobbyID=\(playlistID)")!
    var request = URLRequest(url: reqURL)
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    print("checking lobby status")
    
    Alamofire.request(request).responseJSON { response in
      if response.response?.statusCode == 200 {
        // playlist lobby does exist so request recommendations
        self.activeLobby = true
        self.requestPlaylistRecs(playlistID: self.playlistID)
      } else if response.response?.statusCode == 404 {
        // playlist lobby doesn't exist, update UI to
        // prompt user to begin sharing
        self.noRecsLabel1.isHidden = false
        self.noRecsLabel2.isHidden = false
        SKActivityIndicator.dismiss()
      } else {
        print("Error -> Response code: \(response.response?.statusCode ?? (401))")
        SKActivityIndicator.dismiss()
      }
    }
  }
  
  // request recommendations for playlist lobby
  func requestPlaylistRecs(playlistID: String) {
    var recommendedSongs = [String]()
    let reqURL = URL(string: "http://\(ip):\(port)/receive")!
    var request = URLRequest(url: reqURL)
    request.httpMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    let parameters = ["playlistID" : playlistID]
    guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else { return }
    request.httpBody = httpBody
    
    Alamofire.request(request).responseJSON { response in
      switch response.result {
      case .success(let value):
        let json = JSON(value)
        if let results = json["list"].array {
          for i in 0..<results.count {
            recommendedSongs.append(results[i].stringValue)
          }
        }
        if recommendedSongs.isEmpty {
          // there are no recommendations
          self.noRecsLabel1.text = "No Recommendations"
          self.noRecsLabel2.text = "There are currently no recommendations. Spread the word by sharing below!"
          self.noRecsLabel1.isHidden = false
          self.noRecsLabel2.isHidden = false
          SKActivityIndicator.dismiss()
        } else {
          // there are recommendations
          print("     Recommendations:")
          self.convertToSongs(songIDs: recommendedSongs)
        }
      case .failure(let error):
        print("ERROR: failed to get data: \(error.localizedDescription)")
      }
    }
  }
  
  // convert raw songIDs to Song instances
  func convertToSongs(songIDs: [String]) {
    var reqURL = "https://api.music.apple.com/v1/catalog/us/songs?ids="
    for songID in songIDs {
      reqURL.append(contentsOf: "\(songID),")
    }
    reqURL.removeLast()
    var request = URLRequest(url: URL(string: reqURL)!)
    request.setValue("Bearer \(devToken)", forHTTPHeaderField: "Authorization")
    request.setValue(musicToken, forHTTPHeaderField: "Music-User-Token")
    
    Alamofire.request(request).responseJSON { response in
      switch response.result {
      case .success(let value):
        let json = JSON(value)
        let songs = json["data"].array
        if songs!.count != 0 {
          for i in 0..<songs!.count {
            var explicit = false
            if songs![i]["attributes"]["contentRating"].stringValue == "explicit" {
              explicit = true
            }
            let recommendation = Song(name: songs![i]["attributes"]["name"].stringValue,
                                              artist: songs![i]["attributes"]["artistName"].stringValue,
                                              album: songs![i]["attributes"]["albumName"].stringValue,
                                              id: songs![i]["id"].stringValue,
                                              imageURLString: songs![i]["attributes"]["artwork"]["url"].stringValue,
                                              explicit: explicit)
            print("         \(recommendation.name) - \(recommendation.artist)")
            self.recommendations.append(recommendation)
          }
        }
        // update UI to show table view of fresh recommendations
        self.popUpView.backgroundColor = UIColor.white
        self.tableView.reloadData()
        self.tableView.isHidden = false
        SKActivityIndicator.dismiss()
      case .failure(let error):
        print("ERROR: failed to get data: \(error.localizedDescription)")
      }
    }
  }
  
  // send POST request to add song to playlist
  func addSongToPlaylist(songID: String) {
    print(playlistID)
      let reqURL = URL(string: "https://api.music.apple.com/v1/me/library/playlists/p.\(playlistID)/tracks")
      var request = URLRequest(url: reqURL!)
      request.httpMethod = "POST"
      request.addValue("application/json", forHTTPHeaderField: "Content-Type")
      request.addValue("application/json", forHTTPHeaderField: "Accepts")
      request.setValue("Bearer \(devToken)", forHTTPHeaderField: "Authorization")
      request.setValue(musicToken, forHTTPHeaderField: "Music-User-Token")
    var libraryTracksRequest = JSON()
    libraryTracksRequest.dictionaryObject = [
      "data": [
        [
          "id": songID,
        "type": "songs"
        ]
      ]
    ]
    guard let httpBody = try? JSONSerialization.data(withJSONObject: libraryTracksRequest.dictionaryObject!, options: []) else { return }
      request.httpBody = httpBody
    
      Alamofire.request(request).responseJSON { response in
        switch response.result {
        case .success(_):
          if response.response?.statusCode == 204 {
            self.updateSongRecord(songID: songID)
          }
        case .failure(let error):
          print("ERROR: failed to get data: \(error.localizedDescription)")
        }
      }
  }
  
  // mark song record as 'added' (previously just 'new')
  func updateSongRecord(songID: String) {
  let reqURL = URL(string: "http://\(ip):\(port)/add")
    var request = URLRequest(url: reqURL!)
    request.httpMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    let parameters = ["playlistID" : playlistID, "songID" : songID]
    guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else { return }
    request.httpBody = httpBody
    Alamofire.request(request).responseJSON { response in
      if response.response?.statusCode == 200 {
        print("\(songID) has been marked as added")
      } else {
        print("Response code: \(response.response?.statusCode ?? (401)) - song could not be marked as added")
      }
    }
  }
  // mark song record as 'deleted' (previously 'new')
  func postDeleteRecord(songID: String) {
    let reqURL = URL(string: "http://\(ip):\(port)/delete")
    var request = URLRequest(url: reqURL!)
    request.httpMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    let parameters = ["playlistID" : playlistID, "songID" : songID]
    guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else { return }
    request.httpBody = httpBody
    Alamofire.request(request).responseJSON { response in
      if response.response?.statusCode == 200 {
        print("\(songID) has been marked as deleted")
      } else {
        print("Response code: \(response.response?.statusCode ?? (402)) - song could not be marked as deleted")
      }
    }
  }
  
  func createLobby() {
    let reqURL = URL(string: "http://\(ip):\(port)/create")!
    var request = URLRequest(url: reqURL)
    request.httpMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    let parameters = ["playlistID": playlistID, "max": 100] as [String : Any]
    guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else { return }
    request.httpBody = httpBody
    Alamofire.request(request)
  }
  
  @IBAction func shareBtnPressed(_ sender: DesignableButton) {
    if !activeLobby {
      createLobby()
    }
    if (MFMessageComposeViewController.canSendText()) {
      let controller = MFMessageComposeViewController()
      controller.body = "Send me recommendations for my music playlist with Juke Jam!\n\nClick the link below to begin recommending:\nhttps://juke-jam.herokuapp.com/recommend/\(playlistID)"
      controller.messageComposeDelegate = self
      self.present(controller, animated: true, completion: nil)
    }
  }
  
  // delete table view row, correctly updating UI if table view
  // is now empty
  func refreshAfterDelete(indexPath: IndexPath) {
    recommendations.remove(at: indexPath.row)
    tableView.deleteRows(at: [indexPath], with: .fade)
    if recommendations.isEmpty {
      popUpView.backgroundColor = backBtn.backgroundColor
      tableView.isHidden = true
      noRecsLabel1.isHidden = false
      noRecsLabel2.isHidden = false
    }
  }
}
extension PlaylistRecommendationsVC: PlaylistRecommendedCellDelegate {
  func addBtnPressed(songID: String) {
    addSongToPlaylist(songID: songID)
  }
}

extension PlaylistRecommendationsVC: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    //return 1
    return recommendations.count
  }
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let recommendation = recommendations[indexPath.row]
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! PlaylistRecommendedCell
    cell.setUpCell(with: recommendation)
    cell.delegate = self
    return cell
  }
  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    let songID = recommendations[indexPath.row].id
    postDeleteRecord(songID: songID)
    refreshAfterDelete(indexPath: indexPath)
  }
}

