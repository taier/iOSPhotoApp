//
//  ViewController.swift
//  APhoto
//
//  Created by Denis Kaibagarov on 3/1/16.
//  Copyright © 2016 Sudo Mobi. All rights reserved.
//

import UIKit
import AVFoundation

class CameraController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, AVCaptureVideoDataOutputSampleBufferDelegate  {

    // MARK: Enums
    enum ManualControllsMode {
        case IOS
        case Shutter
    }
    
    // MARK: Variables
    let captureSession = AVCaptureSession()
    let stillImageOutput = AVCaptureStillImageOutput()
    var videoImageOutput = AVCaptureVideoDataOutput()
    var mainCaptureDevice = AVCaptureDevice?()
    var currentManualControllsMode = ManualControllsMode?()
    
    // Camera settings related
    var currentShutter = CMTime?()
    var currentISO = Float?()
    var arrayISO = [Float]()
    var arrayShutter = [Float]()
    var cameraRunning = false
    
    // Data 
    var arrayOfImagesForLongExposure = NSMutableArray()
    
    
    // MARK: Outlets
    @IBOutlet weak var viewCamera: UIView!
    @IBOutlet var viewSlider: UISlider!
    @IBOutlet var labelCurrentValue: UILabel!
    @IBOutlet var labelInfo: UILabel!
    @IBOutlet var buttonAutoISO: UIButton!
    @IBOutlet var imageViewPreviewLongExposure: UIImageView!
    
    @IBOutlet var collectionViewShutter: UICollectionView!
    @IBOutlet var collectionViewISO: UICollectionView!
    
    @IBOutlet var viewContainerManualControlls: UIView!
    @IBOutlet var viewFocusControlls: UIView!
    
    //MARK: Live cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareCamera()
        arrayISO = DKCameraHelper.prepareISO()
        arrayShutter = DKCameraHelper.prepareShutter()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(CameraController.onWatchButonPressAction(_:)), name: "onWatchButonPressNotification", object: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        setCurrentCameraControllsValuesForUI()
        lauchCamera() // For correct frame
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // MARK: Setup
    func lauchCamera() {
        
        if(cameraRunning) {
            return
        }
        
        // Preview
        if let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession) {
            previewLayer.bounds = self.viewCamera.frame
            previewLayer.position = CGPointMake(self.viewCamera.bounds.midX, self.viewCamera.bounds.midY)
            previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
            let cameraPreview = UIView(frame: self.viewCamera.frame)
            cameraPreview.layer.addSublayer(previewLayer)
            
            // Tap Gesture
            let tap = UITapGestureRecognizer(target: self, action : #selector(CameraController.handleTap(_:)))
            tap.numberOfTapsRequired = 1
            cameraPreview.addGestureRecognizer(tap)
            viewCamera.addSubview(cameraPreview)
            cameraRunning = true
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
    
    func setCurrentCameraControllsValuesForUI() {
        if let device = mainCaptureDevice {
            do {
                try device.lockForConfiguration()
            } catch {
                return
            }
            
            // ISO
            let itemIndexPathForISO:NSIndexPath = DKCameraHelper.convertISOToCollectionViewPosition(device.ISO)
            self.collectionViewISO.scrollToItemAtIndexPath(itemIndexPathForISO, atScrollPosition: UICollectionViewScrollPosition.CenteredHorizontally, animated: false)
            
            //Shutter
            let itemIndexPathForShutter = DKCameraHelper.convertShutterToCollectionViewPosition(Float(device.exposureDuration.seconds / 50))
            self.collectionViewShutter.scrollToItemAtIndexPath(itemIndexPathForShutter, atScrollPosition: UICollectionViewScrollPosition.CenteredHorizontally, animated: false)
        }
    }
    
    func setAutoISO() {
        if let device = mainCaptureDevice {
            do {
                try device.lockForConfiguration()
            } catch {
                return
            }
            
            device.exposureMode = AVCaptureExposureMode.ContinuousAutoExposure
            device.unlockForConfiguration()
            
            let dispatchTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(2 * Double(NSEC_PER_SEC)))
            dispatch_after(dispatchTime, dispatch_get_main_queue(), {
                self.setCurrentCameraControllsValuesForUI()
            })
            
        }
    }
    
    func toggleFlash() {
        if let device = mainCaptureDevice {
            do {
                try device.lockForConfiguration()
            } catch {
                return
            }
            
            if (device.hasTorch) {
            do {
                try device.lockForConfiguration()
                if (device.torchMode == AVCaptureTorchMode.On) {
                    device.torchMode = AVCaptureTorchMode.Off
                } else {
                    try device.setTorchModeOnWithLevel(1.0)
                }
                device.unlockForConfiguration()
                } catch {
                print(error)
                }
            }
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
    
    
    func ChangeShutterAndISOWithValues(value:Float, withISO ISO:Float) {
        if let device = mainCaptureDevice {
            do {
                try device.lockForConfiguration()
            } catch {
                return
            }
            
            // Save current Value for other controlls reuse
            let correctShutter = CMTimeMake(Int64(value * 1000000000) , device.exposureDuration.timescale)
            
            // Change camera controll value
            device.setExposureModeCustomWithDuration(correctShutter, ISO:ISO, completionHandler: { (CMTime) -> Void in
                device.unlockForConfiguration()
            })
        }
    }
    
    func changeFocus(value:Float) {
        if let device = mainCaptureDevice {
            do {
                try device.lockForConfiguration()
            } catch {
                return
            }
            
            device.setFocusModeLockedWithLensPosition(value, completionHandler: { (time) -> Void in
            })
            
            device.unlockForConfiguration()
        }
    }

    
    // MARK: Actions
    @IBAction func buttonTakePhoto(sender: AnyObject) {
       processPhoto()
    }
    
    
    @IBAction func buttonFocus(sender: AnyObject) {
        self.viewContainerManualControlls.hidden = true
        self.viewFocusControlls.hidden = false
    }
    
    @IBAction func buttonManualControlls(sender: AnyObject) {
        self.viewContainerManualControlls.hidden = false
        self.viewFocusControlls.hidden = true
    }
    
    @IBAction func sliderValueChange(sender: UISlider) {
        let value:Float = Float(sender.value);
        
        changeFocus(value)
    }
    @IBAction func buttonAutoISO(sender: AnyObject) {
        setAutoISO()
        toggleAutoButtonON(true)
    }
    
    @IBAction func buttonFlash(sender: AnyObject) {
        toggleFlash();
    }
    
    // MARK: Touches
    func handleTap(sender: UITapGestureRecognizer) {
        
        if sender.state == .Ended {
            //TODO: Move to helper class
            let touchLocation: CGPoint = sender.locationInView(self.viewCamera)
            let focus_x = touchLocation.x/self.viewCamera.frame.size.width;
            let focus_y = touchLocation.y/self.viewCamera.frame.size.height;
            let focusPoint = CGPointMake(focus_x,focus_y)
            
            if let device = mainCaptureDevice {
                do {
                    try device.lockForConfiguration()
                } catch {
                    return
                }

                device.focusPointOfInterest = focusPoint
                device.focusMode = AVCaptureFocusMode.ContinuousAutoFocus
                device.exposurePointOfInterest = focusPoint
                device.exposureMode = AVCaptureExposureMode.ContinuousAutoExposure
                
                device.unlockForConfiguration()
                print("Focus on point ",focus_x,focus_y)
                
                // Animate
                highlightTouchOnPoint(touchLocation, inView: self.viewCamera)
            }

        }
        
    }
    
    // MARK: Camera Delegate
    func captureOutput(captureOutput: AVCaptureOutput!, didDropSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection: AVCaptureConnection!) {
    }
    
    func captureOutput(captureOutput: AVCaptureOutput, didOutputSampleBuffer sampleBuffer: CMSampleBufferRef, fromConnection connection: AVCaptureConnection) {

        dispatch_sync(dispatch_get_main_queue(), {
            var image:UIImage = self.imageFromSampleBuffer(sampleBuffer)!
            image = image.imageRotatedByDegrees(90, flip: false)
            // Add to data
            self.arrayOfImagesForLongExposure.addObject(image)
            // Preview
            self.imageViewPreviewLongExposure.image = self.createLongExposure(self.arrayOfImagesForLongExposure)
        })
        
        print("frame received")
    }
    
    func imageFromSampleBuffer(sampleBuffer:CMSampleBufferRef) -> UIImage? {
        let imageBuffer: CVImageBufferRef! = CMSampleBufferGetImageBuffer(sampleBuffer)
        
        CVPixelBufferLockBaseAddress(imageBuffer, 0)
        let baseAddress: UnsafeMutablePointer<Void> = CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0)
        
        let bytesPerRow: Int = CVPixelBufferGetBytesPerRow(imageBuffer)
        let width: Int = CVPixelBufferGetWidth(imageBuffer)
        let height: Int = CVPixelBufferGetHeight(imageBuffer)
        let colorSpace: CGColorSpaceRef! = CGColorSpaceCreateDeviceRGB()
        let bitsPerCompornent: Int = 8
        let bitmapInfo = CGBitmapInfo(rawValue: (CGBitmapInfo.ByteOrder32Little.rawValue | CGImageAlphaInfo.PremultipliedFirst.rawValue) as UInt32)
        let newContext: CGContextRef! = CGBitmapContextCreate(baseAddress, width, height, bitsPerCompornent, bytesPerRow, colorSpace, bitmapInfo.rawValue) as CGContextRef!
        let imageRef: CGImageRef! = CGBitmapContextCreateImage(newContext!)
        CVPixelBufferUnlockBaseAddress(imageBuffer, 0)
        let resultImage: UIImage = UIImage(CGImage: imageRef)
        return resultImage
    }
    
    func createLongExposure(images:NSMutableArray) -> UIImage? {
        
        let firstImg = images[0]
        let imgSize = firstImg.size
        let alpha:CGFloat = CGFloat(1.0 / Double(images.count))
        
        UIGraphicsBeginImageContext(imgSize);
        let context:CGContextRef = UIGraphicsGetCurrentContext()!;
        CGContextSetFillColorWithColor(context, UIColor.blackColor().CGColor);
        CGContextFillRect(context, CGRectMake(0, 0, imgSize.width, imgSize.height));
        
        for image in images {
            let rect = CGRect(x:0, y:0, width: imgSize.width, height:imgSize.height)
            image.drawInRect(rect, blendMode: .PlusLighter, alpha: alpha)
        }
        
        let longExpImg = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return longExpImg
    }
    
    // MARK: Apple watch delegate
    
    func onWatchButonPressAction(notification:NSNotification) {
        processPhoto()
    }

    
    // MARK: Collection View Delegates
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int  {
        return collectionView.tag == 1 ? arrayShutter.count :arrayISO.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell  {

        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CellShutter", forIndexPath: indexPath) as! ManualControllCollectionViewCell
        
        let posstion = indexPath.item
        let text = collectionView.tag == 1 ? getSringForCurrentShutterPossition(posstion) : getSringForCurrentISOPossition(posstion)
        cell.labelMain.text = text
        
        return cell
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        print("End Delecerating")
        
        let shutterIndexPath = DKCameraHelper.findCenterIndexForCollectionView(self.collectionViewShutter)
        let shutter = arrayShutter[shutterIndexPath.item]
        
        let isoIndexPath = DKCameraHelper.findCenterIndexForCollectionView(self.collectionViewISO)
        let iso = arrayISO[isoIndexPath.item]
        
        toggleAutoButtonON(false) // Off auto Mode
        
        ChangeShutterAndISOWithValues(shutter, withISO: iso)
    }
    
    func getSringForCurrentShutterPossition(shutterPosition:Int) -> String {
        return DKCameraHelper.convertFloatShutterToString(arrayShutter[shutterPosition])
    }
    
    func getSringForCurrentISOPossition(isoPossiton:Int) -> String {
        return String(format: "%.0f",arrayISO[isoPossiton])
    }
    
    
    // MARK: Navigation
    func moveToImageViewControllerWithImage(image: UIImage) {
        let controller:ImageViewController = storyboard?.instantiateViewControllerWithIdentifier("imageViewController") as! ImageViewController
        controller.image = DKCameraHelper.resizeImage(image, newWidth: 400)
        self.presentViewController(controller, animated: false,completion:{ () -> Void in
        })
    }
    
    // MARK: UI Updates
    func highlightTouchOnPoint(point:CGPoint, inView view:UIView) {
        
        // Create
        let imageView = UIImageView(image: UIImage(named: "Focus Point Indication"))
        imageView.frame = CGRectMake(point.x - 40, point.y - 40, 80, 80)
        imageView.alpha = 0;
        view.addSubview(imageView)
        view.bringSubviewToFront(imageView) // Just to be sure
        
        //Animate
        UIView.animateWithDuration(0.2, delay:0, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
            imageView.alpha = 1;
            }, completion: { (finished: Bool) -> Void in
               UIView.animateWithDuration(0.2, delay:0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
                imageView.alpha = 0;
                }, completion: { (finished: Bool) -> Void in
                    imageView.removeFromSuperview()
                })
        })
    }
    
    func toggleAutoButtonON(on:Bool) {
        self.buttonAutoISO.backgroundColor = on ? UIColor.greenColor() : UIColor.blueColor()
    }
}

