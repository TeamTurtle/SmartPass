//
//  HostEventViewController.swift
//  SmartPass
//
//  Created by Cassidy Wang on 10/8/16.
//  Copyright © 2016 Cassidy Wang. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
import Alamofire

//TODO: Temporarily disable back button when picture is being analyzed

enum FaceAPIResult<AnyObject, Error: NSError> {
    case Success(AnyObject)
    case Failure(Error)
}

var personGroupID: String = ""
var currentName: String = ""
var currentpID: String = ""
var currentKey: String = ""

class HostEventViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, URLSessionDelegate, URLSessionTaskDelegate, URLSessionDataDelegate, AlertPresenter {
    
    //Outlets
    @IBOutlet weak var activityIndicatorView: UIVisualEffectView!
    @IBOutlet weak var beginHostingButton: UIButton!
    @IBOutlet weak var queryImage: DynamicImageView!
    @IBOutlet weak var welcomeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        queryImage.isUserInteractionEnabled = true
        NotificationCenter.default.addObserver(self, selector: #selector(HostEventViewController.checkImage), name: NSNotification.Name(rawValue: "imageViewDidChange"), object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func checkImage() {
        if !__CGSizeEqualToSize(queryImage.image!.size, CGSize(width: 0, height: 0)) {
            
            activityIndicatorView.isHidden = false
            
            uploadImage(faceImage: queryImage.image!, completion: { (result) in
                switch result {
                case .Success(_):
                    print("face uploaded - ")
                    break
                case .Failure(let error):
                    print("Error uploading a face - ", error)
                    break
                }
            })
        } else {
            self.presentAlert(title: "No Picture Detected", message: "Please select a valid picture", type: .notification, sender: self)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            
            //Make image square
            let squareLength = pickedImage.size.width > pickedImage.size.height ? pickedImage.size.height : pickedImage.size.width
            UIGraphicsBeginImageContextWithOptions(CGSize(width: squareLength, height: squareLength), false, 1)
            let context = UIGraphicsGetCurrentContext()
            context?.setFillColor(UIColor.black.cgColor)
            context?.fill(CGRect(x: 0, y: 0, width: squareLength, height: squareLength))
            pickedImage.draw(in: CGRect(x: (squareLength - pickedImage.size.width) / 2, y: (squareLength - pickedImage.size.height) / 2, width: pickedImage.size.width, height: pickedImage.size.height))
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            queryImage.image = newImage
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func startHosting() {
        beginHostingButton.isHidden = true
        queryImage.isHidden = false
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            let imagePicker = UIImagePickerController()
            
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    @IBAction func openCamera() {
        self.view.backgroundColor = UIColor.white
        welcomeLabel.isHidden = true
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            let imagePicker = UIImagePickerController()
            
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    @IBAction func viewTapped(_ sender: UITapGestureRecognizer) {
        if (self.view.backgroundColor == UIColor.green || self.view.backgroundColor == UIColor.red) {
            self.view.backgroundColor = UIColor.white
            openCamera()
        }
    }
    
    // Upload image
    func uploadImage(faceImage: UIImage, completion: (_ encodingResult: FaceAPIResult<AnyObject, NSError>) -> Void) {
        
        let url = "https://api.projectoxford.ai/face/v1.0/detect?returnFaceId=true&returnFaceLandmarks=false"
        let request = NSMutableURLRequest(url: NSURL(string: url)! as URL)
        
        request.httpMethod = "POST"
        request.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
        request.setValue("41b49cbdfd7548179bc07be1a26d5699", forHTTPHeaderField: "Ocp-Apim-Subscription-Key")
        
        let pngRepresentation = UIImagePNGRepresentation(faceImage)
        
        let task = URLSession.shared.uploadTask(with: request as URLRequest, from: pngRepresentation) { (data, response, error) in
            
            print("HTTP Request initiated")
            
            if let nsError = error {
                print("failure")
//                completion(.Failure(Error.UnexpectedError(nsError: nsError)))
            }
            else {
                let httpResponse = response as! HTTPURLResponse
                let statusCode = httpResponse.statusCode
                
                do {
                    let json = try JSONSerialization.jsonObject(with: data!, options:.allowFragments)
                    if statusCode == 200 {
                        DispatchQueue.main.async {
                            self.activityIndicatorView.isHidden = true
                        }
                        print("success")
                        print(json)
                        if (json as AnyObject).count == 0 {
                            DispatchQueue.main.async {
                                self.presentAlert(title: "No face found", message: "We couldn't identify a face. Please try again.", type: .notification, sender: self)
                            }
                        } else {
                            let swiftyJSONED = JSON(json)
                            let faceID = swiftyJSONED[0]["faceId"].stringValue
                            print(faceID)
                            self.identify(faces: [faceID], personGroupId: personGroupID, completion: { (result) in
                                switch result {
                                case .Success(let successJson):
                                    print("Identified face", successJson)
                                case .Failure(let error):
                                    print("Error identifying face", error)
                                }
                            })
                        }

//                        completion(.Success(json))
                    }
                }
                catch {
                    print("error")
//                    completion(.Failure(Error.JSonSerializationError))
                }
            }
        }
        task.resume()
    }
    
    func identify(faces faceIDs: [String], personGroupId: String, completion: (_ encodingResult: FaceAPIResult<JSON, NSError>) -> Void) {
        let url = "https://api.projectoxford.ai/face/v1.0/identify"
        let request = NSMutableURLRequest(url: NSURL(string: url)! as URL)
        
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("41b49cbdfd7548179bc07be1a26d5699", forHTTPHeaderField: "Ocp-Apim-Subscription-Key")
        
        let json: [String: Any] = ["personGroupId": personGroupId,
                                         "maxNumOfCandidatesReturned": 1,
                                         "confidenceThreshold": 0.7,
                                         "faceIds": faceIDs
        ]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
            
            if let nsError = error {
                print("failure")
                print(nsError)
//                completion(result: .Failure(Error.UnexpectedError(nsError: nsError)))
            }
            else {
                let httpResponse = response as! HTTPURLResponse
                let statusCode = httpResponse.statusCode
                
                do {
                    let json = try JSONSerialization.jsonObject(with: data!, options:.allowFragments)
                    print("identify json: \(json)")
                    if statusCode == 200 {
                        DispatchQueue.main.async {
                            print("identification success")
                            print("Confidence: \(JSON(json)[0]["candidates"][0]["confidence"].floatValue)")
                            let pID: String = JSON(json)[0]["candidates"][0]["personId"].stringValue
                            print("personId: \(pID)")
                            currentpID = pID
                            self.retrievePersonData()
                            let confidenceLevel = JSON(json)[0]["candidates"][0]["confidence"].floatValue
                            if confidenceLevel >= 0.80 {
                                self.view.backgroundColor = UIColor.green
                            } else if confidenceLevel >= 0.50 {
                                self.view.backgroundColor = UIColor.orange
                                DispatchQueue.main.async {
                                    self.performSegue(withIdentifier: "toVoiceVerification", sender: self)
                                }
                            } else {
                                self.view.backgroundColor = UIColor.red
                            }
                            //                        completion(result: .Success(json))
                        }
                    }
                    else {
                        DispatchQueue.main.async {
                        self.view.backgroundColor = UIColor.red
                            print(statusCode)
                        print("JSON error")
//                        completion(result: .Failure(Error.ServiceError(json: json as! JSONDictionary)))
                        }
                    }
                }
                catch {
                    DispatchQueue.main.async {
                    print("JSON serialization error")
                    self.view.backgroundColor = UIColor.red
//                    completion(result: .Failure(Error.JSonSerializationError))
                    }
                }
            }
        }
        task.resume()
    }
    
    func retrievePersonData() {
        let url = "http://smartpass-145909.appspot.com/getuser?personId=\(currentpID)&personGroupId=\(personGroupID)"
        let request = NSMutableURLRequest(url: NSURL(string: url)! as URL)
        
        request.httpMethod = "GET"
        request.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
        
//        let json: [String: Any] = ["personId": currentpID]
//        
//        let jsonData = try! JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
//        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
            
            if let nsError = error {
                print("failure")
                print(nsError)
            }
            else {
                let httpResponse = response as! HTTPURLResponse
                let statusCode = httpResponse.statusCode
                
                do {
                    let json = try JSONSerialization.jsonObject(with: data!, options:.allowFragments)
                    print("retrievePersonData json: \(json)")
                    if statusCode == 200 {
                        DispatchQueue.main.async {
                            let pName = JSON(json)["name"].stringValue
                            let pWord = JSON(json)["word"].stringValue
                            currentName = pName
                            self.welcomeLabel.text = "Welcome, \(currentName)!"
                            self.welcomeLabel.isHidden = false
                            currentKey = pWord
                        }
                    }
                    else {
                        print("retrieval error")
                    }
                }
                catch {
                    DispatchQueue.main.async {
                        print("JSON serialization error")
                    }
                }
            }
        }
        task.resume()
    }
    
    @IBAction func unwindToHostEvent(sender: UIStoryboardSegue) {
    }
}
