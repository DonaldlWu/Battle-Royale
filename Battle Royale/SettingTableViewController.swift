//
//  SettingTableViewController.swift
//  城市碰碰球-CityPonPon
//
//  Created by Vince Lee on 2017/10/11.
//  Copyright © 2017年 吳得人. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
import FBSDKLoginKit
import SDWebImage


class SettingTableViewController: UITableViewController {
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    
    @IBOutlet weak var circleColorView: UIView!
    
    @IBOutlet weak var playerImageView: UIImageView!
    var ref: DatabaseReference!
    var players: [Player] = []
    var colorsToChoose = [#colorLiteral(red: 0.02806639113, green: 0.4978648424, blue: 1, alpha: 1), #colorLiteral(red: 1, green: 0.9818630815, blue: 0, alpha: 1), #colorLiteral(red: 1, green: 0, blue: 0.9234561324, alpha: 1), #colorLiteral(red: 0, green: 0.9673202634, blue: 1, alpha: 1), #colorLiteral(red: 1, green: 0.7024777532, blue: 0, alpha: 1), #colorLiteral(red: 0.7690714002, green: 0.6713362336, blue: 1, alpha: 1), #colorLiteral(red: 1, green: 0, blue: 0.3030588925, alpha: 1)]
    
    var colorController = ColorController()
    var colorIndex = 0
    
    
    override func viewDidLoad() {
        activityView.startAnimating()
        super.viewDidLoad()
        fetchPlayerSocre { (newPlayers) in
            self.players = newPlayers
            self.configure()
            self.activityView.stopAnimating()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    @IBAction func unwindToSettingPage(segue: UIStoryboardSegue) {
        circleColorView.backgroundColor = MapViewController.mainPlayerColor
        let source = segue.source as? EditProfileTableViewController
        
        if let image = source?.playerImageButton.image(for: .normal), let name = source?.nameTextField.text, let colorIndex = source?.colorsPickerView.selectedRow(inComponent: 0) {
            nameLabel.text = name
            playerImageView.image = image
            self.colorIndex = colorIndex
            circleColorView.backgroundColor = colorsToChoose[colorIndex]
            
        }
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            performSegue(withIdentifier: PropertKeys.editProfileSetting, sender: indexPath)
        }
        if indexPath.section == 2 && indexPath.row == 0 {
            let urlString = "https://www.facebook.com/CityPonPon/"
            if let url = URL(string: urlString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        if indexPath.section == 2 && indexPath.row == 1 {
            let urlString = "https://www.facebook.com/vince.lee.391"
            if let url = URL(string: urlString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func fetchPlayerSocre(completion: @escaping ([Player]) -> ()) {
        ref = Database.database().reference()
        let uid = Auth.auth().currentUser?.uid
        ref.child("users").child(uid!).observeSingleEvent(of: .value) { (snapshot) in
            
            var newPlayers = [Player]()
            let player = Player(snapshot: snapshot)
            newPlayers.append(player)
            completion(newPlayers)
        }
    }
    
    @IBAction func logout(_ sender: UIBarButtonItem) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        GIDSignIn.sharedInstance().signOut()
        FBSDKLoginManager().logOut()
        performSegue(withIdentifier: PropertKeys.unwindToLogin, sender: nil)
    }
    
    
    func configure() {
        nameLabel.text = players[0].username
        playerImageView.sd_setImage(with: players[0].imageURL, placeholderImage: #imageLiteral(resourceName: "Unknown"))
        playerImageView.contentMode = .scaleAspectFill
        playerImageView.clipsToBounds = true
        playerImageView.layer.cornerRadius = playerImageView.frame.height / 2
        
        
            
            let colorIndex = colorController.read()
            circleColorView.backgroundColor = colorsToChoose[colorIndex]
            self.colorIndex = colorIndex
        
        if circleColorView.backgroundColor == nil {
            circleColorView.backgroundColor = #colorLiteral(red: 0.02806639113, green: 0.4978648424, blue: 1, alpha: 1)
        }
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let image = playerImageView.image, segue.identifier == PropertKeys.editProfileSetting {
            let controller = segue.destination as? EditProfileTableViewController
            controller?.players = players
            controller?.colorIndex = colorIndex
            controller?.playerImage = image
        }
    }
    
}
