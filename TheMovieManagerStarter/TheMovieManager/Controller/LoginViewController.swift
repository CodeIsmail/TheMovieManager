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
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        emailTextField.text = ""
        passwordTextField.text = ""
    }
    
    @IBAction func loginTapped(_ sender: UIButton) {
        TMDBClient.getRequestToken(completion: handleResquestToken(isSuccess:error:))
    }
    
    @IBAction func loginViaWebsiteTapped() {
        TMDBClient.getRequestToken(){ isSuccess, error in
            if isSuccess {
                UIApplication.shared.open(TMDBClient.Endpoints.webAuth.url, options: [:], completionHandler: nil)
            }
        }
    }
    
    
    func handleResquestToken(isSuccess:Bool, error: Error?){
        setLoggingIn(true)
        if isSuccess {
            let username = emailTextField.text!
            let password = passwordTextField.text!
            TMDBClient.getLoginRequest(username, password, completion: handleLoginResponse(isSuccess:error:))
            
        }else{
            showLoginFailure(message: error?.localizedDescription ?? "")
        }
    }
    
    func handleLoginResponse(isSuccess:Bool, error: Error?) {
        setLoggingIn(true)
        if isSuccess {
            TMDBClient.getSessionRequest(completion: self.handleSessionResponse(isSuccess:error:))
        }else{
            showLoginFailure(message: error?.localizedDescription ?? "")
        }
        
    }
    
    func handleSessionResponse(isSuccess:Bool, error: Error?) {
        setLoggingIn(false)
        if isSuccess {
            performSegue(withIdentifier: "completeLogin", sender: nil)
        }else{
            showLoginFailure(message: error?.localizedDescription ?? "")
        }
    }
    
    func setLoggingIn(_ loggingIn: Bool) {
        if loggingIn {
            activityIndicator.startAnimating()
        }else{
            activityIndicator.stopAnimating()
        }
        setUIState(!loggingIn)
    }
    
    func setUIState(_ isLoading: Bool){
        emailTextField.isEnabled = isLoading
        passwordTextField.isEnabled = isLoading
        loginButton.isEnabled = isLoading
        loginViaWebsiteButton.isEnabled = isLoading
    }
    
    func showLoginFailure(message: String) {
        let alertVC = UIAlertController(title: "Login Failed", message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        show(alertVC, sender: nil)
    }
}
