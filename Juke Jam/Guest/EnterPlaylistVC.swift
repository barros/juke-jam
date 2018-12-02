//
//  EnterPlaylistVC.swift
//  Juke Jam
//
//  Created by Jeffrey Barros Peña on 7/23/18.
//  Copyright © 2018 Barros Peña. All rights reserved.
//

import UIKit

class EnterPlaylistVC: UIViewController {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var enterValidIDLabel: UILabel!
    var playlistID = ""
    var validIDEntered = true
    
    var musicToken = ""
    var devToken = ""
    
    override func viewDidLoad() {
        textField.text = "PkxVBOeFzg7q3g"
    }
    
    @IBAction func textFieldChanged(_ sender: UITextField) {
        print(1)
        if (textField.text == "") {
            validIDEntered = false
            playlistID = ""
            print(2)
            print("validIDEntered: \(validIDEntered)")
        } else if (textField.text?.count == 16) && (textField.text?.hasPrefix("p."))!{
            validIDEntered = true
            //playlistID = textField.text!
            print(3)
            print("validIDEntered: \(validIDEntered)")
        } else {
            validIDEntered = false
            print("validIDEntered: \(validIDEntered)")
        }
       
    }
    @IBAction func enterBtnPressed(_ sender: DesignableButton) {
        //print(4)
        if validIDEntered {
            //print(5)
            enterValidIDLabel.isHidden = true
            playlistID = textField.text!
            performSegue(withIdentifier: "ToGuestSongSearch", sender: self)
        } else {
            enterValidIDLabel.isHidden = false
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToGuestSongSearch" {
            let destination = segue.destination as! SearchSongVC
            destination.devToken = devToken
            destination.musicToken = musicToken
            destination.playlistID = playlistID
        }
    }
    
}
