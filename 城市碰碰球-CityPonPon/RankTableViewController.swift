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
        cell.scoreLabel.text = String(describing: player.score!)
        cell.rankLabel.text = String(describing: indexPath.row + 1)
        cell.playerImage.sd_setImage(with: player.imageURL, placeholderImage: #imageLiteral(resourceName: "Unknown"))
        cell.playerImage.clipsToBounds = true
        cell.playerImage.layer.cornerRadius = cell.playerImage.frame.height / 2
        
        
    }
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
