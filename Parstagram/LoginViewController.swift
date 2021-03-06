//
//  LoginViewController.swift
//  Parstagram
//
//  Created by Andy Celdo on 3/17/21.
//

import UIKit
import AlamofireImage
import Parse


class LoginViewController: UIViewController {

    // MARK: - Initializing variables
    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    // MARK: - Override Functions
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    //MARK: - IBActions
    @IBAction func onSignIn(_ sender: Any) {
    
        let username = usernameField.text!
        let password = passwordField.text!
        
        PFUser.logInWithUsername(inBackground: username, password: password) { (user, error) in
        
            if user != nil{
                self.performSegue(withIdentifier: "loginSegue", sender: nil)
            } else {
                print("Error with login up \(String(describing: error?.localizedDescription))")
            }
        }
        
    }
    
    @IBAction func onSignUp(_ sender: Any) {
    
        let user = PFUser()
        user.username = usernameField.text
        user.password = passwordField.text
//        user.email = "email@example.com"
        // other fields can be set just like with PFObject
//        user["phone"] = "415-392-0202"
        
        user.signUpInBackground { (success, error) in
            if success {
                self.performSegue(withIdentifier: "loginSegue", sender: nil)
            } else {
                print("Error with sign up \(String(describing: error?.localizedDescription))")
            }
        }
        
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
