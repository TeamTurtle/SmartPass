//
//  DynamicImageView.swift
//  SmartPass
//
//  Created by Cassidy Wang on 10/8/16.
//  Copyright © 2016 Cassidy Wang. All rights reserved.
//

import UIKit

class DynamicImageView: UIImageView {

    override var image: UIImage? {
        didSet {
            super.image = image
            NotificationCenter.default.post(Notification.init(name: Notification.Name(rawValue: "imageViewDidChange")))
        }
    }

}
