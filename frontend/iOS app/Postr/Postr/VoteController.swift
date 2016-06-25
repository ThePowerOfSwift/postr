//
//  VoteController.swift
//  Postr
//
//  Created by Steven Kingaby on 07/06/2016.
//  Copyright © 2016 Steven Kingaby. All rights reserved.
//

import AVFoundation
import UIKit
import Alamofire
import JSSAlertView

class VoteController: UIViewController {
    @IBAction func cancelToVoteController(segue:UIStoryboardSegue) {
    }
    
    var event : Event?

    // Poster Image Capture variables
    let captureSession = AVCaptureSession()
    let stillImageOutput = AVCaptureStillImageOutput()
    var captureDevice : AVCaptureDevice?
    var previewLayer : AVCaptureVideoPreviewLayer?
    var cameraPreview: UIView!
    
    // Crop view variables
    var cropX : CGFloat!
    var cropY : CGFloat!
    var cropWidth : CGFloat!
    var cropHeight : CGFloat!
    var cropView : UIView!
    
    let zoomChange = CGFloat(0.001)
    var isZoom : Bool?
    var baseLoc : CGPoint?
    
    let postrColor = UIColor(red:1.00, green:0.60, blue:0.00, alpha:1.0)
    let httpNetworking = HTTPNetworking()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set base crop values
        cropX = 9
        cropY = 288
        cropWidth = 356
        cropHeight = 91
        
        let devices = AVCaptureDevice.devices()
 
        // Find back camera amongst phone's devices
        for device in devices {
            if (device.hasMediaType(AVMediaTypeVideo) &&
                device.position == AVCaptureDevicePosition.Back) {
                captureDevice = device as? AVCaptureDevice
                configureCameraSession(captureDevice!)
            }
        }
    }
    
    /////////////////////////////////////////////  Capture Session Functions  ////////////////////////////////////////////////
    
    
    // Set up camera session for poster image capture
    func configureCameraSession(captureDevice: AVCaptureDevice) {
        // Set focus settings for camera session
        configureDevice()
    
        var input : AVCaptureDeviceInput? = nil;
        
        // Get reference to camera device
        do {
            input = try AVCaptureDeviceInput(device: captureDevice)
        } catch _ {
            print("Error in getting reference to camera device")
        }

        captureSession.addInput(input)
        captureSession.sessionPreset = AVCaptureSessionPreset1920x1080
        captureSession.startRunning()
        stillImageOutput.outputSettings = [AVVideoCodecKey:AVVideoCodecJPEG]
        
        
        if captureSession.canAddOutput(stillImageOutput) {
            captureSession.addOutput(stillImageOutput)
        }
        
        if let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession) {
            // Get image (video) preview layer to be 
            // displayed on screen 
            self.previewLayer = previewLayer
            previewLayer.bounds = view.bounds
            previewLayer.position = CGPointMake(view.bounds.midX, view.bounds.midY)
            previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
            cameraPreview = UIView(frame: CGRectMake(0.0, 0.0, view.bounds.size.width, view.bounds.size.height))
            cameraPreview.layer.addSublayer(previewLayer)
            cameraPreview.layer.zPosition = 1
            
            // Add buttons, zoom icons, and crop views
            setUpButtonView(cameraPreview)
            setUpZoomViews(cameraPreview)
            setUpCropView(cameraPreview)

            view.addSubview(cameraPreview)
        }
    }
    
    // Set focus mode for camera session
    func configureDevice() {
        if let device = captureDevice {
            do {
                try device.lockForConfiguration()
                device.focusMode = .Locked
                device.unlockForConfiguration()
            } catch {
                print("Error in configureDevice()")
                return
            }
        }
    }

    
    /////////////////////////////////////////////  View Setup Functions  ////////////////////////////////////////////////
    
    func setUpCropView(cameraPreview: UIView) {
        cropView = CropView(frame: CGRectMake(cropX, cropY, cropWidth, cropHeight))
        cameraPreview.addSubview(cropView)
    }
    
    func setUpButtonView(cameraPreview: UIView) {
        let buttonView = ButtonView(frame: CGRectMake(123, 585, 129, 62))
            buttonView.userInteractionEnabled = true
            buttonView.button.userInteractionEnabled = true
            buttonView.button.addTarget(self, action: #selector(VoteController.uploadImage(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        cameraPreview.addSubview(buttonView)
    }
    
    func setUpZoomViews(cameraPreview: UIView) {
           let zoomInView = ZoomView(frame: CGRectMake(320, 84, 35, 35), zoomIn: true)
            zoomInView.userInteractionEnabled = true
            zoomInView.button.userInteractionEnabled = true
            zoomInView.button.addTarget(self, action: #selector(VoteController.zoomInStart(_:)), forControlEvents: UIControlEvents.TouchDown)
            zoomInView.button.addTarget(self, action: #selector(VoteController.zoomEnd(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            
            
            let zoomOutView = ZoomView(frame: CGRectMake(320, 127, 35, 35), zoomIn: false)
            zoomOutView.userInteractionEnabled = true
            zoomOutView.button.userInteractionEnabled = true
            zoomOutView.button.addTarget(self, action: #selector(VoteController.zoomOutStart(_:)), forControlEvents: UIControlEvents.TouchDown)
            zoomOutView.button.addTarget(self, action: #selector(VoteController.zoomEnd(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
            cameraPreview.addSubview(zoomInView)
            cameraPreview.addSubview(zoomOutView)
    }
    
    
    ////////////////////////////////////////////////  Camera Zoom  Functions  ///////////////////////////////////////////////////

    func zoomInStart(sender: AnyObject!) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            if let device = self.captureDevice {
                do {
                    try device.lockForConfiguration()
                    
                    self.isZoom = true
                    while (device.videoZoomFactor < device.activeFormat.videoMaxZoomFactor - self.zoomChange &&
                           self.isZoom!) {
                        device.videoZoomFactor += self.zoomChange
                    }
                    
                    device.unlockForConfiguration()
                } catch {
                    print("Error in zoomInStart()")
                    return
                }
            }
        })
    }
    
    func zoomOutStart(sender: AnyObject!) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            if let device = self.captureDevice {
                do {
                    try device.lockForConfiguration()
                    
                    self.isZoom = true
                    while (device.videoZoomFactor > 1 + self.zoomChange && self.isZoom!) {
                        device.videoZoomFactor -= self.zoomChange
                    }
                    
                    device.unlockForConfiguration()
                } catch {
                    print("Error in zoomOutStart()")
                    return
                }
            }
        })
    }
    
        
    func zoomEnd(sender: AnyObject!) {
        isZoom = false
    }
    
    /////////////////////////////////////////////  Image Upload Functions  ////////////////////////////////////////////////
    
    func uploadImage(sender: AnyObject!){
        httpNetworking.startActivityIndicator(self.cameraPreview)
        if let videoConnection = stillImageOutput.connectionWithMediaType(AVMediaTypeVideo) {
            stillImageOutput.captureStillImageAsynchronouslyFromConnection(videoConnection) {
                (imageDataSampleBuffer, error) -> Void in
                    let image : UIImage = self.getImageFromSampleBuffer(imageDataSampleBuffer)
                    let path = "/events/\(self.event!.event_id)/findPoster"
                    let url = HTTPNetworking.postrURL + path
                    let jwtToken = HTTPNetworking.JWT
                
                    let headers = ["Authorization" : "Bearer \(jwtToken)"]
                

                    Alamofire.upload(.POST, url, headers: headers, multipartFormData: { multipartFormData in
                            if let imageData = UIImageJPEGRepresentation(image, 1) {
                                multipartFormData.appendBodyPart(data: imageData, name: "file", fileName: "fileName.jpg", mimeType: "image/jpeg")
                            }
                            }, encodingCompletion: { encodingResult in
                                
                                switch encodingResult {
                                    case .Success(let upload, _, _):
                                        upload.responseJSON { response in
                                            self.processResponse(response)
                                        }
                                    case .Failure(let encodingError):
                                        // Handle error
                                        print(encodingError)
                                    }
                    })

            }
        }
    }

    func processResponse(response: Response<AnyObject, NSError>) {
        switch response.result {
            case .Success:
                if let JSON = response.result.value {
                    let responseDict = JSON as! NSDictionary
                    if (response.response?.statusCode == 200) {
                        presentPoster((responseDict["posters"] as! NSArray), index: 0)
                    } else {
                        userMessage(responseDict["msg"] as! String)
                    }
                }
            
                self.httpNetworking.stopActivityIndicator(self.cameraPreview)
                
            case .Failure(let error):
                // Handle error
                print(error)
        }
    }
    
    func presentPoster(posters: NSArray, index: Int) {
        // Base case for recursion
        // No more posters available to present to user
        if (index >= posters.count) {
            userMessage("Vote Again!")
            return
        }
    
        // Get poster and title
        let poster = posters[index]
        let posterTitle = poster[1]["title"] as! String

        func castVote() {
            voteForPoster(poster[1]["poster_id"] as! Int)
        }
        
        func presentOtherPosters() {
            presentPoster(posters, index: index + 1)
        }
        
        // Query user
        let alertView = JSSAlertView().show(
          self,
          title: "Did you vote for:",
          text: posterTitle,
          buttonText: "Yes",
          cancelButtonText: "No",
          color: postrColor
        )
        
        alertView.addAction(castVote)
        alertView.addCancelAction(presentOtherPosters)
        alertView.setTitleFont("coolvetica")
        alertView.setTextFont("coolvetica")
        alertView.setButtonFont("coolvetica")
        alertView.setTextTheme(.Light)
    }
    
    func voteForPoster(poster_id: Int) {
        httpNetworking.startActivityIndicator(self.cameraPreview)
        
        let url = HTTPNetworking.postrURL + "/events/\(event!.event_id)/posters/\(poster_id)/upvote"
        
        let jwtToken = HTTPNetworking.JWT
        
        let headers = ["Authorization" : "Bearer \(jwtToken)"]
        let parameters = ["username": "\(HTTPNetworking.username)"]
        
        
        Alamofire.request(.POST,  url, headers: headers, parameters: parameters).responseJSON { response in
            self.httpNetworking.stopActivityIndicator(self.cameraPreview)
            switch response.result {
                case .Success:
                    if let JSON = response.result.value {
                        let voteDict = JSON as! NSDictionary
                        self.userMessage(voteDict["msg"] as! String)
                    }
                
                case .Failure(let error):
                    print(error)
                }
            }
        }

    // Present user with message
    func userMessage(msg: String) {
        let alertView = JSSAlertView().show(
            self,
            title: msg,
            noButtons: true,
            color: postrColor,
            delay: 4
        )

        alertView.setTitleFont("coolvetica")
        alertView.setTextTheme(.Light)
    }

    
    // Form image from a image data
    func getImageFromSampleBuffer(sampleBuffer:  CMSampleBuffer) -> UIImage {
        // Set image format as JPEG
        let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
        let dataProvider = CGDataProviderCreateWithCFData(imageData)
        let cgImageRef = CGImageCreateWithJPEGDataProvider(dataProvider, nil, true, CGColorRenderingIntent.RenderingIntentDefault)
        
        // Create UIImage object from capture data
        let image = UIImage(CGImage: cgImageRef!, scale: 1.0, orientation: UIImageOrientation.Right)

        // Calculate ratio between UIImage dimensions and Screen dimensions
        let heightRatio = Float(image.size.height) / Float(self.view.frame.height)
        
        // Calculate position and size values for cropped image
        let height = CGFloat(heightRatio) * cropHeight!
        let y = CGFloat(heightRatio) * cropY!

        // Crop entire width of screen, even if it's outside of visible crop view on app.
        // "image" object initially rotated 90 degrees anti-clockwise, 
        // therefore swap x and y values, width and height values,
        // when passing them in as parameters for image crop.
        let imageRef: CGImage = CGImageCreateWithImageInRect(image.CGImage, CGRectMake(y, 0, height, image.size.width))!
        let result: UIImage = UIImage(CGImage: imageRef, scale: 1.0, orientation: UIImageOrientation.Right)
        
        return result
    }
    

    /////////////////////////////////////////////  Crop View Manipulation Functions  ////////////////////////////////////////////////

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        // set baseLoc to location of touch
        baseLoc = touches.first?.locationInView(self.view)
    
        // Set focus point
        if let device = captureDevice {
            do {
                try device.lockForConfiguration()
                let viewPoint = touches.first?.locationInView(self.view)
                let focusPoint = CGPoint(x: viewPoint!.x, y: viewPoint!.y)
                device.focusPointOfInterest = focusPoint
                device.focusMode = AVCaptureFocusMode.ContinuousAutoFocus
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
    }

    // Track user touches and change crop view size
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        // Get location of screen touch
        let firstTouch = touches.first
        let newLoc = firstTouch?.locationInView(self.view)
        
    
        if (withinCropBounds(newLoc!) && withinCropBounds(baseLoc!)) {
            let yDist = newLoc!.y - baseLoc!.y
        
            if(withinTopHalf(newLoc!) && withinTopHalf(baseLoc!)) {
                cropY! += yDist
                cropHeight! -= yDist
            } else if (!withinTopHalf(newLoc!) && !withinTopHalf(baseLoc!)) {
                cropHeight! += yDist
            }
            
            self.cropView.frame = CGRectMake(cropX, cropY, cropWidth, cropHeight)
            cropView.setNeedsDisplay()
            
        }
        
        // Update baseLoc for later comparisons
        baseLoc = newLoc
    }
    
    
    // Check to see if given point is within top half of crop view
    func withinTopHalf(location: CGPoint) -> Bool {
        return location.y <= (cropY + (cropHeight / 2))
    }
    
    
    // Check to see if given point is within crop view bounds
    func withinCropBounds(location: CGPoint) -> Bool {
        return cropX < location.x && location.x < cropX + cropWidth &&
               cropY < location.y && location.y < cropY + cropHeight
    }
    
    
    
    
    
    
    override func prepareForSegue(segue: (UIStoryboardSegue!), sender: AnyObject!) {
        if (segue.identifier == "seguePosters") {
            let navController = segue!.destinationViewController as! UINavigationController
            let postersController = navController.topViewController as! PostersController;
            postersController.event = event
        }
    }
}
