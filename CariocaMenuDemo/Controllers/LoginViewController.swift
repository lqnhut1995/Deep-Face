//
//  LoginViewController.swift
//  CariocaMenuDemo
//
//  Created by Hell Rocky on 8/7/19.
//  Copyright © 2019 CariocaMenu. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var login: UIButton!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var username: UITextField!
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        login.rounded()
        password.rounded()
        username.rounded()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func login(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainVC = storyboard.instantiateViewController(withIdentifier: "mainvc") as! MainViewController
        UIView.transition(from: AppDelegate.sharedInstance().window!.rootViewController!.view, to: mainVC.view, duration: 1.0, options: [.transitionFlipFromRight], completion: {
            _ in
            AppDelegate.sharedInstance().window?.rootViewController = mainVC
        })
    }
}
