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

    // Variables
    let captureSession = AVCaptureSession()
    let stillImageOutput = AVCaptureStillImageOutput()
    var mainCaptureDevice = AVCaptureDevice?()
    
    @IBOutlet weak var viewCamera: UIView!
    @IBOutlet var viewSlider: UISlider!
    @IBOutlet var labelCurrentValue: UILabel!
    @IBOutlet var labelInfo: UILabel!
    @IBOutlet var viewControlls: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        lauchCamera()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // MARK: SetupStuff
    func updateValueLabelWithValue(value:Float) {
        self.labelCurrentValue.text = String(format: "%.0f",value)
    }
    
    func setupDevice() {
        
    }
    
    func lauchCamera() {
        
        if(captureSession.running) {
            return;
        }

        let devices = AVCaptureDevice.devices().filter{ $0.hasMediaType(AVMediaTypeVideo) && $0.position == AVCaptureDevicePosition.Back }
        if let captureDevice = devices.first as? AVCaptureDevice  {
            
            captureSession.sessionPreset = AVCaptureSessionPresetLow
            stillImageOutput.outputSettings = [AVVideoCodecKey:AVVideoCodecJPEG]
            
            mainCaptureDevice = captureDevice
            captureSession.addInput(try!AVCaptureDeviceInput(device: captureDevice))
            captureSession.sessionPreset = AVCaptureSessionPresetPhoto
            captureSession.startRunning()
            stillImageOutput.outputSettings = [AVVideoCodecKey:AVVideoCodecJPEG]
            if captureSession.canAddOutput(stillImageOutput) {
                captureSession.addOutput(stillImageOutput)
            }
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

    func processPhoto() {
        if let videoConnection = stillImageOutput.connectionWithMediaType(AVMediaTypeVideo) {
            stillImageOutput.captureStillImageAsynchronouslyFromConnection(videoConnection) {
                (imageDataSampleBuffer, error) -> Void in
                let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer)
                self.moveToImageViewControllerWithImage(UIImage(data: imageData)!)
            }
        }
    }
    
    func setupControllsFroISO() {
        if let device = mainCaptureDevice {
            do {
                try device.lockForConfiguration()
            } catch {
                return
            }
            
            // Can change iOS
            self.viewSlider.minimumValue = device.activeFormat.minISO
            self.viewSlider.maximumValue = device.activeFormat.maxISO
            self.viewSlider.value = device.ISO
            self.labelInfo.text = "ISO"
            self.viewControlls.hidden = false;
            updateValueLabelWithValue(device.ISO)
        }
        
    }
    
    // MARK: Actions
    
    @IBAction func buttonTakePhoto(sender: AnyObject) {
       processPhoto()
    }
    
    @IBAction func buttonISO(sender: AnyObject) {
        setupControllsFroISO()
    }
    
    @IBAction func sliderValueChange(sender: UISlider) {
        if let device = mainCaptureDevice {
            do {
                try device.lockForConfiguration()
            } catch {
                return
            }
            
            let value:Float = Float(sender.value);
            updateValueLabelWithValue(value)
            
            device.setExposureModeCustomWithDuration(AVCaptureExposureDurationCurrent, ISO:value, completionHandler: { (CMTime) -> Void in
                device.unlockForConfiguration()
            })
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

