//
//  RankTableViewController.swift
//  Battle Royale
//
//  Created by Vince Lee on 2017/9/11.
//  Copyright © 2017年 吳得人. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
import FBSDKLoginKit
import FirebaseStorage
import SDWebImage

class RankTableViewController: UITableViewController {
    
    var ref: DatabaseReference!
    var players: [Player] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        let colors = [#colorLiteral(red: 0.3476037681, green: 0.4178079367, blue: 0.5853316188, alpha: 1).cgColor, #colorLiteral(red: 0.01379980333, green: 0.2095791996, blue: 0.5689586401, alpha: 1).cgColor]
       // addGradiantLayer(sender: self, colors: colors )
        fetchAllPlayerSocre()
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(logout))
    }
    
    func fetchAllPlayerSocre() {
        ref = Database.database().reference()
        ref.child("users").observe(.value, with: { (snapshot) in
            var newPlayers = [Player]()
            let allUsers = snapshot.children
            for user in allUsers {
                if let user = user as? DataSnapshot {
                    let player = Player(snapshot: user)
                    newPlayers.append(player)
                    self.players = newPlayers
                }
            }
            self.players = self.players.sorted(by: { (playerA, playerB) -> Bool in
                playerA.score! > playerB.score!
            })
            self.tableView.reloadData()
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
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if players.count > 20 {
            return 20
        } else {
            return players.count
        }
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> RankTableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PropertKeys.rankCell, for: indexPath)
        
        configure(cell: cell as! RankTableViewCell, forItemAt: indexPath)
        
        return cell as! RankTableViewCell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    
    
    func configure(cell: RankTableViewCell, forItemAt indexPath: IndexPath) {
        
        
        
        let player = players[indexPath.row]
        cell.nameLabel?.text = player.username
        cell.nameLabel?.textColor = .black
        cell.scoreLabel.text = String(describing: player.score!)
         cell.scoreLabel?.textColor = .black
        cell.rankLabel.text = String(describing: indexPath.row + 1)
         cell.rankLabel?.textColor = .black
        cell.playerImage.sd_setImage(with: player.imageURL, placeholderImage: #imageLiteral(resourceName: "Unknown"))
        cell.playerImage.clipsToBounds = true
        cell.playerImage.layer.cornerRadius = cell.playerImage.frame.height / 2
       // cell.backgroundColor = UIColor.clear
        
    }
    
  
    
}
