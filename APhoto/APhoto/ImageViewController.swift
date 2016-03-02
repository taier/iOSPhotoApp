//
//  ImageViewController.swift
//  APhoto
//
//  Created by Denis Kaibagarov on 3/2/16.
//  Copyright © 2016 Sudo Mobi. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController, UICollectionViewDataSource {

    // Outlets
    @IBOutlet var mainImageView: UIImageView!
    
    // Variables
    var image:UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Setup

    func initialSetup() {
        self.mainImageView.image = self.image;
    }
    
    // MARK: Collection View Delegates
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int  {
        return 12
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell  {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("imageCell", forIndexPath: indexPath) as! ImageCollectionViewCell
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.mainImageView.image = convertToGrayScale(self.image);
    }
    
    // MARK : Filters
    
    func convertToGrayScale(image : UIImage) -> UIImage {
        
        let imgOrientation = image.imageOrientation
        let imgScale = image.scale
        
        let filter: CIFilter = CIFilter(name: "CIPhotoEffectMono")!
        filter.setDefaults()
        filter.setValue(CoreImage.CIImage(image: image)!, forKey: kCIInputImageKey)
        
        return UIImage(CGImage: CIContext(options:nil).createCGImage(filter.outputImage!, fromRect: filter.outputImage!.extent), scale:imgScale, orientation:imgOrientation)
    }
}
