//
//  ImageDownloader.swift
//  Assignment
//
//  Created by admin on 14/04/19.
//  Copyright © 2019 admin. All rights reserved.
//

import UIKit
class ImageDownloader: Operation {
    let photoRecord: FlickrPhoto
    init(_ photoRecord: FlickrPhoto) {
        self.photoRecord = photoRecord
    }
    
    override func main() {
        if isCancelled {
            return
        }
        guard let url = URL(string: photoRecord.photoUrl) else { return }
        guard let imageData = try? Data(contentsOf: url) else { return }
        
        if isCancelled {
            return
        }
        
        if !imageData.isEmpty {
            photoRecord.image = UIImage(data:imageData)!
            photoRecord.state = .downloaded
        } else {
            photoRecord.state = .failed
        }
    }
}

