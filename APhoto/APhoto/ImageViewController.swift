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
        saveImage()
    }
    
    @IBAction func handleSwipeBack(recognizer:UISwipeGestureRecognizer) {
        print("Swiped back to return")
        moveToPreviosScreen()
    }
    
    @IBAction func onShareButtonPress(sender: AnyObject) {
        shareImage()
    }
    
    @IBAction func onSaveButtonPress(sender: AnyObject) {
        saveImage()
    }
    
    @IBAction func onBackButtonPress(sender: AnyObject) {
        moveToPreviosScreen()
    }
    
    
    // Private methods
    func moveToPreviosScreen() {
        print("Move to previos screen")
        self.dismissViewControllerAnimated(false, completion: nil)
    }
    
    func shareImage() {
        print("Save Image")
        let vc = UIActivityViewController(activityItems: [image], applicationActivities: [])
        presentViewController(vc, animated: true, completion: nil)
    }
    
    func saveImage() {
        print("Save to photo library")
        UIImageWriteToSavedPhotosAlbum(self.image, self, #selector(ImageViewController.image(_:didFinishSavingWithError:contextInfo:)), nil)
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
