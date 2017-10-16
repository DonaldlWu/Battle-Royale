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
    var loginDefault: UserDefaults!
    var colorController = ColorController()
    
    // The pages it contains
    var pages = [UIViewController]()
    
    // Track the current index
    var currentIndex: Int?
    var pendingIndex: Int?
    
    @IBOutlet weak var firstCellView: UIView!
    
    var pageContainer: UIPageViewController!
    
    @IBOutlet weak var playerImageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var playButton: UIButton!
    
    @IBOutlet weak var pageControl: UIPageControl!
    
    @IBAction func pageControlPressed(_ sender: Any) {
        
        
    }
    
    @IBAction func playButtonPressed(_ sender: Any) {
        
        if (nameTextField.text?.count)! >= 3 && (nameTextField.text?.count)! <= 12 {
            ref = Database.database().reference()
            if let user = Auth.auth().currentUser {
                ref?.child("users").child(user.uid).updateChildValues(["username" : nameTextField.text!])
                uploadImage()
                loginDefault.set(
                    true, forKey: user.uid)
                colorController.save(colorIndex: 0)
                
                performSegue(withIdentifier: PropertKeys.tutorialToTabBarSegue, sender: nil)
            }
        } else {
            nameTooShort()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupPages()
        
        if let displayName = Auth.auth().currentUser?.displayName {
            nameTextField.text = displayName
        }
        
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
       
    }
    
    override func viewDidAppear(_ animated: Bool) {
        loginDefault = UserDefaults.standard
        if let uid = Auth.auth().currentUser?.uid {
            let login = loginDefault.bool(forKey: uid)
            
            if login {
                print(login)
                performSegue(withIdentifier: PropertKeys.tutorialToTabBarSegue, sender: nil)
            }
        }
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
}
