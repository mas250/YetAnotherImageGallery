//
//  FlickPhotosViewController.swift
//  YetAnotherImageGallery
//
//  Created by Matthew Shaw on 18/06/2017.
//  Copyright © 2017 Matthew Shaw. All rights reserved.
//

import UIKit

final class FlickrPhotosViewController : UICollectionViewController {
    

fileprivate let reuseIdentifier = "FlickrCell"  //UICollectionView requires for cell reuse
fileprivate let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)
fileprivate var searches = [FlickrSearchResults]()
fileprivate let flickr = Flickr()
fileprivate let itemsPerRow: CGFloat = 3

    
}

private extension FlickrPhotosViewController{
    func photoForIndexPath(indexPath: IndexPath) -> FlickrPhoto { //
        return searches [(indexPath as NSIndexPath).section].searchResults[(indexPath as IndexPath).row]
    }
}

extension FlickrPhotosViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // log status to console. Should also alert user.
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        textField.addSubview(activityIndicator)
        activityIndicator.frame = textField.bounds
        activityIndicator.startAnimating()
        
        flickr.searchFlickrForTerm(textField.text!) {
            results, error in
            
            activityIndicator.removeFromSuperview()
            
            if let error = error{
                //
                print("An error occured while searching: \(error)") //to be shown to user
                return
            }
            
            if let results = results {
                //add to search array and update UI. Results can be reordered here.
                print("Found \(results.searchResults.count) matching \(results.searchTerm)")
                self.searches.insert(results, at: 0)
                
                
                self.collectionView?.reloadData()
            }
        }
        textField.text = nil
        textField.resignFirstResponder()
        return true
    }
}

extension FlickrPhotosViewController {
    //Returns one header per set of search results. Design could be changed to allow one header per result.
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return searches.count
        }
    
    
    override func collectionView( _ collectionView: UICollectionView, numberOfItemsInSection section : Int) -> Int {
    return searches[section].searchResults.count
    }
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind : String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        //Populate header with search term.
        switch kind {
        case UICollectionElementKindSectionHeader:
            
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "FlickrPhotoHeaderView", for: indexPath) as! FlickrPhotoHeaderView
            headerView.label.text = searches[(indexPath as NSIndexPath).section].searchTerm
            return headerView
        default:
            assert(false, "Unexpected element kind found")
        }
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        //Populate cell with value for photo.
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! FlickrPhotoCell
        
        let flickrPhoto = photoForIndexPath(indexPath: indexPath)
        cell.backgroundColor = UIColor.white
        
        cell.imageView.image = flickrPhoto.thumbnail
        //cell.label.text = flickrPhoto.Photo // Extract metadata to display alongside photo.
        
        return cell
    }
    
    
    
}

extension FlickrPhotosViewController : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        //Format search results to display on screen.
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        
        
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    //
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return sectionInsets
    }
    
    //
    
    func collectionView(_ collectionView : UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
}
