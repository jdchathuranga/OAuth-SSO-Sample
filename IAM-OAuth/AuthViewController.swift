//
//  ViewController.swift
//  IAM-OAuth
//
//  Created by Chathuranga Disanayaka on 1/16/18.
//  Copyright © 2018 WSO2 Inc. All rights reserved.
//

import UIKit
import AppAuth


class AuthViewController: UIViewController {

    let clientId = "dGeebJ3zFegVZEUc4Tk5kjpeu9ka"
    let clientSecret = "_EPk7q4KcDiAwhMfxlvFcHoVmoga"
    
    let redirectURI = URL(string:"com.wso2://oauth")
    
    let authURL = URL(string: "https://localhost:9443/oauth2/authorize")
    let tokenURL = URL(string: "https://localhost:9443/oauth2/token")
    let registerURL = URL(string:"https://localhost:9443/identity/connect/register")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func loginWithOAuthButtonTapped(_ sender: Any) {

        let alert = UIAlertController(title: "Select Flow", message: nil, preferredStyle: .actionSheet)
        
        
        let actionClientId = UIAlertAction(title: "Client ID/Secret", style: .default) { (_) in
            self.authenticate()
        }
        
        let actionPKCE = UIAlertAction(title: "PKCE", style: .default) { (_) in
            self.authenticatePKCE()
        }
        
        let actionPKCEDCR = UIAlertAction(title: "PKCE/DCR", style: .default) { (_) in
            self.authenticatePKCEDCR()
        }
        
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
            
        }

        alert.addAction(actionClientId)
        alert.addAction(actionPKCE)
        alert.addAction(actionPKCEDCR)
        alert.addAction(actionCancel)
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func authenticate() {
        let deligate = UIApplication.shared.delegate as! AppDelegate
        
        let config = OIDServiceConfiguration(authorizationEndpoint: authURL!, tokenEndpoint: tokenURL!)
        
        let authrequest = OIDAuthorizationRequest(configuration: config,
                                                  clientId: clientId,
                                                  clientSecret: clientSecret,
                                                  scopes: ["refresh_token"],
                                                  redirectURL: redirectURI!,
                                                  responseType: OIDResponseTypeCode,
                                                  additionalParameters: nil)
        
        deligate.currentAuthorizationFlow = OIDAuthState.authState(byPresenting: authrequest, presenting: self, callback: { (oidAuthState, error) in
            
            if let _ = error {
                print("Authentication Failed..")
            }
            
            if let authState = oidAuthState {
                print("Authentication Success - Auth State: \(authState)")
                self.loginToTheApp()
            }
            
        })
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
                self.loginToTheApp()
            }
            
        })
    }
    
    func authenticatePKCEDCR() {
        let config = OIDServiceConfiguration(authorizationEndpoint: authURL!, tokenEndpoint: tokenURL!, registrationEndpoint: registerURL!)
        
        let regRequest = OIDRegistrationRequest(configuration: config,
                                                redirectURIs: [redirectURI!],
                                                responseTypes: [OIDResponseTypeCode],
                                                grantTypes: ["authorization_code"],
                                                subjectType: nil,
                                                tokenEndpointAuthMethod: nil,
                                                additionalParameters: nil)

        OIDAuthorizationService.perform(regRequest) { (registrationResponse, error) in
            if let _ = error {
                print("Client Registration Failed..")
            }
            
            if let regResp = registrationResponse {
                print("Client Registration Success \(regResp)")
                self.loginToTheApp()
            }
        }
    }
    
    func loginToTheApp() {
        let homeViewController = self.storyboard?.instantiateViewController(withIdentifier: "HomeViewController")
        self.navigationController?.pushViewController(homeViewController!, animated: true)
    }
    
}

