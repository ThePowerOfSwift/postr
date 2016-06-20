//
//  LoginController.swift
//  Postr
//
//  Created by Steven Kingaby on 07/06/2016.
//  Copyright © 2016 Steven Kingaby. All rights reserved.
//

import UIKit
import Alamofire

class LoginController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var loginView: PostrView!
    @IBOutlet weak var registerView: PostrView!
    @IBOutlet weak var loginUsernameField: UITextField!
    @IBOutlet weak var loginPasswordField: UITextField!
    @IBOutlet weak var registerUsernameField: UITextField!
    @IBOutlet weak var registerPasswordField: UITextField!
    @IBOutlet weak var activityView: UIView!
    
    @IBAction func loginButton(sender: AnyObject) {
        loginToAccount()
    }
    
    
    @IBAction func createAccountButton(sender: AnyObject) {
        displayRegisterView()
    }
    
    
    @IBAction func registerButton(sender: AnyObject) {
        registerAccount()
    }
    
    
    @IBAction func backToLoginButton(sender: AnyObject) {
        displayLoginView()
    }
    
    @IBAction func cancelToLoginController(segue:UIStoryboardSegue) {
        
    }
    
    // variable to handle networking helper functions
    let httpNetworking = HTTPNetworking()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        setupStyle()
        
        // Add tap gesture
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LoginController.hideKeyboard))
        view.addGestureRecognizer(tap)
    }
    

    // Triggers view's text fields to resign first responder status
    func hideKeyboard() {
        view.endEditing(true)
    }

    
    func registerAccount() {
        httpNetworking.startActivityIndicator(self.view)
        let url = HTTPNetworking.postrURL + "/register"
        
        // Make sure all fields have been filled out
        if (registerUsernameField.text! == "" ||
            registerPasswordField.text! == "") {
            return
        }
        
        let parameters = [
            "username": registerUsernameField.text!,
            "password": registerPasswordField.text!
        ]

        // Submit user details in http post request to server
        Alamofire.request(.POST, url, parameters: parameters).responseJSON { response in
                if let JSON = response.result.value {
                    let tokenDict = JSON as! NSDictionary
                    HTTPNetworking.JWT = tokenDict["token"] as! String
                }
            
            self.registerUsernameField.text = nil
            self.registerPasswordField.text = nil
            self.performSegueWithIdentifier("segueNearestEvents", sender: nil)
            self.httpNetworking.stopActivityIndicator(self.view)
        }
    }
    
    func loginToAccount() {
        httpNetworking.startActivityIndicator(self.view)
        let url = HTTPNetworking.postrURL + "/login"
        
        if (loginUsernameField.text! == "" ||
            loginPasswordField.text! == "") {
            return
        }
        
        let parameters = [
            "username": loginUsernameField.text!,
            "password": loginPasswordField.text!
        ]
        
        // Submit user details in http post request to server
        Alamofire.request(.POST, url, parameters: parameters).responseJSON { response in
            if let JSON = response.result.value {
                let tokenDict = JSON as! NSDictionary
                HTTPNetworking.JWT = tokenDict["token"] as! String
                HTTPNetworking.username = tokenDict["username"] as! String
            }
            
            self.loginUsernameField.text = nil
            self.loginPasswordField.text = nil
            
            self.performSegueWithIdentifier("segueNearestEvents", sender: nil)
            self.httpNetworking.stopActivityIndicator(self.view)
        }
    }

    func displayRegisterView() {
        // login fields
        self.loginUsernameField.text = nil
        self.loginPasswordField.text = nil

        // Clears keyboard away view
        if registerUsernameField.isFirstResponder() {
            registerUsernameField.resignFirstResponder()
        } else if registerPasswordField.isFirstResponder() {
            registerPasswordField.resignFirstResponder()
        }
        
        // display register view
        UIView.animateWithDuration(0.9, animations: { () -> Void in
            self.registerView.frame = CGRectMake(self.registerView.frame.origin.x - self.registerView.frame.width,
                                                 self.registerView.frame.origin.y, self.registerView.frame.width,
                                                 self.registerView.frame.height)
        }, completion: nil)
    }
    
    func displayLoginView() {
        self.registerUsernameField.text = nil
        self.registerPasswordField.text = nil
        
        // Clears keyboard away view
        if loginUsernameField.isFirstResponder() {
            loginUsernameField.resignFirstResponder()
        } else if loginUsernameField.isFirstResponder() {
            loginUsernameField.resignFirstResponder()
        }
        
        UIView.animateWithDuration(0.9, animations: { () -> Void in
            self.registerView.frame = CGRectMake(self.registerView.frame.width, self.registerView.frame.origin.y,
                                                 self.registerView.frame.width, self.registerView.frame.height)
        }, completion: nil)
    }
    
   
    func setupStyle() {
        setUpTextField(loginUsernameField)
        setUpTextField(loginPasswordField)
        setUpTextField(registerUsernameField)
        setUpTextField(registerPasswordField)
    }
    
    // Sets fonts and a bottom border to given 
    // text fields
    func setUpTextField(textField: UITextField) {
        let border = CALayer()
        let width = CGFloat(1.0)
        border.borderColor = UIColor.lightGrayColor().CGColor
        border.frame = CGRect(x: 0, y: textField.frame.size.height - width, width:  textField.frame.size.width, height: textField.frame.size.height)
        border.borderWidth = width
        textField.layer.addSublayer(border)
        
        textField.font = UIFont(name: "coolvetica", size: 18)!
        textField.delegate = self;
    }
    
    // Designates
    func textFieldShouldReturn(userText: UITextField) -> Bool {
        userText.resignFirstResponder()
        return true;
    }

}
