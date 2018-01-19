//
//  ViewController.swift
//  IAM-OAuth
//
//  Created by Chathuranga Disanayaka on 1/16/18.
//  Copyright © 2018 WSO2 Inc. All rights reserved.
//

import UIKit
import AppAuth


class AuthViewController2: UIViewController {

    let clientId = "f1l5hvXVOcGNQNaJP4lPAjVJGw0a"
    let clientSecret = "OU4a2N4g0UhUxbCp12tzM92Qpj0a"
    
    let redirectURI = URL(string:"com.wso2app2://oauth")
    
    let authURL = URL(string: "https://www.wso2oauth.com:9443/oauth2/authorize")
    let tokenURL = URL(string: "https://www.wso2oauth.com:9443/oauth2/token")
    let registerURL = URL(string:"https://www.wso2oauth.com:9443/identity/connect/register")
    
    var oidAuthState:OIDAuthState?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.loadOidState()
    }
    
//    123, 31, 162

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func loginWithOAuthButtonTapped(_ sender: Any) {
        authenticatePKCE()
    }
    
    func authenticatePKCE() {
        let deligate = UIApplication.shared.delegate as! AppDelegate
        
        let config = OIDServiceConfiguration(authorizationEndpoint: authURL!, tokenEndpoint: tokenURL!)
        
        let codeVerifier = OIDAuthorizationRequest.generateCodeVerifier()
        
        let authrequest = OIDAuthorizationRequest(configuration: config,
                                                  clientId: clientId,
                                                  clientSecret: clientSecret,
                                                  scope: "default",
                                                  redirectURL: redirectURI!,
                                                  responseType: OIDResponseTypeCode,
                                                  state: OIDAuthorizationRequest.generateState(),
                                                  codeVerifier: codeVerifier,
                                                  codeChallenge: OIDAuthorizationRequest.codeChallengeS256(forVerifier: codeVerifier),
                                                  codeChallengeMethod: OIDOAuthorizationRequestCodeChallengeMethodS256,
                                                  additionalParameters: nil)
        
        deligate.currentAuthorizationFlow = OIDAuthState.authState(byPresenting: authrequest, presenting: self, callback: { (oidAuthState, error) in
            
            if let _ = error {
                print("Authentication Failed..")
            }
            
            if let authState = oidAuthState {
                print("Authentication Success - Auth State: \(authState)")
                self.oidAuthState = authState
                self.saveOidState()
                self.loginToTheApp()
            }
            
        })
    }
    
    func saveOidState() {
        
        if let state = oidAuthState {
            let archivedState = NSKeyedArchiver.archivedData(withRootObject: state)
            UserDefaults.standard.set(archivedState, forKey: "com.wso2.oidauthstate")
            UserDefaults.standard.synchronize()
        }
        
    }
    
    func loadOidState() {
        if let archivedState = UserDefaults.standard.value(forKey: "com.wso2.oidauthstate") as? Data {
            if let state = NSKeyedUnarchiver.unarchiveObject(with: archivedState) as? OIDAuthState {
                self.oidAuthState = state
            }
            
        }
    }
    
    func loginToTheApp() {
        let homeViewController = self.storyboard?.instantiateViewController(withIdentifier: "HomeViewController")
        self.navigationController?.pushViewController(homeViewController!, animated: true)
    }
    
}

