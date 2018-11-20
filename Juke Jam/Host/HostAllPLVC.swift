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

class HostAllPLVC: UIViewController {
    
  @IBOutlet weak var tableView: UITableView!
  
  var playlists = [Playlist]()
  var devToken = ""
  var musicToken = ""
  var ip = Routing().getIP()
  var port = Routing().getPort()
  
  var lastReceivedRecs = [SearchResult]()
  var lastPlaylistID = ""
  var lastPlaylistTitle = ""

  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.delegate = self
    tableView.dataSource = self
    tableView.rowHeight = 87.0
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
      let destination = segue.destination as! PlaylistRecommendationsViewController
      destination.recommendations = lastReceivedRecs
      destination.playlistID = lastPlaylistID
      destination.playlistTitle = lastPlaylistTitle
      destination.devToken = devToken
      destination.musicToken = musicToken
    }
  }
  
  @IBAction func unwindFromRecommended(_ segue: UIStoryboardSegue) {
    let source = segue.source as! PlaylistRecommendationsViewController
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
        }
      case .failure(let error):
        print("ERROR: failed to get data: \(error.localizedDescription)")
      }
    }
  }
  ///////////////////////////////
  
  func requestPlaylistRecs(playlistID: String) {
    var recommendedSongs = [String]()
    let postURL = URL(string: "http://\(ip):\(port)/receive")!
  
    var request = URLRequest(url: postURL)
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
        
        self.lastReceivedRecs.removeAll()
        if recommendedSongs.isEmpty {
          self.performSegue(withIdentifier: "ToPlaylistRecommendations", sender: self)
        } else {
          print("     Recommendations:")
          self.convertToSongs(songIDs: recommendedSongs)
        }
        self.lastPlaylistID = playlistID
      case .failure(let error):
        print("ERROR: failed to get data: \(error.localizedDescription)")
      }
    }
  }
  
  func convertToSongs(songIDs: [String]) {
    var getSongString = "https://api.music.apple.com/v1/catalog/us/songs?ids="
    // convert song IDs to instances of the SearchResult class
    for songID in songIDs {
        getSongString.append(contentsOf: "\(songID),")
    }
    getSongString.removeLast()
    var request = URLRequest(url: URL(string: getSongString)!)
    request.setValue("Bearer \(devToken)", forHTTPHeaderField: "Authorization")
    request.setValue(musicToken, forHTTPHeaderField: "Music-User-Token")
  
    Alamofire.request(request).responseJSON { response in
        switch response.result {
        case .success(let value):
          let json = JSON(value)
          //print(json)
          let songs = json["data"].array
          if songs!.count != 0 {
            for i in 0..<songs!.count {
              var explicit = false
              if songs![i]["attributes"]["contentRating"].stringValue == "explicit" {
                explicit = true
              }
              let recommendation = SearchResult(name: songs![i]["attributes"]["name"].stringValue,
                                                artist: songs![i]["attributes"]["artistName"].stringValue,
                                                album: songs![i]["attributes"]["albumName"].stringValue,
                                                id: songs![i]["id"].stringValue,
                                                imageURLString: songs![i]["attributes"]["artwork"]["url"].stringValue,
                                                explicit: explicit)
              print("         \(recommendation.name) - \(recommendation.artist)")
              self.lastReceivedRecs.append(recommendation)
            }
          }
          self.performSegue(withIdentifier: "ToPlaylistRecommendations", sender: self)
        case .failure(let error):
          print("ERROR: failed to get data: \(error.localizedDescription)")
        }
    }
  }
  
}
extension HostAllPLVC: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
  
    let playlistLabel = cell?.viewWithTag(1) as! UILabel
    playlistLabel.text = playlists[indexPath.row].name
  
    let mainImageView = cell?.viewWithTag(3) as! UIImageView
    mainImageView.image = playlists[indexPath.row].image
    mainImageView.layer.cornerRadius = 7.0
  
    return cell!
  }
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return playlists.count
  }
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    lastPlaylistTitle = playlists[(tableView.indexPathForSelectedRow?.row)!].name
    var playlistID = playlists[(tableView.indexPathForSelectedRow?.row)!].id
    playlistID.removeFirst(2)
    print("Selected playlist: \(playlists[(tableView.indexPathForSelectedRow?.row)!].name) (\(playlists[(tableView.indexPathForSelectedRow?.row)!].id))")
    print(playlistID)
    requestPlaylistRecs(playlistID: playlistID)
    tableView.deselectRow(at: indexPath, animated: true)
  }
}
