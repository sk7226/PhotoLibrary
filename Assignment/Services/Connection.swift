//
//  Connection.swift
//  Assignment
//
//  Created by admin on 14/04/19.
//  Copyright © 2019 admin. All rights reserved.
//

import Foundation

enum HTTPMethod: String {
    case GET, POST
}



class Connection : NSObject {
    typealias Completion = (String?, [FlickrPhoto]?) -> Void
    
    static let sharedInstance = Connection()
    
    func invokePWService(method: HTTPMethod, searchtext: String,tagPagenumber: (String,Int), onCompletion:Completion?) {
        
        
        let BASE_URL: String = "https://api.flickr.com/services/rest/?method=flickr.photos.search&tags=\(tagPagenumber.0)&api_key=\(flickerAPIKey)&per_page=26&page=\(tagPagenumber.1)&format=json&nojsoncallback=1"
        
        if let url = URL(string: BASE_URL) {
            let request = NSMutableURLRequest(url: url, cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringCacheData, timeoutInterval:60)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpMethod = method.rawValue
            let sessionConfig = URLSessionConfiguration.default
            let sesson = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
            
            
            let task = sesson.dataTask(with: request as URLRequest) { data, response, error in
                if let _ = error {
                    print("error:: \(error!.localizedDescription)")
                    if let _ = onCompletion {
                        
                        onCompletion!("Error While Downloading image",nil)
                        
                        
                    }
                } else {
                    
                    do {                        
                        let resultsDictionary = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: AnyObject]
                        guard let photosContainer = resultsDictionary!["photos"] as? NSDictionary else { return }
                        guard let photosArray = photosContainer["photo"] as? [NSDictionary] else { return }
                        
                        let flickrPhotos: [FlickrPhoto] = photosArray.map { photoDictionary in
                            
                            let photoId = photoDictionary["id"] as? String ?? ""
                            let farm = photoDictionary["farm"] as? Int ?? 0
                            let secret = photoDictionary["secret"] as? String ?? ""
                            let server = photoDictionary["server"] as? String ?? ""
                            let title = photoDictionary["title"] as? String ?? ""
                            
                            let flickrPhoto = FlickrPhoto(photoId: photoId, farm: farm, secret: secret, server: server, title: title)
                            return flickrPhoto
                        }
                        
                        onCompletion!(nil, flickrPhotos)
                        
                        
                    }catch {
                        onCompletion!("Error While Downloading image",nil)
                        
                    }
                }
            }
            
            task.resume()
        }
    }
    
    
    
    func invokeHighResService(method: HTTPMethod, id: String, onCompletion:((String?, Highres?) -> Void)?) {
        
        
        let BASE_URL: String = "https://api.flickr.com/services/rest/?method=flickr.photos.getSizes&api_key=\(flickerAPIKey)&&photo_id=\(id)&format=json&nojsoncallback=1"
        
        if let url = URL(string: BASE_URL) {
            let request = NSMutableURLRequest(url: url, cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringCacheData, timeoutInterval:60)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpMethod = method.rawValue
            let sessionConfig = URLSessionConfiguration.default
            let sesson = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
            
            
            let task = sesson.dataTask(with: request as URLRequest) { data, response, error in
                if let _ = error {
                    print("error:: \(error!.localizedDescription)")
                    if let _ = onCompletion {
                        
                        onCompletion!("Error While Downloading image",nil)
                        
                    }
                } else {
                    
                    do {
                        let resultsDictionary = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: AnyObject]
                        if let photosArray = (resultsDictionary!["sizes"] as? NSDictionary)?.value(forKey: "size") as? [NSDictionary] {
                            
                            var highresPhotos: [Highres] = photosArray.map { item in
                                
                                let height = Int(item["height"] as? String ?? "0")!
                                let source = item["source"] as? String ?? ""
                                let url = item["url"] as? String ?? ""
                                
                                let flickrPhoto = Highres(height: height, source: source, url: url)
                                return flickrPhoto
                            }
                            print(photosArray)
                            highresPhotos = highresPhotos.sorted(by: {return $0.height < $1.height })
                            onCompletion!(nil, highresPhotos.last!)
                            
                        }else {
                            onCompletion!("Error While Downloading image",nil)
                            return
                        }
                        
                    }catch {
                        onCompletion!("Error While Downloading image",nil)
                        
                    }
                }
            }
            
            task.resume()
        }
    }
    
    
    
    
}


