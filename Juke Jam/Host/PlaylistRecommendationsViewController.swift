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

class PlaylistRecommendationsViewController: UIViewController, MFMessageComposeViewControllerDelegate {
  
  func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
    self.dismiss(animated: true, completion: nil)
  }

  @IBOutlet weak var tableView: UITableView!
  
  @IBOutlet weak var noRecsLabel1: UILabel!
  @IBOutlet weak var noRecsLabel2: UILabel!
  @IBOutlet weak var playlistTitleLabel: UILabel!
  @IBOutlet weak var whiteStripUnderTitle: UIView!
  @IBOutlet weak var popUpView: DesignablePopup!
  @IBOutlet weak var backBtn: DesignableButton!
  var lastAddPressed: PlaylistRecommendedCell!
  
  var recommendations = [SearchResult]()
  var playlistID = ""
  var playlistTitle = ""
  var devToken = ""
  var musicToken = ""
  var ip = Routing().getIP()
  var port = Routing().getPort()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.delegate = self
    tableView.dataSource = self
    playlistTitleLabel.text = playlistTitle
  
    if recommendations.isEmpty {
      popUpView.backgroundColor = backBtn.backgroundColor
      whiteStripUnderTitle.isHidden = true
    } else {
      tableView.isHidden = false
      noRecsLabel1.isHidden = true
      noRecsLabel2.isHidden = true
    }
  }
  
  // send POST request to add song to playlist
  func addSongToPlaylist(songID: String) {
    print(playlistID)
      let postURLString = URL(string: "https://api.music.apple.com/v1/me/library/playlists/p.\(playlistID)/tracks")
      var request = URLRequest(url: postURLString!)
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
  
  func updateSongRecord(songID: String) {
  let addRequest = URL(string: "http://\(ip):\(port)/add")
    var request = URLRequest(url: addRequest!)
    request.httpMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    let parameters = ["playlistID" : playlistID, "songID" : songID]
    guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else { return }
    request.httpBody = httpBody
    Alamofire.request(request).responseJSON { response in
      if response.response?.statusCode == 200 {
        print("\(songID) has been marked as added")
      } else {
        print("Response code: \(response.response?.statusCode ?? (401))")
      }
    }
  }
  func postDeleteRecord(songID: String) {
    let deleteRequest = URL(string: "http://\(ip):\(port)/delete")
    var request = URLRequest(url: deleteRequest!)
    request.httpMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    let parameters = ["playlistID" : playlistID, "songID" : songID]
    guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else { return }
    request.httpBody = httpBody
    Alamofire.request(request).responseJSON { response in
      if response.response?.statusCode == 200 {
        print("\(songID) has been marked as deleted")
      } else {
        print("Response code: \(response.response?.statusCode ?? (402))")
      }
    }
  }
  
  @IBAction func shareBtnPressed(_ sender: DesignableButton) {
    if (MFMessageComposeViewController.canSendText()) {
      let controller = MFMessageComposeViewController()
      controller.body = "Send me recommendations for my music playlist with Juke Jam!\n\nClick the link below to begin recommending:\nwww.juke-jam.herokuapp.com/\(playlistID)"
      controller.messageComposeDelegate = self
      self.present(controller, animated: true, completion: nil)
    }
  }
  
  func refreshAfterDelete(indexPath: IndexPath) {
    recommendations.remove(at: indexPath.row)
    tableView.deleteRows(at: [indexPath], with: .fade)
    if recommendations.isEmpty {
      popUpView.backgroundColor = self.backBtn.backgroundColor
      whiteStripUnderTitle.isHidden = true
      tableView.isHidden = true
      noRecsLabel1.isHidden = false
      noRecsLabel2.isHidden = false
    }
  }
}
extension PlaylistRecommendationsViewController: PlaylistRecommendedCellDelegate {
  func addBtnPressed(songID: String) {
    addSongToPlaylist(songID: songID)
  }
}

extension PlaylistRecommendationsViewController: UITableViewDelegate, UITableViewDataSource {
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

