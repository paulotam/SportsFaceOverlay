//
//  MaskPreviewController
//  SportsFaceOverlay
//
//  Created by Paulo Tam on 30/05/2016.
//  Copyright © 2016 Paulo Tam. All rights reserved.
//

import UIKit
import AVFoundation

import GLKit
import CoreMedia

//add delegates
//need to conform it!
class LiveMaskController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  
  /*var captureSession : AVCaptureSession?
  var stillImageOutput : AVCaptureStillImageOutput?
  var previewLayer : AVCaptureVideoPreviewLayer?*/
  
  @IBOutlet weak var imageOverlay: UIImageView!
  @IBOutlet weak var cameraView: UIView!
  
  @IBOutlet weak var capturedImage: UIImageView!
  
  @IBOutlet weak var collectionView: UICollectionView!

  let eaglContext = EAGLContext(API: .OpenGLES2)
  let captureSession = AVCaptureSession()
  
  let imageView = GLKView()
  
  //let comicEffect = CIFilter(name: "CIComicEffect")!
  let eyeballImage = CIImage(image: UIImage(named: "eyeball.png")!)!
  
  var cameraImage: CIImage?
  
  lazy var ciContext: CIContext =
    {
      [unowned self] in
      
      return  CIContext(EAGLContext: self.eaglContext)
      }()
  
  lazy var detector: CIDetector =
    {
      [unowned self] in
      
      CIDetector(ofType: CIDetectorTypeFace,
                 context: self.ciContext,
                 options: [
                  CIDetectorAccuracy: CIDetectorAccuracyHigh,
                  CIDetectorTracking: true])
      }()
  
  private var overlays: [Overlay] = [
    Overlay( title: "Hawks", icon: UIImage(named: "Hawks")),
    Overlay( title: "Hawks", icon: UIImage(named: "Hawks")),
    Overlay( title: "Hawks", icon: UIImage(named: "Hawks")),
    Overlay( title: "Hawks", icon: UIImage(named: "Hawks"))]

  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    //reload the data in the colelction view.
    collectionView.reloadData()
    
    /*
    captureSession = AVCaptureSession()
    //captureSession?.sessionPreset = AVCaptureSessionPreset1920x1080
    
    var camera = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
    for cameraDevice in AVCaptureDevice.devices() {
      if cameraDevice.position == AVCaptureDevicePosition.Front {
        //todo: do this safely
        camera = cameraDevice as! AVCaptureDevice
        break
      }
    
    }
    //camera.position = AVCaptureDevicePosition.Front
    
    var error : NSError?
    var input: AVCaptureDeviceInput!
    do {
      input = try AVCaptureDeviceInput(device: camera)
    } catch let error1 as NSError {
      error = error1
      input = nil
    }
    
    if (error == nil && captureSession?.canAddInput(input) != nil){
      
      captureSession?.addInput(input)
      
      stillImageOutput = AVCaptureStillImageOutput()
      stillImageOutput?.outputSettings = [AVVideoCodecKey : AVVideoCodecJPEG]
      
      if (captureSession?.canAddOutput(stillImageOutput) != nil){
        captureSession?.addOutput(stillImageOutput)
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer?.videoGravity = AVLayerVideoGravityResizeAspect
        previewLayer?.connection.videoOrientation = AVCaptureVideoOrientation.Portrait
        cameraView.layer.addSublayer(previewLayer!)
        captureSession?.startRunning()
        
      }
      
      
    }
 */
    
    
  }

  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    initialiseCaptureSession()
    
    cameraView.addSubview(imageView)
    imageView.context = eaglContext
    imageView.delegate = self
   
    collectionView.dataSource = self
    collectionView.delegate = self
    collectionView.reloadData()
    
    
  }
  
  func initialiseCaptureSession()
  {
    captureSession.sessionPreset = AVCaptureSessionPresetPhoto
    
    guard let frontCamera = (AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo) as! [AVCaptureDevice])
      .filter({ $0.position == .Front })
      .first else
    {
      fatalError("Unable to access front camera")
    }
    
    do
    {
      let input = try AVCaptureDeviceInput(device: frontCamera)
      
      captureSession.addInput(input)
    }
    catch
    {
      fatalError("Unable to access front camera")
    }
    
    let videoOutput = AVCaptureVideoDataOutput()
    
    videoOutput.setSampleBufferDelegate(self, queue: dispatch_queue_create("sample buffer delegate", DISPATCH_QUEUE_SERIAL))
    if captureSession.canAddOutput(videoOutput)
    {
      captureSession.addOutput(videoOutput)
    }
    
    captureSession.startRunning()
  }
  
  /// Detects either the left or right eye from `cameraImage` and, if detected, composites
  /// `eyeballImage` over `backgroundImage`. If no eye is detected, simply returns the
  /// `backgroundImage`.
  func eyeImage(cameraImage: CIImage, backgroundImage: CIImage, leftEye: Bool) -> CIImage
  {
    let compositingFilter = CIFilter(name: "CISourceAtopCompositing")!
    let transformFilter = CIFilter(name: "CIAffineTransform")!
    
    let halfEyeWidth = eyeballImage.extent.width / 2
    let halfEyeHeight = eyeballImage.extent.height / 2
    
    if let features = detector.featuresInImage(cameraImage).first as? CIFaceFeature
      where leftEye ? features.hasLeftEyePosition : features.hasRightEyePosition
    {
      let eyePosition = CGAffineTransformMakeTranslation(
        leftEye ? features.leftEyePosition.x - halfEyeWidth : features.rightEyePosition.x - halfEyeWidth,
        leftEye ? features.leftEyePosition.y - halfEyeHeight : features.rightEyePosition.y - halfEyeHeight)
      
      transformFilter.setValue(eyeballImage, forKey: "inputImage")
      transformFilter.setValue(NSValue(CGAffineTransform: eyePosition), forKey: "inputTransform")
      let transformResult = transformFilter.valueForKey("outputImage") as! CIImage
      
      compositingFilter.setValue(backgroundImage, forKey: kCIInputBackgroundImageKey)
      compositingFilter.setValue(transformResult, forKey: kCIInputImageKey)
      
      return  compositingFilter.valueForKey("outputImage") as! CIImage
    }
    else
    {
      return backgroundImage
    }
  }
  
  override func viewDidLayoutSubviews()
  {
    imageView.frame = view.bounds
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    //previewLayer?.frame = cameraView.bounds
  }
  
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    //guard let overlays = overlays else { return 0 }
    return overlays.count
  }
  
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("overlayCellIdentifier", forIndexPath: indexPath)
    
    if var cell = cell as? OverlayCellType {
      cell.title = overlays[indexPath.row].title
      cell.icon = overlays[indexPath.row].icon
    }
    
    return cell
  }
  
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    // set the overlay to do something?
    imageOverlay.image = overlays[indexPath.row].icon
    
  }
  
  @IBAction func takePicture(sender: AnyObject) {
    // performSegueWithIdentifier("previewMaskSegue", sender: self)
    /*if let videoConnection = stillImageOutput!.connectionWithMediaType(AVMediaTypeVideo) {
      videoConnection.videoOrientation = AVCaptureVideoOrientation.Portrait
      stillImageOutput?.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler: {(sampleBuffer, error) in
        if (sampleBuffer != nil) {
          let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
          let dataProvider = CGDataProviderCreateWithCFData(imageData)
          let cgImageRef = CGImageCreateWithJPEGDataProvider(dataProvider, nil, true, CGColorRenderingIntent.RenderingIntentDefault)
          
          let image = UIImage(CGImage: cgImageRef!, scale: 1.0, orientation: UIImageOrientation.Right)
          self.capturedImage.image = image
        }
      })
    }*/
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
}


extension LiveMaskController: AVCaptureVideoDataOutputSampleBufferDelegate
{
  func captureOutput(captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection: AVCaptureConnection!)
  {
    connection.videoOrientation = AVCaptureVideoOrientation(rawValue: UIApplication.sharedApplication().statusBarOrientation.rawValue)!
    
    let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
    cameraImage = CIImage(CVPixelBuffer: pixelBuffer!)
    
    dispatch_async(dispatch_get_main_queue())
    {
      self.imageView.setNeedsDisplay()
    }
  }
}

extension LiveMaskController: GLKViewDelegate
{
  func glkView(view: GLKView, drawInRect rect: CGRect)
  {
    guard let cameraImage = cameraImage else
    {
      return
    }
    
    let leftEyeImage = eyeImage(cameraImage, backgroundImage: cameraImage, leftEye: true)
    let rightEyeImage = eyeImage(cameraImage, backgroundImage: leftEyeImage, leftEye: false)
    
    //comicEffect.setValue(rightEyeImage, forKey: kCIInputImageKey)
    
//    let outputImage = comicEffect.valueForKey(kCIOutputImageKey) as! CIImage
    let outputImage = rightEyeImage
    
    ciContext.drawImage(outputImage,
                        inRect: CGRect(x: 0, y: 0,
                          width: imageView.drawableWidth,
                          height: imageView.drawableHeight),
                        fromRect: outputImage.extent)
  }
}


