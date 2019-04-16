//
//  ImageViewWithCache.swift
//  Assignment
//
//  Created by admin on 16/04/19.
//  Copyright © 2019 admin. All rights reserved.
//

import UIKit

let imageCache = NSCache<NSString, AnyObject>()

class ImageViewWithCache: UIImageView {
    
    var imageURLString: String?
    var imageId: String = ""
    
    func loadImage(with urlString: String, placeHolderImage:UIImage, imageStoreId: String) {
        
        self.image = placeHolderImage
        
        imageURLString = urlString
        
        if(!((imageURLString?.count)!>0)) {
            return
        }
        
        let catPictureURL = URL(string: urlString)
        if let cachedImage = imageCache.object(forKey: imageStoreId as NSString) as? Data {
            
            let image = UIImage(data: cachedImage)
            self.image = image
            
        } else {
            
            self.image = placeHolderImage
            let session = URLSession(configuration: .default)
            let downloadPicTask = session.dataTask(with: catPictureURL!) { (data, response, error) in
                
                if let e = error {
                    print("Error downloading cat picture: \(e.localizedDescription)")
                } else {
                    if let res = response as? HTTPURLResponse {
                        print("Downloaded cat picture with response code \(res.statusCode)")
                        
                        DispatchQueue.main.async {
                            if let imageData = data {
                                if urlString == self.imageURLString {
                                    self.image = UIImage(data: imageData)
                                }
                                imageCache.setObject(imageData as AnyObject, forKey: imageStoreId as NSString)
                            } else {
                                print("Couldn't get image: Image is nil")
                                self.image = placeHolderImage//UIImage(named: placeHolderImage)
                            }
                        }
                    } else {
                        print("Couldn't get response code for some reason")
                    }
                }
            }
            downloadPicTask.resume()
        }
        
    }
}
