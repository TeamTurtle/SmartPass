//
//  CreateEventViewController.swift
//  SmartPass
//
//  Created by Cassidy Wang on 10/8/16.
//  Copyright © 2016 Cassidy Wang. All rights reserved.
//

import UIKit

class CreateEventViewController: UIViewController, UITextFieldDelegate {

    //Outlets
    @IBOutlet weak var eventNameTextField: UITextField!
    @IBOutlet weak var createButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        eventNameTextField.delegate = self
        eventNameTextField.addTarget(self, action: #selector(CreateEventViewController.textFieldDidChange), for: UIControlEvents.editingChanged)
        self.hideKeyboardOnTap()
    }
    
    func textFieldDidChange(textField: UITextField) {
        if (eventNameTextField.text != nil) {
            createButton.isEnabled = true
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        personGroupID = eventNameTextField.text!
        self.performSegue(withIdentifier: "toEventHosting", sender: self)
        return true
    }
    
    @IBAction func createEvent(_ sender: UIBarButtonItem) {
        personGroupID = eventNameTextField.text!
        performSegue(withIdentifier: "toEventHosting", sender: self)
    }

    @IBAction func unwindToCreateEvent(sender: UIStoryboardSegue) {
    }
    
}
