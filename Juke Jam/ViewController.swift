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
import SKActivityIndicatorView

class ViewController: UIViewController {
  
  // labels
  @IBOutlet weak var jukeJamLabel: UILabel!
  @IBOutlet weak var greetingLabel: UILabel!
  @IBOutlet weak var loginLabel: UILabel!
  @IBOutlet weak var showPlaylistsLabel: UILabel!
  @IBOutlet weak var welcomeLabel: UILabel!
  @IBOutlet weak var nowLoggedInLabel: UILabel!
  
  //buttons
  @IBOutlet weak var getStartedBtn: DesignableButton!
  @IBOutlet weak var showPlaylistsBtn: DesignableButton!
  @IBOutlet weak var recommendBtn: DesignableButton!
  @IBOutlet weak var loginBtnView: DesignablePopup!
  @IBOutlet weak var subscribeBtn: DesignableButton!
  
  
  var tokens = Tokens()
  var devToken = ""
  var musicToken = ""
  var ip = Routing().getIP()
  var port = Routing().getPort()
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    //loadDefaultsData()
    fetchTokens()
    
    SKActivityIndicator.spinnerStyle(.spinningCircle)
    SKActivityIndicator.show("", userInteractionStatus: false)
  
    jukeJamLabel.center = self.view.center
    // make labels invisible
    greetingLabel.alpha = 0
    getStartedBtn.alpha = 0
    //selectionLabel.alpha = 0
    loginLabel.alpha = 0
    showPlaylistsLabel.alpha = 0
    welcomeLabel.alpha = 0
    nowLoggedInLabel.alpha = 0
    // make buttons invisible
    showPlaylistsBtn.alpha = 0
    recommendBtn.alpha = 0
    loginBtnView.alpha = 0
    subscribeBtn.alpha = 0
  }
  
  func fetchTokens() {
    print("fetchTokens()")
    musicToken = tokens.getMusicToken()
    print("ip: \(ip)")
    print("port: \(port)")

    let reqURL = URL(string: "http://\(ip):\(port)/devToken/")!
    var request = URLRequest(url: reqURL)
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")

    Alamofire.request(request).responseJSON { response in
      switch response.result {
      case .success(let value):
        let json = JSON(value)
        let result = json["devToken"].stringValue
        self.tokens.setDevToken(newToken: result)
        self.devToken = result
      case .failure(let error):
        print("ERROR: failed to get data: \(error.localizedDescription)")
      }
      self.setup()
    }
  }
  
  func setup() {
    print("setup()")
    if musicToken != "" {
      checkTokenStatus()
    } else {
      SKActivityIndicator.dismiss()
      launchAnimation()
      SKCloudServiceController.requestAuthorization { (status: SKCloudServiceAuthorizationStatus) in
        switch status {
        case .authorized: print("authorized")
        case .denied, .restricted: print("denied, restricted")
        case .notDetermined: print("notDetermined")
        }
      }
    }
  }
  
  // Confirm music token is valid by sending request to Apple Music
  // API and checking status code (200=success), (403=forbidden)
  func checkTokenStatus() {
    print("checkTokenStatus()")
    let playlistRequestURL = URL(string: "https://api.music.apple.com/v1/me/library/playlists")
    var request = URLRequest(url: playlistRequestURL!)
    request.setValue("Bearer \(devToken)", forHTTPHeaderField: "Authorization")
    request.setValue(musicToken, forHTTPHeaderField: "Music-User-Token")
    
    Alamofire.request(request).responseJSON { response in
      let code = response.response?.statusCode
      print("res code: \(code!)")
      SKActivityIndicator.dismiss()
      if code == 200 {
        // success
        self.loggedInUIUpdate()
      } else {
        // fail
        self.launchAnimation()
        self.tokens.setMusicToken(newToken: "")
      }
    }
  }
  
  // MARK:- Animations
  // UI update after successful login
  func loggedInUIUpdate() {
    UIView.animate(withDuration: 0.5, delay: 0.6, options: [], animations: {
      self.loginLabel.alpha = 0
      self.loginBtnView.alpha = 0
      self.subscribeBtn.alpha = 0
    
      self.welcomeLabel.alpha = 1
      self.nowLoggedInLabel.alpha = 1
      self.showPlaylistsLabel.alpha = 1
      self.showPlaylistsBtn.alpha = 1
      self.recommendBtn.alpha = 1
    }, completion: nil)
  }
  // Initial launch animation
  func launchAnimation() {
    UIView.animate(withDuration: 0.5, delay: 0, options: [], animations: {
      //self.actIndView.isHidden = true
      self.greetingLabel.alpha = 1
      self.getStartedBtn.alpha = 1
    }, completion: nil)
  }
  
  // MARK:- Button Actions
  @IBAction func getStartedPressed(_ sender: DesignableButton) {
    UIView.animate(withDuration: 0.5, delay: 0.4, options: [], animations: {
        self.getStartedBtn.alpha = 0
        self.greetingLabel.alpha = 0
        self.loginLabel.alpha = 1
        self.loginBtnView.alpha = 1
        self.subscribeBtn.alpha = 1
    }, completion: nil)
  }
  
  @IBAction func loginClicked(_ sender: UIButton) {
    SKActivityIndicator.show("Authenticating", userInteractionStatus: false)
    //actIndView.isHidden = false
    let controller = SKCloudServiceController()
    controller.requestUserToken(forDeveloperToken: devToken) { (userToken: String?, error: Error?) in
      //self.actIndView.isHidden = true
      SKActivityIndicator.dismiss()
      
      if let userToken = userToken {
        self.tokens.setMusicToken(newToken: userToken)
        self.musicToken = userToken
        self.loggedInUIUpdate()
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
  
  // MARK:- Segue Functions
  @IBAction func unwindWithSegue(_ segue: UIStoryboardSegue) {
  }
  @IBAction func unwindFromGuestSearch(_ segue: UIStoryboardSegue){
  }
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "ToAllHostPL" {
      let destination = segue.destination as! HostAllPLVC
      destination.musicToken = musicToken
      destination.devToken = devToken
    } else if segue.identifier == "ToGetPlaylistID" {
      let destination = segue.destination as! EnterPlaylistVC
      destination.musicToken = musicToken
      destination.devToken = devToken
    }
  }
}
