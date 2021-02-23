//
//  LoginViewController.swift
//  TheMovieManager
//
//  Created by Owen LaRosa on 8/13/18.
//  Copyright © 2018 Udacity. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var loginViaWebsiteButton: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        emailTextField.text = ""
        passwordTextField.text = ""
    }
    
    @IBAction func loginTapped(_ sender: UIButton) {
//        performSegue(withIdentifier: "completeLogin", sender: nil)
        TMDBClient.getRequestToken(completion: handleResquesToken(isSuccess:error:))
    }
    
    @IBAction func loginViaWebsiteTapped() {
        TMDBClient.getRequestToken(){ isSuccess, error in
            if isSuccess {
                DispatchQueue.main.async {
                    UIApplication.shared.open(TMDBClient.Endpoints.webAuth.url, options: [:], completionHandler: nil)
                }
                
                //performSegue(withIdentifier: "completeLogin", sender: nil)
            }
        }
    }
    
    
    func handleResquesToken(isSuccess:Bool, error: Error?){
        
        if isSuccess {
            DispatchQueue.main.async {
                let username = self.emailTextField.text!
                let password = self.passwordTextField.text!
                TMDBClient.getLoginRequest(username, password, completion: self.handleLoginResponse(isSuccess:error:))
            }
            
        }else{
            print("Something went wrong! \(String(describing: error))")
        }
    }
    
    func handleLoginResponse(isSuccess:Bool, error: Error?) {
        if isSuccess {
            TMDBClient.getSessionRequest(completion: self.handleSessionResponse(isSuccess:error:))
        }else{
            print("Failed to login! Check your email or password.")
        }
        
    }
    
    func handleSessionResponse(isSuccess:Bool, error: Error?) {
        if isSuccess {
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "completeLogin", sender: nil)
            }
        }else{
            print("Something went wrong! \(String(describing: error))")
        }
    }
}
