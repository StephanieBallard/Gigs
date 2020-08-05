//
//  LoginViewController.swift
//  Gigs
//
//  Created by Stephanie Ballard on 8/5/20.
//  Copyright © 2020 Stephanie Ballard. All rights reserved.
//

import UIKit

enum LoginType {
    case login
    case signup
}

class LoginViewController: UIViewController {
    
    var gigController: GigController?
    var loginType: LoginType = .signup
    
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var signUpLogInSegmentedControl: UISegmentedControl!
    @IBOutlet weak var signInLogInButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        signInLogInButton.backgroundColor = UIColor(hue: 190/360, saturation: 70/100, brightness: 80/100, alpha: 1.0)
        signInLogInButton.tintColor = .white
        signInLogInButton.layer.cornerRadius = 8.0

        // Do any additional setup after loading the view.
    }
    @IBAction func signUpLogInSegmentedControlTapped(_ sender: UISegmentedControl) {
        if signUpLogInSegmentedControl.selectedSegmentIndex == 0 {
            loginType = .signup
            signInLogInButton.setTitle("Sign Up", for: .normal)
        } else {
            loginType = .login
            signInLogInButton.setTitle("Log In", for: .normal)
        }
    }
    
    @IBAction func signInLogInButtonTapped(_ sender: UIButton) {
        guard let gigController = gigController else { return }
        if let username = usernameTextField.text,
            !username.isEmpty,
            let password = passwordTextField.text,
            !password.isEmpty {
            
            let user = User(username: username, password: password)
            
            if loginType == .signup {
                gigController.signUp(with: user, completion: { result in
                    do {
                        let success = try result.get()
                        if success {
                            DispatchQueue.main.async {
                                let alertController = UIAlertController(title: "Sign Up Successful", message: "Please log in", preferredStyle: .alert)
                                let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                                alertController.addAction(alertAction)
                                self.present(alertController, animated: true) {
                                    self.loginType = .login
                                    self.signUpLogInSegmentedControl.selectedSegmentIndex = 1
                                    self.signInLogInButton.setTitle("Sign In", for: .normal)
                                }
                            }
                        }
                    } catch {
                        print("Error signing up: \(error)")
                    }
                })
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
