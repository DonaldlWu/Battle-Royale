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
    
    @IBOutlet weak var playerImageView: UIImageView!
    var ref: DatabaseReference!
    var players: [Player] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchPlayerSocre { (newPlayers) in
            self.players = newPlayers
            self.configure()
            
        }
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func fetchPlayerSocre(completion: @escaping ([Player]) -> ()) {
        ref = Database.database().reference()
        let uid = Auth.auth().currentUser?.uid
        ref.child("users").child(uid!).observe(.value, with: { (snapshot) in
            
            var newPlayers = [Player]()
            let user = snapshot.children
            
            let player = Player(snapshot: snapshot)
            newPlayers.append(player)
            
            
            print(newPlayers.count)
            
            completion(newPlayers)
        }
        )}
    
    @objc func logout() {
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
        playerImageView.clipsToBounds = true
        playerImageView.layer.cornerRadius = playerImageView.frame.height / 2
    }
    
}
