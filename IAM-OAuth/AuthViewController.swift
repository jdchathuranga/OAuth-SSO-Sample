//
//  ViewController.swift
//  IAM-OAuth
//
//  Created by Chathuranga Disanayaka on 1/16/18.
//  Copyright © 2018 WSO2 Inc. All rights reserved.
//

import UIKit
import AppAuth


class AuthViewController: UIViewController, OIDAuthStateErrorDelegate, OIDAuthStateChangeDelegate {

    let clientId = "dGeebJ3zFegVZEUc4Tk5kjpeu9ka"
    let clientSecret = "_EPk7q4KcDiAwhMfxlvFcHoVmoga"
    
    let redirectURI = URL(string:"com.wso2://oauth")
    
    let authURL = URL(string: "https://www.wso2oauth.com:9443/oauth2/authorize")
    let tokenURL = URL(string: "https://www.wso2oauth.com:9443/oauth2/token")
    
//    if using DCR.
    let registerURL = URL(string:"https://www.wso2oauth.com:9443/identity/connect/register")
    
//    This confirms NSCoding, so archive and store.
    var oidAuthState:OIDAuthState?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.loadOidState()
    }

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
        
        deligate.currentAuthorizationFlow = OIDAuthState.authState(byPresenting: authrequest, presenting: self, callback: { (oidAuthStateResponse, error) in
            
            if let _ = error {
                print("Authentication Failed..")
                self.oidAuthState = nil
            }
            
            if let authState = oidAuthStateResponse {
                print("Authentication Success - Auth State: \(authState)")
                
                self.updateAuthState(authState: authState)
                self.loginToTheApp()
            }
            
        })
    }
    
    func saveOidState(authState:OIDAuthState) {
        
        if let state = oidAuthState {
            
            if (state == authState) {
                return
            }
            
            let archivedState = NSKeyedArchiver.archivedData(withRootObject: state)
            UserDefaults.standard.set(archivedState, forKey: "com.wso2.oidauthstate")
            UserDefaults.standard.synchronize()
        } else {
            UserDefaults.standard.removeObject(forKey: "com.wso2.oidauthstate")
        }
    }
    
    func loadOidState() {
        if let archivedState = UserDefaults.standard.value(forKey: "com.wso2.oidauthstate") as? Data {
            if let state = NSKeyedUnarchiver.unarchiveObject(with: archivedState) as? OIDAuthState {
                self.updateAuthState(authState: state)
            }
            
        }
    }
    
    func updateAuthState(authState:OIDAuthState) {
        self.oidAuthState = authState
        self.oidAuthState?.errorDelegate = self
        self.oidAuthState?.stateChangeDelegate = self
        self.saveOidState(authState: authState)
    }
    
    func didChange(_ state: OIDAuthState) {
        self.updateAuthState(authState: state)
    }
    
    func authState(_ state: OIDAuthState, didEncounterAuthorizationError error: Error) {
        print("OID State Error \(error)")
    }
    
    
    func loginToTheApp() {
        
        
//        If you need to refresh the token.
//
//        let lastToken = oidAuthState?.lastTokenResponse?.accessToken
//
//        oidAuthState?.setNeedsTokenRefresh()
//
//        oidAuthState?.performAction(freshTokens: { (accessToken, idToken, error) in
//
//        })
        
        
        let homeViewController = self.storyboard?.instantiateViewController(withIdentifier: "HomeViewController")
        self.navigationController?.pushViewController(homeViewController!, animated: true)
    }
    
}

