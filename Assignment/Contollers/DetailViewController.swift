//
//  DetailViewController.swift
//  Assignment
//
//  Created by admin on 16/04/19.
//  Copyright © 2019 admin. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    //MARK: - Outlets
    @IBOutlet weak var detailImageView: ImageViewWithCache!
    @IBOutlet weak var navBar: UINavigationBar!
    
    //MARK: - Properties
    var passedImage: UIImage = UIImage()
    var imageId: String = ""
    
    //MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        detailImageView.image = passedImage
        detailImageView.clipsToBounds = true
        
        if let cachedImage = imageCache.object(forKey: (imageId + "highres") as NSString) as? Data {

            let image = UIImage(data: cachedImage)
            detailImageView.image = image

        } else {
            Connection.sharedInstance.invokeHighResService(method: .GET, id: imageId) { (err, highresData) in
                DispatchQueue.main.async {
                    
                    if let error = err {
                        let alertController = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
                        
                        let okaction = UIAlertAction(title: "OK", style: .cancel) { action -> Void in
                            DispatchQueue.main.async {
                                self.performSegue(withIdentifier: "exit", sender: self)
                            }
                        }
                        alertController.addAction(okaction)
                        
                        self.present(alertController, animated: true, completion: nil)
                        return
                    }
                    
                    self.detailImageView.loadImage(with: (highresData?.source)!, placeHolderImage: self.passedImage,imageStoreId: self.imageId + "highres")
                    
                }
            }
        }

    }
    
    //MARK: - Action
    @IBAction func backAction(_ sender: Any) {
        navBar.isHidden = true
        performSegue(withIdentifier: "exit", sender: self)
    }
    
    
}


