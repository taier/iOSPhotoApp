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
    var arrayISO = [Float]()
    var arrayShutter = [Float]()
    
    // MARK: Outlets
    @IBOutlet weak var viewCamera: UIView!
    @IBOutlet var viewSlider: UISlider!
    @IBOutlet var labelCurrentValue: UILabel!
    @IBOutlet var labelInfo: UILabel!
    @IBOutlet var viewControlls: UIView!
    
    //MARK: Live cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareCamera()
        prepareISO()
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
    
    func updateValueLabelWithShutterValue(value:Float) {
        self.labelCurrentValue.text = String(format: "1/%.0fs",value)
    }
    
    func lauchCamera() {
        
//        if(captureSession.running) { // If already have active camera
//            return;
//        }
        
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
    
    func prepareCamera() {
        
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
        }
    }
    
    func prepareISO() {
        if let device = mainCaptureDevice {
            do {
                try device.lockForConfiguration()
            } catch {
                return
            }
            
            let minISO = Float(ceil(device.activeFormat.minISO/10)*10)
            let maxISO = Float(round(device.activeFormat.maxISO/1000)*1000)
            
            var newISO:Float = minISO
            while (newISO <= maxISO) {
                let digArray = Int(newISO).description.characters.map{Int(String($0)) ?? 0}
                
                arrayISO.append(newISO)
//                newISO = Int(newISO/digArray.count *10) * 1.25
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
            updateValueLabelWithShutterValue(1/self.viewSlider.value)
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
            updateValueLabelWithShutterValue(1/value)
            print(value)
            
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
    
    // MARK: Collection View Delegates
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int  {
        return arrayISO.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell  {

        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CellShutter", forIndexPath: indexPath) as! ManualControllCollectionViewCell
        let iso = arrayISO[indexPath.item]
        cell.labelMain.text =  String(format: "%.0f",iso)
        return cell
    }
    
//    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
//        let object:DKAEffectObject = DKAEffectManager.sharedInstance.effectObjectsArray.objectAtIndex(indexPath.item) as! DKAEffectObject
//        self.mainImageView.image = object.image
//        self.image = object.image
//    }

    
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

