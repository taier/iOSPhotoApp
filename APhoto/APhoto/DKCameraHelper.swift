//
//  DKCameraHelper.swift
//  APhoto
//
//  Created by Deniss Kaibagarovs on 10/03/16.
//  Copyright © 2016 Sudo Mobi. All rights reserved.
//

import UIKit

class DKCameraHelper: NSObject {

    // MARK: Init Singleton
    class var sharedInstance: DKCameraHelper {
        struct Static {
            static let instance = DKCameraHelper()
        }
        return Static.instance
    }
    
    //MARK: Image Helpers
    class func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
        // Get scale factor for resize
        let scale = newWidth / image.size.width
        
        // Calculate new height
        let newHeight = image.size.height * scale
        
        // Create canvas for a new image
        UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight))
        
        // Draw new image in new bounds on canvas
        image.drawInRect(CGRectMake(0, 0, newWidth, newHeight))
        
        // Export new image from canvas
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        
        // Dispose canvas
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    //MARK: Convertations Helpers
    class func convertFloatShutterToString(value:Float) -> String {
        var returnString = ""
        if (value == 0.5) {
            returnString = "1/2s"
        } else if (value == 0.2) {
            returnString = "1/5s"
        } else if (value == 0.1) {
            returnString = "1/10s"
        } else if (value == 0.05) {
            returnString = "1/20s"
        } else if (value == 0.02) {
            returnString = "1/50s"
        } else if (value == 0.01) {
            returnString = "1/100s"
        } else if (value == 0.005) {
            returnString = "1/200s"
        } else if (value == 0.002) {
            returnString = "1/500s"
        } else if (value == 0.001) {
            returnString = "1/1000s"
        } else if (value == 0.0005) {
            returnString = "1/2000s"
        } else if (value == 0.0002) {
            returnString = "1/5000s"
        } else if (value == 0.00015) {
            returnString = "1/8000s"
        }
        
        return returnString
    }
    
    class func convertShutterToCollectionViewPosition(valueShutter:Float) -> NSIndexPath {
        
        var itemPosition = 0
        if (valueShutter <= 0.00015) {
            itemPosition = 10
        } else if (valueShutter <= 0.0002) {
            itemPosition = 9
        } else if (valueShutter <= 0.0005) {
            itemPosition = 8
        } else if (valueShutter <= 0.001) {
            itemPosition = 7
        } else if (valueShutter <= 0.002) {
            itemPosition = 6
        } else if (valueShutter <= 0.005) {
            itemPosition = 5
        } else if (valueShutter <= 0.01) {
            itemPosition = 4
        } else if (valueShutter <= 0.02) {
            itemPosition = 3
        } else if (valueShutter <= 0.05) {
            itemPosition = 2
        } else if (valueShutter <= 0.1) {
            itemPosition = 1
        } else if (valueShutter <= 0.5) {
            itemPosition = 0
        }
        
        return NSIndexPath(forItem: itemPosition, inSection: 0)
    }
    
    class func convertISOToCollectionViewPosition(valueISO:Float) -> NSIndexPath {
        
        var itemPosition = 0
        
        if(valueISO <= 50) {
            itemPosition = 0
        } else if (valueISO <= 100) {
            itemPosition = 1
        } else if (valueISO <= 200) {
            itemPosition = 2
        } else if (valueISO <= 400) {
            itemPosition = 3
        } else if (valueISO <= 800) {
            itemPosition = 4
        } else if (valueISO <= 1600) {
            itemPosition = 5
        } else if (valueISO <= 2000) {
            itemPosition = 6
        }
        
        return NSIndexPath(forItem: itemPosition, inSection: 0)
    }
    
    //MARK: Other Helpers
    class func findCenterIndexForCollectionView(collectionView:UICollectionView) -> NSIndexPath {
        // Get zone for search
        let collectionOrigin = collectionView.bounds.origin
        
        // Get zone width
        let collectionWidth = collectionView.bounds.width
        
        // Define variables for search
        var centerPoint: CGPoint!
        var newX: CGFloat!
        
        //TODO: Comment more!
        if collectionOrigin.x > 0 {
            newX = collectionOrigin.x + collectionWidth / 2
            centerPoint = CGPoint(x: newX, y: collectionOrigin.y)
        } else {
            newX = collectionWidth / 2
            centerPoint = CGPoint(x: newX, y: collectionOrigin.y)
        }
        
        let index = collectionView.indexPathForItemAtPoint(centerPoint)
        print(index)
        
        return index!
    }
}
