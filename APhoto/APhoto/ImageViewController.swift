//
//  ImageViewController.swift
//  APhoto
//
//  Created by Denis Kaibagarov on 3/2/16.
//  Copyright © 2016 Sudo Mobi. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController, UICollectionViewDataSource {

    //MARK: Variables
    var image:UIImage!
    var imageBlackAndWhite:UIImage!
    
    //MARK: Outlets
    @IBOutlet var mainImageView: UIImageView!
    @IBOutlet var labelSaved: UILabel!
    
    override func viewDidLoad() {
        // Super init
        super.viewDidLoad()
        // Init custom code
        initialSetup()
    }
    
    // MARK: Setup
    func initialSetup() {
        // Set initial image to view
        self.mainImageView.image = self.image;
    }

    
    // MARK: Actions
    @IBAction func handleDoubleTap(recognizer:UITapGestureRecognizer) {
        print("Save to photo library")
        UIImageWriteToSavedPhotosAlbum(self.image, self, #selector(ImageViewController.image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @IBAction func handleSwipeBack(recognizer:UISwipeGestureRecognizer) {
        print("Swiped back to return")
        self.dismissViewControllerAnimated(false, completion: nil)
    }
    
    // MARK: Image Saving Delegates
    func image(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo:UnsafePointer<Void>) {
        // Notify about result
        if error == nil {
           notificatonSaveSuccess()
        } else {
            notificationSaveError(error!)
        }
    }
    
    // MARK: Collection View Delegates
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int  {
        return DKAEffectManager.sharedInstance.createEffectsItemsAndGetCount(self.image)
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell  {
        // Get Cell
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("imageCell", forIndexPath: indexPath) as! ImageCollectionViewCell
        
        // Get object to show
        let object:DKAEffectObject = DKAEffectManager.sharedInstance.effectObjectsArray.objectAtIndex(indexPath.item) as! DKAEffectObject
        
        // Set cell with object
        cell.imageView.image = object.image
        cell.name.text = object.effectName
        
        // Return cell to show
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        // Get selected object by cell index
        let object:DKAEffectObject = DKAEffectManager.sharedInstance.effectObjectsArray.objectAtIndex(indexPath.item) as! DKAEffectObject
        
        // Save selected image
        self.image = object.image
        
        // Update Main image with selected one
        self.mainImageView.image = object.image
    }
    
    //MARK: Notifications
    func notificatonSaveSuccess() {
        // Create alert Controller Title and body
        let ac = UIAlertController(title: "Saved!", message: "Your altered image has been saved to your photos.", preferredStyle: .Alert)
        
        // Add buttons
        ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        
        // Show
        presentViewController(ac, animated: true, completion: nil)
    }
    
    func notificationSaveError(error: NSError) {
        // Create alert Controller Title and body
        let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .Alert)
        
         // Add buttons
        ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        
         // Show
        presentViewController(ac, animated: true, completion: nil)

    }
}
