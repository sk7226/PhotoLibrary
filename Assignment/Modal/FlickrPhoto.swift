//
//  FlickrPhoto.swift
//  Assignment
//
//  Created by admin on 14/04/19.
//  Copyright © 2019 admin. All rights reserved.
//

import UIKit

class FlickrPhoto {
    
    let photoId: String
    let farm: Int
    let secret: String
    let server: String
    let title: String
    var isDownloaded = false
    var image: UIImage = UIImage(named: "placeholder")!
    var state = PhotoDownloadState.new
    
    var photoUrl: String {
        return  "https://farm\(farm).staticflickr.com/\(server)/\(photoId)_\(secret)_m.jpg"
    }
    
    init(photoId: String, farm: Int, secret: String, server: String, title: String){
        self.photoId = photoId
        self.farm = farm
        self.secret = secret
        self.server = server
        self.title = title
    }
    
}

struct Highres {
    let height: Int
    let source: String
    let url: String
}
