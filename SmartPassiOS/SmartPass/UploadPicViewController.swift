//
//  UploadPicViewController.swift
//  SmartPass
//
//  Created by Cassidy Wang on 10/8/16.
//  Copyright © 2016 Cassidy Wang. All rights reserved.
//

import UIKit
import Alamofire

//TODO: Double tapping next button triggers segue twice

class UploadPicViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, AlertPresenter {
    
    //Outlets
    @IBOutlet weak var imageToUse: UIImageView!
    @IBOutlet weak var nextStageButton: UIBarButtonItem!
    @IBOutlet weak var activityIndicatorView: UIVisualEffectView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageToUse.isUserInteractionEnabled = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func imageTapped() {
        print("image tapped")
        let alert = UIAlertController(title: "Upload a photo", message: "Please upload a clear picture of your face", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Open camera", style: .default, handler: { (alert: UIAlertAction!) -> Void in
            self.takePicture()
        }))
        alert.addAction(UIAlertAction(title: "Open photo library", style: .default, handler: { (alert: UIAlertAction!) -> Void in
            self.openPhotoLibrary()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            self.imageToUse.contentMode = .scaleToFill
            
            //Make image square
            let squareLength = pickedImage.size.width > pickedImage.size.height ? pickedImage.size.height : pickedImage.size.width
            UIGraphicsBeginImageContextWithOptions(CGSize(width: squareLength, height: squareLength), false, 1)
            let context = UIGraphicsGetCurrentContext()
            context?.setFillColor(UIColor.black.cgColor)
            context?.fill(CGRect(x: 0, y: 0, width: squareLength, height: squareLength))
            pickedImage.draw(in: CGRect(x: (squareLength - pickedImage.size.width) / 2, y: (squareLength - pickedImage.size.height) / 2, width: pickedImage.size.width, height: pickedImage.size.height))
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            imageToUse.image = newImage
            nextStageButton.isEnabled = true
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func takePicture() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            let imagePicker = UIImagePickerController()
            
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    @IBAction func openPhotoLibrary() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
            let imagePicker = UIImagePickerController()
            
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    @IBAction func attemptNextStep(_ sender: UIBarButtonItem) {
        //TODO: Verify valid facial features before passing to next view controller
        activityIndicatorView.isHidden = false
        if !__CGSizeEqualToSize(imageToUse.image!.size, CGSize(width: 0, height: 0)) {
            
            uploadImage(faceImage: imageToUse.image!, completion: { (result) in
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
    
    // Upload image
    func uploadImage(faceImage: UIImage, completion: (_ encodingResult: FaceAPIResult<AnyObject, NSError>) -> Void) {
        
        let url = "https://api.projectoxford.ai/face/v1.0/detect?returnFaceId=true&returnFaceLandmarks=false"
        let request = NSMutableURLRequest(url: NSURL(string: url)! as URL)
        
        request.httpMethod = "POST"
        request.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
        request.setValue("41b49cbdfd7548179bc07be1a26d5699", forHTTPHeaderField: "Ocp-Apim-Subscription-Key")
        
        let pngRepresentation = UIImagePNGRepresentation(faceImage)
        
        let task = URLSession.shared.uploadTask(with: request as URLRequest, from: pngRepresentation) { (data, response, error) in
            
            if let nsError = error {
                print("failure")
                print(nsError)
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
                                self.presentAlert(title: "Uh oh", message: "No face found. Please try again.", type: .notification, sender: self)
                            }
                        } else {
                            DispatchQueue.main.async {
                                self.performSegue(withIdentifier: "toVoiceKey", sender: self)
                            }
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

    @IBAction func unwindToRegistration(sender: UIStoryboardSegue) {
    }
}
