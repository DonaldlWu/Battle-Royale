//
//  EditProfileTableViewController.swift
//  城市碰碰球-CityPonPon
//
//  Created by Vince Lee on 2017/10/12.
//  Copyright © 2017年 吳得人. All rights reserved.
//

import UIKit
import Firebase


class EditProfileTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var players: [Player] = []
    var colorIndex = Int()
    var playerImage = UIImage()
    var isChangeImage = false
    var colorsToChoose = SettingTableViewController().colorsToChoose
    var ref: DatabaseReference?
    let storage = Storage.storage()
    var colorController = ColorController()
    
    @IBOutlet weak var colorsPickerView: UIPickerView!
    
    @IBOutlet weak var playerImageButton: UIButton!
    
    @IBAction func playerImageButtonPressed(_ sender: Any) {
        func chooseHowToPhoto() {
            // setting alertController
            let alertController = UIAlertController(title: "Photo", message: "Choose from", preferredStyle: .actionSheet)
            // getting photo by camera
            let cameraAction = UIAlertAction(title: "Camera", style: .default) {(action: UIAlertAction!) -> Void  in
                
                let imagePicker = UIImagePickerController()
                
                imagePicker.sourceType = .camera
                imagePicker.delegate = self
                
                self.present(imagePicker, animated: true, completion: nil)
                
            }
            // getting photo by photo library
            let photolibraryAction = UIAlertAction(title: "Photo Library", style: .default) {(action: UIAlertAction!) -> Void  in
                
                let imagePicker = UIImagePickerController()
                imagePicker.allowsEditing = true
                imagePicker.sourceType = .photoLibrary
                
                imagePicker.delegate = self
                
                self.present(imagePicker, animated: true, completion: nil)
                
            }
            // add additional cancel button
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            alertController.addAction(cameraAction)
            alertController.addAction(photolibraryAction)
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)
        }
        chooseHowToPhoto()
    }
    @IBAction func savePressed(_ sender: Any) {
        
        updatePlayerProfile()
    }
    
    
    @IBOutlet weak var nameTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(playerImage)
        nameTextField.text = players[0].username
        playerImageButton.clipsToBounds = true
        playerImageButton.imageView?.contentMode = .scaleAspectFill
        playerImageButton.layer.cornerRadius = playerImageButton.frame.height / 2
        playerImageButton.setImage(playerImage, for: .normal)
        
        
        // colorsPicker
        colorsPickerView.dataSource = self
        colorsPickerView.delegate = self
        colorsPickerView.selectRow(colorIndex, inComponent: 0, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        isChangeImage = true
        let image = info[UIImagePickerControllerOriginalImage] as? UIImage
        
        playerImageButton.setImage(image, for: .normal)
        
        dismiss(animated: true, completion: nil)
    }
    
    func updatePlayerProfile() {
        if (nameTextField.text?.count)! >= 3 && (nameTextField.text?.count)! <= 12 {
            ref = Database.database().reference()
            if let user = Auth.auth().currentUser {
                ref?.child("users").child(user.uid).updateChildValues(["username" : nameTextField.text!])
                
                // update player image
                uploadImage()
                
                // update circle color
                let selectRow =  colorsPickerView.selectedRow(inComponent: 0)
                MapViewController.mainPlayerColor = colorsToChoose[selectRow]
                
                colorController.save(colorIndex: selectRow)
                
                performSegue(withIdentifier: PropertKeys.unwindToSettingPageWithSegue, sender: nil)
            }
        } else {
            nameTooShort()
        }
    }
    func nameTooShort() {
        let retryAction = UIAlertAction(title: "再試一次", style: .cancel, handler: nil)
        let alertController = UIAlertController(title: "Error", message: "名字要3個字以上，12個字以下喔", preferredStyle: .alert)
        
        alertController.addAction(retryAction)
        present(alertController, animated: true, completion: nil)
    }
    func uploadImage() {
        let storageRef = storage.reference()
        let uid = Auth.auth().currentUser?.uid
        let userProfilePic = storageRef.child("images/\(uid!).jpg")
        if let image = playerImageButton.image(for: .normal), let data = UIImageJPEGRepresentation(image, 1) {
            
            let uploadTask = userProfilePic.putData(data, metadata: nil) { (metadata, error) in
                guard let metadata = metadata else {
                    // Uh-oh, an error occurred!
                    print(error)
                    return
                }
                // Metadata contains file metadata such as size, content-type, and download URL.
                if let downloadURL = metadata.downloadURL() {          
                self.ref?.child("users").child(uid!).child("image").setValue("\(downloadURL)")
                }
            }
        } else {
            print("upload error")
        }
    }
}
