//
//  RegistrationSuccessViewController.swift
//  SmartPass
//
//  Created by Cassidy Wang on 10/9/16.
//  Copyright © 2016 Cassidy Wang. All rights reserved.
//

import UIKit

class RegistrationSuccessViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func returnToRegistration() {
        self.performSegue(withIdentifier: "unwindToRegistration", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is UploadPicViewController {
            let destinationVC = segue.destination as! UploadPicViewController
            destinationVC.imageToUse.contentMode = .center
            destinationVC.imageToUse.image = #imageLiteral(resourceName: "Camera-76")
        }
    }
}
