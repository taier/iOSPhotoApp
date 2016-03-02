//
//  ViewController.swift
//  APhoto
//
//  Created by Denis Kaibagarov on 3/1/16.
//  Copyright © 2016 Sudo Mobi. All rights reserved.
//

import UIKit
import MobileCoreServices // for kUTTypeImage

class CameraController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {

    // Variables
    var imagePicker: UIImagePickerController!
    var takePhoto:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if(!takePhoto) {
            lauchCamera()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func lauchCamera() {
        if UIImagePickerController.isSourceTypeAvailable(
            UIImagePickerControllerSourceType.Camera) {
                
                imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType =
                    UIImagePickerControllerSourceType.Camera
                imagePicker.mediaTypes = [kUTTypeImage as String]
                imagePicker.allowsEditing = false
                
                self.presentViewController(imagePicker, animated: false,
                    completion: nil)
        } else {
            print("Can't use camera");
        }
    }
    
    // MARK: Navigation
    
    func moveToImageViewControllerWithImage(image: UIImage) {
        let controller:ImageViewController = storyboard?.instantiateViewControllerWithIdentifier("imageViewController") as! ImageViewController
        controller.image = image
        self.presentViewController(controller, animated: false, completion: nil)
    }
    
    // MARK: Camera Delegates
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        // you code
        takePhoto = true
        imagePicker.dismissViewControllerAnimated(false, completion: nil)
        moveToImageViewControllerWithImage(image)
    }
}

