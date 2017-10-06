//
//  TutorialTableViewController.swift
//  Battle Royale
//
//  Created by Vince Lee on 2017/9/12.
//  Copyright © 2017年 吳得人. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage


class TutorialTableViewController: UITableViewController {
    
    var displayName: String?
    var ref: DatabaseReference?
    var playerImage: UIImage?
    let storage = Storage.storage()
    
    @IBOutlet weak var privacyPolicyView: UIView!
    
    @IBOutlet weak var playerImageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var playButton: UIButton!
    
    @IBOutlet weak var pageControl: UIPageControl!
    
    @IBAction func pageControlPressed(_ sender: Any) {
        
        
    }
    
    @IBAction func playButtonPressed(_ sender: Any) {
        
        if (nameTextField.text?.characters.count)! >= 3 && (nameTextField.text?.characters.count)! <= 12 {
            ref = Database.database().reference()
            if let user = Auth.auth().currentUser {
                ref?.child("users").child(user.uid).updateChildValues(["username" : nameTextField.text!])
                uploadImage()
                performSegue(withIdentifier: PropertKeys.tutorialToTabBarSegue, sender: nil)
            }
        } else {
            nameTooShort()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let displayName = Auth.auth().currentUser?.displayName {
            nameTextField.text = displayName
        }
        
        privacyPolicyView.layer.borderWidth = 1
        privacyPolicyView.layer.cornerRadius = 5
        
        nameTextField.layer.masksToBounds = true
        nameTextField.textAlignment = .center
        playButton.layer.cornerRadius = 10
        
        playerImageView.clipsToBounds = true
        
        playerImageView.layer.cornerRadius = playerImageView.frame.height / 2
        
        
        fetchUserImage(completion: { (image) in
            DispatchQueue.main.async {
                self.playerImage = image
                self.playerImageView.image = image
            }
        })
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    func nameTooShort() {
        let retryAction = UIAlertAction(title: "再試一次", style: .cancel, handler: nil)
        let alertController = UIAlertController(title: "Error", message: "名字要3個字以上，12個字以下喔", preferredStyle: .alert)
        
        alertController.addAction(retryAction)
        present(alertController, animated: true, completion: nil)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    
    
    /*
     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
     
     // Configure the cell...
     
     return cell
     }
     */
    
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
