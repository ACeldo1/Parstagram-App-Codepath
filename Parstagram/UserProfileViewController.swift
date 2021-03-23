//
//  UserProfileViewController.swift
//  Parstagram
//
//  Created by Andy Celdo on 3/22/21.
//

import UIKit
import AlamofireImage
import Parse

class UserProfileViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet var testingImg: UIImageView!
    
    var profile = [PFObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //checking if there is any profile pic available
//        let post = posts[indexPath.section]
//        let comments = (post["comments"] as? [PFObject]) ?? []
        
//        let user = post["author"] as! PFUser
//        cell.usernameLabel.text = user.username
//
//        cell.captionLabel.text = post["caption"] as? String
//
//        let imageFile = post["image"] as! PFFileObject
//        let urlStr = imageFile.url!
//        let url = URL(string: urlStr)!
//
//        cell.photoView.af.setImage(withURL: url)
        
//        let query = PFQuery(className: "User")
//        query.includeKeys(["profilePic"])
//
//        query.limit = 1
//
//        query.findObjectsInBackground { (data, error) in
//            if data != nil {
//                self.profile = data!
//
////                let prof = self.profile[0]
//        //        let pic = (prof["profilePic"] as? [PFObject]) ?? []
//                if self.profile[0] != nil {
//                    let imageFile = self.profile[0]["profilePic"] as! PFFileObject
//                    let urlStr = imageFile.url!
//                    let url = URL(string: urlStr)!
//
//                    self.testingImg.af.setImage(withURL: url)
//                }
//
//
//            } else {
//                print("Error: \(String(describing: error))")
//            }
//        }
        
        
    }
    
    @IBAction func onPicSelection(_ sender: Any) {
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
     
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            picker.sourceType = .camera
        } else {
            picker.sourceType = .photoLibrary
        }
        
        present(picker, animated: true, completion: nil)
        
    }
    
    @IBAction func onSubmit(_ sender: Any) {
    
        let user = PFObject(className: "User")
        
        user["username"] = PFUser.current()!
        
        let imageData = profilePic.image!.pngData()
        let file = PFFileObject(name: "image.png", data: imageData!)
        
        user["profilePic"] = file
        
        user.saveInBackground { (success, error) in
            if success {
                self.dismiss(animated: true, completion: nil)
                let alert = UIAlertController(title: "Picture saved successfully!", message: "Press OK to dismiss", preferredStyle: .alert)
                alert .addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                print("saved user name info!")
            } else {
                print("error with submit button in UserProfileVC!")
            }
        }
        
        //testing uploaded image
        testingImg.image = user["profilePic"] as? UIImage
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.editedImage] as! UIImage
        let size = CGSize(width: 300, height: 300)
        let scaledImage = image.af.imageAspectScaled(toFill: size)
        
        profilePic.image = scaledImage
        
        dismiss(animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
