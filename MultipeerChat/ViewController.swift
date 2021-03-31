//
//  ViewController.swift
//  MultipeerChat
//
//  Created by Tihomir RAdeff on 13.01.21.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var nameText: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func continueButtonAction(_ sender: Any) {
        let name = nameText.text
        if name != "" {
            //save the nickname
            UserDefaults.standard.set(name, forKey: "nickname")
            
            //open the second screen
            performSegue(withIdentifier: "OpenChat", sender: nil)
        }
    }
}

