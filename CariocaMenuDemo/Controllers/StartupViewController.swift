//
//  StartupViewController.swift
//  CariocaMenuDemo
//
//  Created by Hell Rocky on 8/1/19.
//  Copyright © 2019 CariocaMenu. All rights reserved.
//

import UIKit
import RevealingSplashView

class StartupViewController: UIViewController {

    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let revealingSplashView = RevealingSplashView(iconImage: UIImage(named: "carioca_logo")!,iconInitialSize: CGSize(width: 70, height: 70), backgroundColor: UIColor(hex: "#434343"))
        
        //Adds the revealing splash view as a sub view
        view.addSubview(revealingSplashView)
        revealingSplashView.delay = 2
        revealingSplashView.duration = 2
        
        revealingSplashView.animationType = SplashAnimationType.popAndZoomOut
        
        //Starts animation
        revealingSplashView.startAnimation {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let mainVC = storyboard.instantiateViewController(withIdentifier: "loginvc") as! LoginViewController
            AppDelegate.sharedInstance().window?.rootViewController = mainVC
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
