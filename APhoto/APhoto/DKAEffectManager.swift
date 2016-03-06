//
//  DKAEffectManager.swift
//  APhoto
//
//  Created by Deniss Kaibagarovs on 02/03/16.
//  Copyright © 2016 Sudo Mobi. All rights reserved.
//

import UIKit

class DKAEffectManager: NSObject {
    
    // MARK: Init
    var effectObjectsArray: NSMutableArray!
    
    class var sharedInstance: DKAEffectManager {
        struct Static {
            static let instance = DKAEffectManager()
        }
        return Static.instance
    }
    
   // MARK: public API
    func createEffectsItemsAndGetCount(image :UIImage) ->Int {
        
        self.effectObjectsArray = NSMutableArray()
        self.effectObjectsArray.addObject(DKAEffectObject(effectImage: filterBlackAndWhite(image), effectName: "B&W"))
        self.effectObjectsArray.addObject(DKAEffectObject(effectImage: filterSepia(image), effectName: "Sepia"))
        self.effectObjectsArray.addObject(DKAEffectObject(effectImage: filterNoir(image), effectName: "Noir"))
        self.effectObjectsArray.addObject(DKAEffectObject(effectImage: filterInstant(image), effectName: "Instant"))
        self.effectObjectsArray.addObject(DKAEffectObject(effectImage: filterChrome(image), effectName: "Chrome"))
        self.effectObjectsArray.addObject(DKAEffectObject(effectImage: filterProcess(image), effectName: "Process"))
        self.effectObjectsArray.addObject(DKAEffectObject(effectImage: filterFade(image), effectName: "Fade"))
        self.effectObjectsArray.addObject(DKAEffectObject(effectImage: filterTonal(image), effectName: "Tonal"))
        
        return self.effectObjectsArray.count;
    }
    
    // MARK: Filters
    func converToFilterWithName(filterName: String, image: UIImage) -> UIImage {
        let imgOrientation = image.imageOrientation
        let imgScale = image.scale
        
        let filter: CIFilter = CIFilter(name:filterName)!
        filter.setDefaults()
        filter.setValue(CoreImage.CIImage(image: image)!, forKey: kCIInputImageKey)
        
        return UIImage(CGImage: CIContext(options:nil).createCGImage(filter.outputImage!, fromRect: filter.outputImage!.extent), scale:imgScale, orientation:imgOrientation)
    }
    
    func filterBlackAndWhite(imageToConvert : UIImage) -> UIImage {
        return converToFilterWithName("CIPhotoEffectMono", image:imageToConvert)
    }
    
    func filterSepia(imageToConvert : UIImage) -> UIImage {
        return converToFilterWithName("CISepiaTone", image:imageToConvert)
    }
    
    func filterNoir(imageToConvert : UIImage) -> UIImage {
        return converToFilterWithName("CIPhotoEffectNoir", image:imageToConvert)
    }
    
    func filterInstant(imageToConvert : UIImage) -> UIImage {
        return converToFilterWithName("CIPhotoEffectInstant", image:imageToConvert)
    }
    
    func filterChrome(imageToConvert : UIImage) -> UIImage {
        return converToFilterWithName("CIPhotoEffectChrome", image:imageToConvert)
    }
    
    func filterProcess(imageToConvert : UIImage) -> UIImage {
        return converToFilterWithName("CIPhotoEffectProcess", image:imageToConvert)
    }
    
    func filterFade(imageToConvert : UIImage) -> UIImage {
        return converToFilterWithName("CIPhotoEffectFade", image:imageToConvert)
    }
    
    func filterTonal(imageToConvert : UIImage) -> UIImage {
        return converToFilterWithName("CIPhotoEffectTonal", image:imageToConvert)
    }
    
}
