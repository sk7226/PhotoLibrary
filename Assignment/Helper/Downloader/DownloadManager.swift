//
//  DownloadManager.swift
//  Assignment
//
//  Created by admin on 14/04/19.
//  Copyright © 2019 admin. All rights reserved.
//

import Foundation
import UIKit

enum PhotoDownloadState {
    case new, downloaded, failed
}

class PhotoRecord {
    let name: String
    let url: URL
    var state = PhotoDownloadState.new
    var image = UIImage(named: "placeholder")
    
    init(name:String, url:URL) {
        self.name = name
        self.url = url
    }
}

class DownloadOperations {
    lazy var downloadsInProgress: [IndexPath: Operation] = [:]
    lazy var downloadQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "com.download.queue"
        return queue
    }()
    
}

