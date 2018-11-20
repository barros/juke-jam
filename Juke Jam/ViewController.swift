//
//  ViewController.swift
//  Juke Jam
//
//  Created by Jeffrey Barros Peña on 6/4/18.
//  Copyright © 2018 Barros Peña. All rights reserved.
//

import UIKit
import StoreKit
import Alamofire
import SwiftyJSON

class ViewController: UIViewController {
  
  // labels
  @IBOutlet weak var jukeJamLabel: UILabel!
  @IBOutlet weak var greetingLabel: UILabel!
  @IBOutlet weak var selectionLabel: UILabel!
  @IBOutlet weak var loginLabel: UILabel!
  @IBOutlet weak var showPlaylistsLabel: UILabel!
  @IBOutlet weak var recommendLabel: UILabel!
  @IBOutlet weak var welcomeLabel: UILabel!
  @IBOutlet weak var nowLoggedInLabel: UILabel!
  
  //buttons
  @IBOutlet weak var getStartedBtn: DesignableButton!
  @IBOutlet weak var showPlaylistsBtn: DesignableButton!
  @IBOutlet weak var recommendBtn: DesignableButton!
  @IBOutlet weak var loginBtnView: DesignablePopup!
  @IBOutlet weak var subscribeBtn: DesignableButton!
  
  
  // dev token can't be static on release
  let devToken = "eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IkdHSzVONUEyTkcifQ.eyJpYXQiOjE1MzE4NzE2NjcsImV4cCI6MTU0NzQyMzY2NywiaXNzIjoiOUwzRDY3NlUyNSJ9.yfVs40BYUDIqHTSWQspOvaJzqlGv0BGmtZVAbUDXiu4xRcIVL70Ke0KAxt_65J6PCMtsccck3cvMI6e-1vbssQ"
  var musicToken = ""
  let playlistRequestURL = URL(string: "https://api.music.apple.com/v1/me/library/playlists")
  var lastEnteredPlaylist = ""
  
  // variables
  var loggedIn = false
  // to be passed
  var username = ""
  var token = ""
  var playlists = [Playlist]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
  
    // make labels invisible
    greetingLabel.alpha = 0
    getStartedBtn.alpha = 0
    //selectionLabel.alpha = 0
    loginLabel.alpha = 0
    showPlaylistsLabel.alpha = 0
    recommendLabel.alpha = 0
    welcomeLabel.alpha = 0
    nowLoggedInLabel.alpha = 0
    // make buttons invisible
    showPlaylistsBtn.alpha = 0
    recommendBtn.alpha = 0
    loginBtnView.alpha = 0
    subscribeBtn.alpha = 0
  
  }
  
  override func viewDidAppear(_ animated: Bool) {
    loadDefaultsData{
      if self.loggedIn {
        //self.getPlaylists()
        self.loggedInUIUpdate()
      } else {
        self.launchAnimation()
        SKCloudServiceController.requestAuthorization { (status: SKCloudServiceAuthorizationStatus) in
                switch status {
                  case .authorized: print("authorized")
                  case .denied, .restricted: print("denied, restricted")
                  case .notDetermined: print("notDetermined")
                }
              }
      }
    }
  }
  
  // MARK:- DefaultsData biz
  func loadDefaultsData(completed: @escaping () -> Void) {
    let decodedPlaylists = UserDefaults.standard.object(forKey: "playlists") as? Data
    if decodedPlaylists != nil {
      let loadedPlaylists = NSKeyedUnarchiver.unarchiveObject(with: decodedPlaylists!) as! [Playlist]
      self.playlists = loadedPlaylists
      print("\(loadedPlaylists.count) has been loaded from 'loadDefaultsData()'")
    } else {
      playlists = [Playlist]()
    }
  
    let savedMusicToken = UserDefaults.standard.object(forKey: "musicToken") as? String
    if savedMusicToken != nil {
      musicToken = savedMusicToken!
    } else {
      musicToken = ""
    }
  
    let savedLoggedIn = UserDefaults.standard.object(forKey: "loggedIn") as? Bool
    if savedLoggedIn != nil {
      loggedIn = savedLoggedIn!
    } else {
      loggedIn = false
    }
    completed()
  }
  func saveDefaultsData(completed: @escaping () -> Void) {
    let encodedPlaylist = NSKeyedArchiver.archivedData(withRootObject: playlists)
    UserDefaults.standard.set(encodedPlaylist, forKey: "playlists")
    UserDefaults.standard.set(musicToken, forKey: "musicToken")
    UserDefaults.standard.set(loggedIn, forKey: "loggedIn")
    completed()
  }
  
  
//  func updateUserMusicToken() {
//    var loginSuccess = false
//    let controller = SKCloudServiceController()
//    controller.requestUserToken(forDeveloperToken: devToken) { (userToken: String?, error: Error?) in
//      if let userToken = userToken {
//        loginSuccess = true
//        self.musicToken = userToken
//        self.getPlaylists()
//        print("Updated music token: \(self.musicToken)")
//        //self.loggedIn = true
//        self.loggedInUIUpdate()
//      }
//      if let error = error {
//        print(error)
//      }
//    }
//    loggedIn = loginSuccess
//    saveDefaultsData()
//  }
  // GET APPLE MUSIC PLAYLISTS
  func getPlaylists() {
    playlists.removeAll()
    var request = URLRequest(url: playlistRequestURL!)
    request.setValue("Bearer \(devToken)", forHTTPHeaderField: "Authorization")
    request.setValue(musicToken, forHTTPHeaderField: "Music-User-Token")
    
    Alamofire.request(request).responseJSON { response in
      
        switch response.result {
        case .success(let value):
          let json = JSON(value)
          let results = json["data"].array
          for i in 0..<results!.count {
            var canEdit = false
            if results![i]["attributes"]["canEdit"].stringValue == "true" {
                canEdit = true
            }
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
          self.saveDefaultsData{}
        case .failure(let error):
          print("ERROR: failed to get data: \(error.localizedDescription)")
          self.loadDefaultsData{}
        }
    }
  }
  
  // UI update after successful login
  func loggedInUIUpdate() {
    UIView.animate(withDuration: 0.5, delay: 0.6, options: [], animations: {
        UIView.animate(withDuration: 2, animations: {
            self.jukeJamLabel.frame.origin.y = CGFloat(177)
        })
        self.loginLabel.alpha = 0
        self.loginBtnView.alpha = 0
        self.subscribeBtn.alpha = 0
      
        self.welcomeLabel.alpha = 1
        self.nowLoggedInLabel.alpha = 1
        self.showPlaylistsLabel.alpha = 1
        self.recommendLabel.alpha = 1
        self.showPlaylistsBtn.alpha = 1
        self.recommendBtn.alpha = 1
    }, completion: nil)
  }
  // Initial launch animation
  func launchAnimation() {
    UIView.animate(withDuration: 2, animations: {
        self.jukeJamLabel.frame.origin.y = CGFloat(177)
    })
    UIView.animate(withDuration: 0.5, delay: 2, options: [], animations: {
        self.greetingLabel.alpha = 1
        self.getStartedBtn.alpha = 1
    }, completion: nil)
    //firstLaunch = false
  }
  
  // MARK:- Button Actions
  @IBAction func getStartedPressed(_ sender: DesignableButton) {
    UIView.animate(withDuration: 0.5, delay: 0.6, options: [], animations: {
        self.getStartedBtn.alpha = 0
        self.greetingLabel.alpha = 0
        self.loginLabel.alpha = 1
        self.loginBtnView.alpha = 1
        self.subscribeBtn.alpha = 1
    }, completion: nil)
  }
  @IBAction func loginClicked(_ sender: UIButton) {
    let controller = SKCloudServiceController()
    controller.requestUserToken(forDeveloperToken: devToken) { (userToken: String?, error: Error?) in
            if let userToken = userToken {
              self.musicToken = userToken
              print("music token: \(userToken)")
              self.loggedInUIUpdate()
              self.loggedIn = true
              self.saveDefaultsData{}
            }
            if let error = error {
              print(error)
            }
    }
  }
  
  @IBAction func subBtnPressed(_ sender: DesignableButton) {
    let controller = SKCloudServiceController()
    controller.requestCapabilities { (capabilities: SKCloudServiceCapability, error: Error?) in
      let canSub = capabilities.contains(.musicCatalogSubscriptionEligible)
      let playback = capabilities.contains(.musicCatalogPlayback)
      if (canSub && !playback) {
        print("canSubscribe")
        let view = SKCloudServiceSetupViewController()
        view.load(options: [.action : SKCloudServiceSetupAction.subscribe],
                            completionHandler: { (result, error) in
                              print("loaded")
        })
        self.present(view,
                animated: true,
                completion: nil)
      }
    }
  }
  
  
  // MARK:- Segue biz
  @IBAction func unwindWithSegue(_ segue: UIStoryboardSegue) {
  }
  @IBAction func unwindFromGuestSearch(_ segue: UIStoryboardSegue){
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "ToAllHostPL" {
      let destination = segue.destination as! HostAllPLVC
      destination.playlists = playlists
      destination.musicToken = musicToken
      destination.devToken = devToken
    } else if segue.identifier == "ToGetPlaylistID" {
      let destination = segue.destination as! EnterPlaylistVC
      destination.musicToken = musicToken
      destination.devToken = devToken
    }
  }
}
