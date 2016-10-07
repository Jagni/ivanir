//
//  CustomPhotoAlbum.swift
//  Ivanir
//
//  Created by Jagni Dasa Horta Bezerra on 9/6/16.
//  Copyright © 2016 Jagni. All rights reserved.
//

import Foundation

import Photos

class CustomPhotoAlbum {
    
    static let albumName = "Ivanir's Month"
    static let sharedInstance = CustomPhotoAlbum()
    
    var assetCollection: PHAssetCollection!
    
    init() {
        
        func fetchAssetCollectionForAlbum() -> PHAssetCollection! {
            
            let fetchOptions = PHFetchOptions()
            fetchOptions.predicate = NSPredicate(format: "title = %@", CustomPhotoAlbum.albumName)
            let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
            
            if let _: AnyObject = collection.firstObject {
                return collection.firstObject
            }
            
            return nil
        }
        
        if let assetCollection = fetchAssetCollectionForAlbum() {
            self.assetCollection = assetCollection
            return
        }
        
        PHPhotoLibrary.shared().performChanges({
            PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: CustomPhotoAlbum.albumName)
        }) { success, _ in
            if success {
                self.assetCollection = fetchAssetCollectionForAlbum()
            }
        }
    }
    
    func saveImage(_ image: UIImage) {
        
//        if assetCollection == nil {
//            return   // If there was an error upstream, skip the save.
//        }
//        
//        PHPhotoLibrary.shared().performChanges({
//            let assetChangeRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
//            let assetPlaceholder = assetChangeRequest.placeholderForCreatedAsset
//            //let fastEnumeration = NSArray(array: [assetPlaceholder!] as [PHObjectPlaceholder])
//            let albumChangeRequest = PHAssetCollectionChangeRequest(for: self.assetCollection)
//            albumChangeRequest!.addAssets([assetPlaceholder!])
//            }, completionHandler: nil)
    }
    
    
}
