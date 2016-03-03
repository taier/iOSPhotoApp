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
    @IBOutlet var labelSaved: UILabel!
    
    // Variables
    var image:UIImage!
    var imageBlackAndWhite:UIImage!
    
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

    
    // MARK: Actions
    @IBAction func handleDoubleTap(recognizer:UITapGestureRecognizer) {
        print("Touched")
        UIImageWriteToSavedPhotosAlbum(self.image, self, "image:didFinishSavingWithError:contextInfo:", nil)
    }
    
    @IBAction func handleSwipeBack(recognizer:UISwipeGestureRecognizer) {
        print("Swiped")
        self.dismissViewControllerAnimated(false, completion: nil)
    }
    
    // MARK: Image Saving Delegates
    
    func image(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo:UnsafePointer<Void>) {
        if error == nil {
            let ac = UIAlertController(title: "Saved!", message: "Your altered image has been saved to your photos.", preferredStyle: .Alert)
            ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            presentViewController(ac, animated: true, completion: nil)
        } else {
            let ac = UIAlertController(title: "Save error", message: error?.localizedDescription, preferredStyle: .Alert)
            ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            presentViewController(ac, animated: true, completion: nil)
        }
    }
    
    // MARK: Collection View Delegates
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int  {
        return DKAEffectManager.sharedInstance.createEffectsItemsAndGetCount(self.image)
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell  {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("imageCell", forIndexPath: indexPath) as! ImageCollectionViewCell
        let object:DKAEffectObject = DKAEffectManager.sharedInstance.effectObjectsArray.objectAtIndex(indexPath.item) as! DKAEffectObject
        cell.imageView.image = object.image
        cell.name.text = object.effectName
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let object:DKAEffectObject = DKAEffectManager.sharedInstance.effectObjectsArray.objectAtIndex(indexPath.item) as! DKAEffectObject
        self.mainImageView.image = object.image
        self.image = object.image
    }
    
}
