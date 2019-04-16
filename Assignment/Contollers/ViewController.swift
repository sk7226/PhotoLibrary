//
//  ViewController.swift
//  Assignment
//
//  Created by admin on 14/04/19.
//  Copyright © 2019 admin. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    //MARK: - IBOutlets
    @IBOutlet weak var photosCollectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    //MARK: - Properties
    let cellIdentifier = "Cell"
    var photos: [FlickrPhoto] = [FlickrPhoto]()
    var centerPoint: CGPoint!
    let transition = CircularTransition()
    var selectedIndex: IndexPath!
    var isFetching: Bool = false
    var pageNumber: Int = 1
    var serchText: String = ""
    var pendingOperations = DownloadOperations()
    var numberOfCellsPerRow: Int = 2 {
        didSet {
            self.photosCollectionView.collectionViewLayout.invalidateLayout()
        }
    }
    let placeholderImage = UIImage(named: "placeholder")
    
    var clickedCell: PhotoCell!
    var transitionImage: UIImage!

    
    
    //MARK: - Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        photosCollectionView.register(PhotoCell.self, forCellWithReuseIdentifier: cellIdentifier)
    }
    
    
    //MARK: - Action
    @IBAction func manuSelectionAction(_ sender: Any) {
        let alertController = UIAlertController(title: "Options", message: "Select options", preferredStyle: UIAlertController.Style.actionSheet)
        
        ["1","2","3","4"].forEach({
            let action = UIAlertAction(title: $0, style: .default) { [weak self](action) in
                self?.numberOfCellsPerRow = Int(action.title ?? "1")!
            }
            alertController.addAction(action)
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
        }
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    //MARK:- Helpers
  fileprivate func startDownload(for photoRecord: FlickrPhoto, at indexPath: IndexPath) {
        guard pendingOperations.downloadsInProgress[indexPath] == nil else {
            return
        }
        
        let downloader = ImageDownloader(photoRecord)
        downloader.completionBlock = {
            if downloader.isCancelled {
                return
            }
            
            DispatchQueue.main.async {
                self.pendingOperations.downloadsInProgress.removeValue(forKey: indexPath)
                self.photosCollectionView.reloadItems(at: [indexPath])
            }
        }
        pendingOperations.downloadsInProgress[indexPath] = downloader
        pendingOperations.downloadQueue.addOperation(downloader)
    }
    
    fileprivate func loadPhotosToCollectionView(searchText: String){
        if searchText.count == 0 { return }
        isFetching = true
        Connection.sharedInstance.invokePWService(method: .GET, searchtext: searchText, tagPagenumber: (searchText,pageNumber)) { [weak self] (err, photos) in
            
            if let err = err {
                print(err)
                return
            }
            DispatchQueue.main.async {
                self?.isFetching = false
                self?.photos = photos!
                self?.pendingOperations = DownloadOperations()
                self?.photosCollectionView.reloadData()
            }
        }
    }
    ///Unwind segue
    @IBAction func unwindToVC1(segue:UIStoryboardSegue) {
        
    }
    
    ///Increasing the priorities of download which are visible and decreasing that of not visible
    fileprivate func resetPriority(indexPaths: [IndexPath]){
        for task in pendingOperations.downloadsInProgress.keys {
            let operation = pendingOperations.downloadsInProgress[task]
            if(indexPaths.contains(task)){
                operation?.queuePriority = .high
            }else{
                operation?.queuePriority = .low
            }
        }
    }
    
    fileprivate func cellSize(count: Int) -> CGSize{
        let paddingOffset: CGFloat = (count == 1 || count == 2) ? 10.0 : (count == 3 ? 20.0 : 30.0)
        let width: CGFloat = self.view.frame.width - paddingOffset
        return CGSize(width: width/CGFloat(count), height: width/CGFloat(count))
    }
}


extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    //MARK: - Collectionview datasource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! PhotoCell
        let photo = photos[indexPath.row]
        switch (photo.state) {
        case .new:
            cell.photoImageView.image = placeholderImage
            startDownload(for: photo, at: indexPath)
            break
        case .downloaded:
            cell.photoImageView.image = photo.image
            break
        case .failed:
            cell.photoImageView.image = placeholderImage
            
        }
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return cellSize(count: numberOfCellsPerRow)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let footer = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "Footer", for: indexPath)
        return footer
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if(photos.count == 0) {
            return .zero
        }else {
            return CGSize(width: collectionView.frame.size.width, height: 60)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let visibleIndexPath = photosCollectionView.indexPathsForVisibleItems.sorted()
        resetPriority(indexPaths: visibleIndexPath)
        if((visibleIndexPath.last?.item)! >= photos.count-1 && !isFetching) {
            pageNumber += 1
            self.isFetching = true
            Connection.sharedInstance.invokePWService(method: .GET, searchtext: serchText, tagPagenumber: (serchText,pageNumber)) { [weak self] (err, addtionalPhotos) in
                if let err = err {
                    print(err)
                    return
                }
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    var indexPaths = [IndexPath]()
                    for index in self.photos.count...addtionalPhotos!.count+self.photos.count - 1 {
                        indexPaths.append(IndexPath(item: index, section: 0))
                    }
                    self.photos.append(contentsOf: addtionalPhotos!)
                    self.photosCollectionView.insertItems(at: indexPaths)
                    self.isFetching = false
                }
            }
        }
    }
    
    //MARK: - Collectionview delegates
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = photosCollectionView.cellForItem(at: indexPath) as! PhotoCell
        clickedCell = cell
        transition.img = cell.photoImageView.image!
        transitionImage = cell.photoImageView.image
        let rect = photosCollectionView.convert(cell.frame, to: self.view)
        let pt = CGPoint(x: rect.origin.x + rect.size.width / 2, y:  rect.origin.y + rect.size.height / 2)
        centerPoint = pt
        selectedIndex = indexPath
        performSegue(withIdentifier: "detail", sender: cell)
    }
}

extension ViewController: UISearchBarDelegate {
    //MARK: - Searchbar delegates
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        serchText = searchBar.text ?? ""
        loadPhotosToCollectionView(searchText: searchBar.text ?? "")
        searchBar.endEditing(true)
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print(searchText)
    }
}

extension ViewController: UIViewControllerTransitioningDelegate {
    //MARK: - Navigation methods
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let secondVC = segue.destination as! DetailViewController
        secondVC.transitioningDelegate = self
        secondVC.modalPresentationStyle = .custom
        secondVC.passedImage = photos[selectedIndex.row].image
        secondVC.imageId = photos[selectedIndex.row].photoId
    }
    
    //MARK: - For custom transition
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .present
        transition.startingPoint = centerPoint
        return transition
    }
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .dismiss
        transition.startingPoint = centerPoint
        return transition
    }
}


