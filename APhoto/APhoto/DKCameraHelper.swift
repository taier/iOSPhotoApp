//
//  DKCameraHelper.swift
//  APhoto
//
//  Created by Deniss Kaibagarovs on 10/03/16.
//  Copyright © 2016 Sudo Mobi. All rights reserved.
//

import UIKit

class DKCameraHelper: NSObject {

    // MARK: Init
    class var sharedInstance: DKCameraHelper {
        struct Static {
            static let instance = DKCameraHelper()
        }
        return Static.instance
    }
    
    //MARK: Image
    class func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight))
        image.drawInRect(CGRectMake(0, 0, newWidth, newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    //MARK: Convertations
    class func convertFloatShutterToString(value:Float) -> String {
        var returnString = "";
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
    
    //MARK: Other
    class func findCenterIndexForCollectionView(collectionView:UICollectionView) -> NSIndexPath {
        let collectionOrigin = collectionView.bounds.origin
        let collectionWidth = collectionView.bounds.width
        var centerPoint: CGPoint!
        var newX: CGFloat!
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
