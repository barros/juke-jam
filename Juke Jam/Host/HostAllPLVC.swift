//
//  HostAllPLVC.swift
//  Juke Jam
//
//  Created by Jeffrey Barros Peña on 7/5/18.
//  Copyright © 2018 Barros Peña. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SKActivityIndicatorView

class HostAllPLVC: UIViewController {
    
  @IBOutlet weak var tableView: UITableView!
  
  var playlists = [Playlist]()
  var devToken = ""
  var musicToken = ""
  var ip = Routing().getIP()
  var port = Routing().getPort()
  
  var selectedPlaylistID = ""
  var selectedPlaylistTitle = ""

  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.delegate = self
    tableView.dataSource = self
    SKActivityIndicator.show("Loading Playlists", userInteractionStatus: false)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    if playlists.isEmpty {
      DispatchQueue.global(qos: .userInitiated).async {
        // Download file or perform expensive task
        self.getPlaylists()
      }
    }
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "ToPlaylistRecommendations" {
      let destination = segue.destination as! PlaylistRecommendationsVC
      destination.playlistID = selectedPlaylistID
      destination.playlistTitle = selectedPlaylistTitle
      destination.devToken = devToken
      destination.musicToken = musicToken
    }
  }
  
  @IBAction func unwindFromRecommended(_ segue: UIStoryboardSegue) {
    let source = segue.source as! PlaylistRecommendationsVC
    source.recommendations.removeAll()
  }

  ///////////////////////////////
  func getPlaylists() {
    playlists.removeAll()
    let playlistRequestURL = URL(string: "https://api.music.apple.com/v1/me/library/playlists")
    var request = URLRequest(url: playlistRequestURL!)
    request.setValue("Bearer \(devToken)", forHTTPHeaderField: "Authorization")
    request.setValue(musicToken, forHTTPHeaderField: "Music-User-Token")
    
    Alamofire.request(request).responseJSON { response in
      
      switch response.result {
      case .success(let value):
        let json = JSON(value)
        print(json)
        let results = json["data"].array
        if results != nil {
          for i in 0..<results!.count {
            var artworkURLString = (results![i]["attributes"]["artwork"]["url"].stringValue).replacingOccurrences(of: "{w}", with: "300")
            artworkURLString = artworkURLString.replacingOccurrences(of: "{h}", with: "300")
            let artworkURL = URL(string: artworkURLString)
            let artwork = UIImage(data: (NSData(contentsOf: artworkURL!))! as Data)
            
            let playlist = Playlist()
            playlist.name = results![i]["attributes"]["name"].stringValue
            playlist.id = results![i]["id"].stringValue
            playlist.image = artwork!
            self.playlists.append(playlist)
            print("Received \(self.playlists.count) playlist(s)")
          }
          self.tableView.reloadData()
          self.tableView.isHidden = false
          SKActivityIndicator.dismiss()
        }
      case .failure(let error):
        print("ERROR: failed to get data: \(error.localizedDescription)")
      }
    }
  }
}
extension HostAllPLVC: UITableViewDelegate, UITableViewDataSource {
  // cell layout
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
  
    let playlistLabel = cell?.viewWithTag(1) as! UILabel
    playlistLabel.text = playlists[indexPath.row].name
  
    let mainImageView = cell?.viewWithTag(2) as! UIImageView
    mainImageView.image = playlists[indexPath.row].image
    mainImageView.layer.cornerRadius = 7.0
  
    return cell!
  }
  // number of rows
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return playlists.count
  }
  // cell selection
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    selectedPlaylistTitle = playlists[(tableView.indexPathForSelectedRow?.row)!].name
    var playlistID = playlists[(tableView.indexPathForSelectedRow?.row)!].id
    playlistID.removeFirst(2)
    selectedPlaylistID = playlistID
    print("Selected playlist: \(selectedPlaylistTitle) (\(playlists[(tableView.indexPathForSelectedRow?.row)!].id))")
    performSegue(withIdentifier: "ToPlaylistRecommendations", sender: self)
    tableView.deselectRow(at: indexPath, animated: true)
  }
}
