//
//  ImageUploader.swift
//  SmartPass
//
//  Created by Cassidy Wang on 10/8/16.
//  Copyright © 2016 Cassidy Wang. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

protocol ImageUploader: URLSessionDelegate, URLSessionTaskDelegate, URLSessionDataDelegate {
    func uploadImage(image: UIImage, progress: (_ percent: Float) -> Void, completion: (_ tags: [String], _ colors: [PhotoColor]) -> Void)
}

//TODO: update upload progress bar
extension ImageUploader {
    func uploadImage(image: UIImage, progress: (_ percent: Float) -> Void, completion: (_ tags: [String], _ colors: [PhotoColor]) -> Void) {
        
        let request = NSMutableURLRequest(url: URL(string: "https://api.projectoxford.ai/face/v1.0/detect?returnFaceId=true&returnFaceLandmarks=false")!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("41b49cbdfd7548179bc07be1a26d5699", forHTTPHeaderField: "Ocp-Apim-Subscription-Key")
        
        guard let imageData = UIImageJPEGRepresentation(image, 1.0) else {
            print("Could not get JPG representation of image")
            return
        }
        
        let base64String = imageData.base64EncodedString(options: .init(rawValue: 0))
        let parameters: Parameters = [
            "url": "\(base64String)"
        ]
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .init(rawValue: 0))
        } catch {
            print("errorLine36ImageUploader")
        }
        
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
//            var strData = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
//            var err: NSError?
            print(response)
        })
        
        task.resume()
    }
}

//        Alamofire.request("https://api.projectoxford.ai/face/v1.0/detect?returnFaceId=true&returnFaceLandmarks=false", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: ["Content-Type": "application/json", "Ocp-Apim-Subscription-Key": "41b49cbdfd7548179bc07be1a26d5699"]).responseJSON(completionHandler: { response in
//            print(response)
//        })
        
//        Alamofire.upload(imageData, to: "https://api.projectoxford.ai/face/v1.0/detect?returnFaceId=true&returnFaceLandmarks=false", method: .post, headers: ["Content-Type": "application/json", "Ocp-Apim-Subscription-Key": "41b49cbdfd7548179bc07be1a26d5699"]).responseJSON(completionHandler: { response in
//            print(response)
//        })
//        .uploadProgress { progress in
//            let percent = progress.fractionCompleted
//        }
        
//    }

//        let url = URL(string: "https://api.projectoxford.ai/face/v1.0/detect?returnFaceId=true&returnFaceLandmarks=false")
//        
//        let request = NSMutableURLRequest(url: url!)
//        request.httpMethod = "POST"
//        
//        let boundary = generateBoundaryString()
//        
//        //define the multipart request type
//        
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.setValue("41b49cbdfd7548179bc07be1a26d5699", forHTTPHeaderField: "Ocp-Apim-Subscription-Key")
//        
//        let image_data = UIImagePNGRepresentation(image)
//        
//        
//        if(image_data == nil)
//        {
//            return
//        }
//        
//        
//        let body = NSMutableData()
//        
//        let fname = "test.png"
//        let mimetype = "image/png"
//        
//        //define the data post parameter
//        
//        body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
//        body.append("Content-Disposition:form-data; name=\"test\"\r\n\r\n".data(using: String.Encoding.utf8)!)
//        body.append("hi\r\n".data(using: String.Encoding.utf8)!)
//        
//        
//        
//        body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
//        body.append("Content-Disposition:form-data; name=\"file\"; filename=\"\(fname)\"\r\n".data(using: String.Encoding.utf8)!)
//        body.append("Content-Type: \(mimetype)\r\n\r\n".data(using: String.Encoding.utf8)!)
//        body.append(image_data!)
//        body.append("\r\n".data(using: String.Encoding.utf8)!)
//        
//        
//        body.append("--\(boundary)--\r\n".data(using: String.Encoding.utf8)!)
//        
//        request.httpBody = body as Data
//        
//        let session = URLSession.shared
//        
//        let task = session.dataTask(with: request as URLRequest) {
//            (data, response, error) in
//            
//            guard let _:NSData = data as NSData?, let _:URLResponse = response  , error == nil else {
//                print("askdfjask")
//                print("error")
//                return
//            }
//            
//            let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
//            print(dataString)
//            
//        }
//        
//        task.resume()
//    }
//    
//    func generateBoundaryString() -> String
//    {
//        return "Boundary-\(NSUUID().uuidString)"
//    }
//}
