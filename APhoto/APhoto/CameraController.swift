//
//  ViewController.swift
//  APhoto
//
//  Created by Denis Kaibagarov on 3/1/16.
//  Copyright © 2016 Sudo Mobi. All rights reserved.
//

import UIKit
import AVFoundation

class CameraController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {

    // MARK: Enums
    enum ManualControllsMode {
        case IOS
        case Shutter
    }
    
    // MARK: Variables
    let captureSession = AVCaptureSession()
    let stillImageOutput = AVCaptureStillImageOutput()
    var mainCaptureDevice = AVCaptureDevice?()
    var currentManualControllsMode = ManualControllsMode?()
    
    // Camera settings related
    var currentShutter = CMTime?()
    var currentISO = Float?()
    
    // MARK: Outlets
    @IBOutlet weak var viewCamera: UIView!
    @IBOutlet var viewSlider: UISlider!
    @IBOutlet var labelCurrentValue: UILabel!
    @IBOutlet var labelInfo: UILabel!
    @IBOutlet var viewControlls: UIView!
    
    
    //MARK: Live cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        lauchCamera() // For correct frame
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // MARK: SetupStuff
    func updateValueLabelWithValue(value:Float) {
        self.labelCurrentValue.text = String(format: "%.0f",value)
    }
    
    func lauchCamera() {
        
        if(captureSession.running) { // If already have active camera
            return;
        }

        let devices = AVCaptureDevice.devices().filter{ $0.hasMediaType(AVMediaTypeVideo) && $0.position == AVCaptureDevicePosition.Back }
        if let captureDevice = devices.first as? AVCaptureDevice  {
            // Quality
            captureSession.sessionPreset = AVCaptureSessionPresetPhoto
            stillImageOutput.outputSettings = [AVVideoCodecKey:AVVideoCodecJPEG]
            
            // Streaming session
            mainCaptureDevice = captureDevice
            captureSession.addInput(try!AVCaptureDeviceInput(device: captureDevice))
            captureSession.startRunning()
            if captureSession.canAddOutput(stillImageOutput) {
                captureSession.addOutput(stillImageOutput)
            }
            
            // Preview
            if let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession) {
                previewLayer.bounds = self.viewCamera.frame
                previewLayer.position = CGPointMake(self.viewCamera.bounds.midX, self.viewCamera.bounds.midY)
                previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
                let cameraPreview = UIView(frame: self.viewCamera.frame)
                cameraPreview.layer.addSublayer(previewLayer)
                view.addSubview(cameraPreview)
            }
        }
    }
    
    // MAR: Camera stuff
    func processPhoto() { // Save and move to next controller
        if let videoConnection = stillImageOutput.connectionWithMediaType(AVMediaTypeVideo) {
            stillImageOutput.captureStillImageAsynchronouslyFromConnection(videoConnection) {
                (imageDataSampleBuffer, error) -> Void in
                let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer)
                self.moveToImageViewControllerWithImage(UIImage(data: imageData)!)
            }
        }
    }
    
    func setupControllsFroISO() {
        // Check for available device
        if let device = mainCaptureDevice {
            do {
                try device.lockForConfiguration()
            } catch {
                return
            }
            
            // Set slider appearance
            self.viewSlider.minimumValue = device.activeFormat.minISO
            self.viewSlider.maximumValue = device.activeFormat.maxISO
            self.viewSlider.value = device.ISO
            
            // Update UI
            self.labelInfo.text = "ISO"
            updateValueLabelWithValue(device.ISO)
            self.viewControlls.hidden = false;
            
            // Change currenct application state
            currentManualControllsMode = ManualControllsMode.IOS;
            
            //TODO:Check if can remove
            device.unlockForConfiguration()
        }
        
    }
    
    func setupControllsForShutter() {
        // Check for available device
        if let device = mainCaptureDevice {
            do {
                try device.lockForConfiguration()
            } catch {
                return
            }
            
            // Set Slider appearance
            self.viewSlider.minimumValue = Float(CMTimeGetSeconds(device.activeFormat.minExposureDuration))
            self.viewSlider.maximumValue = Float(CMTimeGetSeconds(device.activeFormat.maxExposureDuration))
            self.viewSlider.value =  Float(CMTimeGetSeconds(device.exposureDuration))
            
            // Update UI
            self.labelInfo.text = "Shutter"
            updateValueLabelWithValue(1/(self.viewSlider.value * 0.01))
            self.viewControlls.hidden = false;

            // Change currenct application state
            currentManualControllsMode = ManualControllsMode.Shutter;
            
            //TODO:Check if can remove
            device.unlockForConfiguration()
        }
    }
    
    func ChangeISOWithValue(value:Float) {
        // Check for available device
        if let device = mainCaptureDevice {
            do {
                try device.lockForConfiguration()
            } catch {
                return
            }
            
            // Update UI
            updateValueLabelWithValue(value)
            
            // Save current Value for other controlls reuse
            self.currentISO = value
            
            // Get selected shutter if exist
            let shutter = self.currentShutter == nil ? AVCaptureExposureDurationCurrent : self.currentShutter
            
            // Change camere controll value
            device.setExposureModeCustomWithDuration(shutter!, ISO:value, completionHandler: { (CMTime) -> Void in
                device.unlockForConfiguration()
            })
        }
    }
    
    func ChangeShutterWithValue(value:Float) {
        // Check for available device
        if let device = mainCaptureDevice {
            do {
                try device.lockForConfiguration()
            } catch {
                return
            }
            
            // Update UI
            updateValueLabelWithValue(1/(value * 0.01))
            
            // Save current Value for other controlls reuse
            self.currentShutter = CMTimeMake(Int64(value * 1000000000) , device.exposureDuration.timescale)
            
            // Get selected ISO if exist
            let ISO = self.currentISO == nil ? AVCaptureISOCurrent : self.currentISO;
            
            // Change camera controll value
            device.setExposureModeCustomWithDuration(self.currentShutter!, ISO:ISO!, completionHandler: { (CMTime) -> Void in
                device.unlockForConfiguration()
            })
        }
    }

    
    // MARK: Actions
    
    @IBAction func buttonTakePhoto(sender: AnyObject) {
       processPhoto()
    }
    
    @IBAction func buttonISO(sender: AnyObject) {
        setupControllsFroISO()
    }
    @IBAction func buttonShutter(sender: AnyObject) {
        setupControllsForShutter()
    }
    
    @IBAction func sliderValueChange(sender: UISlider) {
        let value:Float = Float(sender.value);
        
        if(currentManualControllsMode == ManualControllsMode.IOS) {
           ChangeISOWithValue(value)
        } else if (currentManualControllsMode == ManualControllsMode.Shutter) {
            ChangeShutterWithValue(value)
        }
    }
    
    // MARK: Navigation
    func moveToImageViewControllerWithImage(image: UIImage) {
        let controller:ImageViewController = storyboard?.instantiateViewControllerWithIdentifier("imageViewController") as! ImageViewController
        controller.image = resizeImage(image, newWidth: 400)
        self.presentViewController(controller, animated: false,completion:{ () -> Void in
        })
    }
    
    // MARK : Helpers
    //TODO: Move to another class
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

