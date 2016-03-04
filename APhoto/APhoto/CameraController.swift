//
//  ViewController.swift
//  APhoto
//
//  Created by Denis Kaibagarov on 3/1/16.
//  Copyright © 2016 Sudo Mobi. All rights reserved.
//

import UIKit
import MobileCoreServices // for kUTTypeImage // Remove
import AVFoundation

class CameraController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {

    // Variables
    var imagePicker: UIImagePickerController! //Remove
    var takePhoto:Bool = false
    
    let captureSession = AVCaptureSession()
    var captureDevice : AVCaptureDevice?
    
    @IBOutlet weak var viewCamera: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        captureSession.sessionPreset = AVCaptureSessionPresetLow
        let devices = AVCaptureDevice.devices()
        print(devices)
        
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
        captureSession.sessionPreset = AVCaptureSessionPresetLow
        let devices = AVCaptureDevice.devices()
        // Loop through all the capture devices on this phone
        for device in devices {
            // Make sure this particular device supports video
            if (device.hasMediaType(AVMediaTypeVideo)) {
                // Finally check the position and confirm we've got the back camera
                if(device.position == AVCaptureDevicePosition.Back) {
                    captureDevice = device as? AVCaptureDevice
                }
            }
        }
        
        if captureDevice != nil {
            beginSession()
        }
    }
    
    // MAR: Camera stuff
    
    func beginSession() {
        
        configureDevice()
        
        try! captureSession.addInput(AVCaptureDeviceInput(device: captureDevice))
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.view.layer.addSublayer(previewLayer)
        previewLayer?.frame = self.viewCamera.layer.frame
        captureSession.startRunning()
    }
    
    func configureDevice() {
        if let device = captureDevice {
            try! device.lockForConfiguration()
            device.focusMode = .Locked
            device.unlockForConfiguration()
        }
    }
    
    func updateDeviceSettings(focusValue : Float, isoValue : Float) {
        if let device = captureDevice {
            
            do {
                try device.lockForConfiguration()
            } catch {
                return
            }
                device.setFocusModeLockedWithLensPosition(focusValue, completionHandler: { (time) -> Void in
                    //
                })
                
                // Adjust the iso to clamp between minIso and maxIso based on the active format
                let minISO = device.activeFormat.minISO
                let maxISO = device.activeFormat.maxISO
                let clampedISO = isoValue * (maxISO - minISO) + minISO
                
                device.setExposureModeCustomWithDuration(AVCaptureExposureDurationCurrent, ISO: clampedISO, completionHandler: { (time) -> Void in
                    //
                })
                
                device.unlockForConfiguration()
        }
    }
    
    let screenWidth = UIScreen.mainScreen().bounds.size.width
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch =  touches.first{
            let touchPer = touchPercent(touch)
            updateDeviceSettings(Float(touchPer.x), isoValue: 0.5)
        }
      
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch =  touches.first{
            let touchPer = touchPercent(touch)
            updateDeviceSettings(Float(touchPer.x), isoValue: 1)
        }
    }
    
    func touchPercent(touch : UITouch) -> CGPoint {
        // Get the dimensions of the screen in points
        let screenSize = UIScreen.mainScreen().bounds.size
        
        // Create an empty CGPoint object set to 0, 0
        var touchPer = CGPointZero
        
        // Set the x and y values to be the value of the tapped position, divided by the width/height of the screen
        touchPer.x = touch.locationInView(self.view).x / screenSize.width
        touchPer.y = touch.locationInView(self.view).y / screenSize.height
        
        // Return the populated CGPoint
        return touchPer
    }
    
    // MARK: Navigation
    func moveToImageViewControllerWithImage(image: UIImage) {
        let controller:ImageViewController = storyboard?.instantiateViewControllerWithIdentifier("imageViewController") as! ImageViewController
        controller.image = resizeImage(image, newWidth: 400)
        self.presentViewController(controller, animated: false,completion:{ () -> Void in
            self.takePhoto = false
        })
    }
    
    // MARK: Camera Delegates
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        // you code
        takePhoto = true
        imagePicker.dismissViewControllerAnimated(false, completion: nil)
        moveToImageViewControllerWithImage(image)
    }
    
    // MARK : Helpers
    
    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
        
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight))
        image.drawInRect(CGRectMake(0, 0, newWidth, newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }

}

