//
//  GuestVC.swift
//  Juke Jam
//
//  Created by Jeffrey Barros Peña on 7/13/18.
//  Copyright © 2018 Barros Peña. All rights reserved.
//

import UIKit
import Spartan
import Alamofire
import SwiftyJSON

class SearchSongVC: UIViewController {
  
  @IBOutlet weak var backBtn: UIButton!
  @IBOutlet weak var searchBar: UISearchBar!
  @IBOutlet weak var recommendedSongsBtn: UIButton!
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var searchAboveLabel: UILabel!
  @IBOutlet weak var strip: UIView!

  //var firstSearch = true
  
  var results = [SearchResult]()
  var recommended = [SearchResult]()
  
  let postSongRequestString = "https://api.music.apple.com/v1/me/library/playlists/"
  var musicToken = ""
  var devToken = ""
  var playlistID = ""
  
  override func viewDidLoad() {
    super.viewDidLoad()

    searchBar.delegate = self
    tableView.delegate = self
    tableView.dataSource = self
  
    let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
  
    //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
    tap.cancelsTouchesInView = false
    view.addGestureRecognizer(tap)
  
    if recommended.isEmpty {
      recommendedSongsBtn.isHidden = true
      strip.isHidden = true
    }
  
    print("playlistID: \(playlistID)")
  }
  
  @objc func dismissKeyboard() {
    // Causes the view (or one of its embedded text fields) to resign the first responder status.
    view.endEditing(true)
  }
  func hideLabel() {
    searchAboveLabel.isHidden = true
    tableView.isHidden = false
  }
  func unhideLabel(withText text: String) {
    searchAboveLabel.text = text
    searchAboveLabel.isHidden = false
    tableView.isHidden = true
  }
  
  func getResults(query: String) {
  
    // SEARCH ON SPOTIFY
//        let text = (searchBar.text ?? "")
//        _ = Spartan.search(query: text, type: .track, success: { (pagingObject: PagingObject<SimplifiedTrack>) in
//            // Get the tracks via pagingObject.items
//            for item in pagingObject.items {
//                let result = SearchResult(name: item.name, artist: "", id: (item.id as! String?)!, imageURL: "")
//                print("Result name: " + result.name)
//                self.results.append(result)
//                print("Results count after appending: " + String(self.results.count))
//            }
//            print("Final Results count: " + String(self.results.count))
//
//            DispatchQueue.main.async { [unowned self] in
//                self.tableView.reloadData()
//            }
//        }, failure: { (error) in
//            print(error)
//            self.results.removeAll()
//            DispatchQueue.main.async { [unowned self] in
//                self.tableView.reloadData()
//            }
//        })
    results.removeAll()
  
    let queryURLString = (searchBar.text)?.replacingOccurrences(of: " ", with: "+")
    let url = URL(string: "https://api.music.apple.com/v1/catalog/us/search?&types=songs&limit=20&term=" + queryURLString!)
  
    var request = URLRequest(url: url!)
    request.setValue("Bearer \(devToken)", forHTTPHeaderField: "Authorization")
  
    Alamofire.request(request).responseJSON { response in
        switch response.result {
      case .success(let value):
          let json = JSON(value)
          //print(json)
          if let searchResults = json["results"]["songs"]["data"].array {
              for i in 0..<searchResults.count {
                var explicit = false
                if searchResults[i]["attributes"]["contentRating"].stringValue == "explicit" {
                  explicit = true
                }
                let result = SearchResult(name: searchResults[i]["attributes"]["name"].stringValue,
                                          artist: searchResults[i]["attributes"]["artistName"].stringValue,
                                          album: searchResults[i]["attributes"]["albumName"].stringValue,
                                          id: searchResults[i]["id"].stringValue,
                                          imageURLString: searchResults[i]["attributes"]["artwork"]["url"].stringValue,
                                          explicit: explicit)
                self.results.append(result)
                //print(searchResults![i])
            }
          }
          if self.results.isEmpty {
            self.unhideLabel(withText: "No results")
          } else {
            self.hideLabel()
            self.tableView.reloadData()
          }
      case .failure(let error):
        print("ERROR: failed to get data: \(error.localizedDescription)")
      }
    }
  }
  // ---------------------------------------
  // Segue methods
  // ---------------------------------------

  @IBAction func unwindWithSegue(_ segue: UIStoryboardSegue) {
  }
  @IBAction func songRecommendedUnwind(_ segue: UIStoryboardSegue) {
    let source = segue.source as! PopupVC
    if source.recommended {
      recommended.append(source.song)
      recommendedSongsBtn.isHidden = false
      strip.isHidden = false
    }
  }
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "PopupSegue" {
      let destination = segue.destination as! PopupVC
      destination.song = results[(tableView.indexPathForSelectedRow?.row)!]
      destination.playlistID = playlistID
    } else if segue.identifier == "RecommendedsSegue" {
      let destination = segue.destination as! GuestRecommendedVC
      destination.recommended = recommended
    }
  }
  
}
extension SearchSongVC: UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {
  // MARK:- SearchBar Delegates
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    if searchBar.text != "" {
        //firstSearch = true
      getResults(query: searchBar.text!)
    }
    dismissKeyboard()
  }
  
  // update results on text field change
//    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        //results.removeAll()
//        if searchBar.text == "" {
//            unhideLabel(withText: "Search for songs on Apple Music above")
//        } else {
//            getResults(query: searchBar.text!)
//        }
//    }
  
  // MARK:- TableView Delegates
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
  
    let songLabel = cell?.viewWithTag(1) as! UILabel
    songLabel.text = results[indexPath.row].name
    songLabel.sizeToFit()
  
    let artistLabel = cell?.viewWithTag(2) as! UILabel
    artistLabel.text = results[indexPath.row].artist
    artistLabel.sizeToFit()
  
    let explicitTag = cell?.viewWithTag(3) as! UIImageView
    if results[indexPath.row].explicit {
      explicitTag.isHidden = false
    } else {
      explicitTag.isHidden = true
    }
  
    return cell!
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return results.count
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    performSegue(withIdentifier: "PopupSegue", sender: nil)
    tableView.deselectRow(at: indexPath, animated: true)
  }
}
