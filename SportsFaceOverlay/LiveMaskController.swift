//
//  LiveMaskController
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
  
  //Setup IBOutlets
  @IBOutlet weak var imageOverlay: UIImageView!
  @IBOutlet weak var cameraView: UIView!
  @IBOutlet weak var capturedImage: UIImageView!
  @IBOutlet weak var collectionView: UICollectionView!

  //variables
  let eaglContext = EAGLContext(API: .OpenGLES2)
  let captureSession = AVCaptureSession()
  let imageView = GLKView()
  
  //setup default eyes and nose
  var eyeballImage = CIImage(image: UIImage(named: "hawks-left-eye")!)!
  var eyeRightImage = CIImage(image: UIImage(named: "hawks-right-eye")!)!
  var noseImage = CIImage(image: UIImage(named: "hawks-mouth")!)!
  
  var cameraImage: CIImage?
  var outputImage: CIImage?
  
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
  
  //setup data for Collection Views
  private var overlays: [Overlay] = [
    Overlay( title: "Hawks", icon: UIImage(named: "hawks-icon"), mouth: UIImage(named: "hawks-mouth"), leftEye: UIImage(named: "hawks-left-eye"), rightEye: UIImage(named: "hawks-right-eye")),
    Overlay( title: "Lions", icon: UIImage(named: "lions-icon"), mouth: UIImage(named: "lions-mouth"), leftEye: UIImage(named: "eyeball"), rightEye: UIImage(named: "eyeball")),
    Overlay( title: "Cats", icon: UIImage(named: "cats-icon"), mouth: UIImage(named: "hawks-mouth"), leftEye: UIImage(named: "hawks-left-eye"), rightEye: UIImage(named: "hawks-right-eye")),
    Overlay( title: "Tigers", icon: UIImage(named: "tigers-icon"), mouth: UIImage(named: "lions-mouth"), leftEye: UIImage(named: "eyeball"), rightEye: UIImage(named: "eyeball"))]

  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    //reload the data in the collection view.
    collectionView.reloadData()
    imageView.contentMode = .ScaleAspectFit
    
    //If its not running, run it
    if (captureSession.running == false) {
      captureSession.startRunning()
    }
  }

  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    //about to disappear, lets stop running.
    if (captureSession.running == true) {
      captureSession.stopRunning()
    }
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
  
  //Function to capture session.
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
  
  // Code to detect the left Eye position and put image into it.
  func eyeImage(cameraImage: CIImage, backgroundImage: CIImage) -> CIImage
  {
    let compositingFilter = CIFilter(name: "CISourceAtopCompositing")!
    let transformFilter = CIFilter(name: "CIAffineTransform")!
    
    let halfEyeWidth = eyeballImage.extent.width / 2
    let halfEyeHeight = eyeballImage.extent.height / 2
    
    if let features = detector.featuresInImage(cameraImage).first as? CIFaceFeature
      where features.hasLeftEyePosition
      {
      let eyePosition = CGAffineTransformMakeTranslation(
        features.leftEyePosition.x - halfEyeWidth,
        features.leftEyePosition.y - halfEyeHeight)
      
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
  
  // Code to detect the right Eye position and put image into it.
  func eyeRightImage(cameraImage: CIImage, backgroundImage: CIImage) -> CIImage
  {
    let compositingFilter = CIFilter(name: "CISourceAtopCompositing")!
    let transformFilter = CIFilter(name: "CIAffineTransform")!
    
    let halfEyeWidth = eyeRightImage.extent.width / 2
    let halfEyeHeight = eyeRightImage.extent.height / 2
    
    if let features = detector.featuresInImage(cameraImage).first as? CIFaceFeature
      where features.hasRightEyePosition
    {
      let eyePosition = CGAffineTransformMakeTranslation(
        features.rightEyePosition.x - halfEyeWidth,
        features.rightEyePosition.y - halfEyeHeight)
      
      transformFilter.setValue(eyeRightImage, forKey: "inputImage")
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
  
  // Code to detect the nose position and put image into it.
  func noseImage(cameraImage: CIImage, backgroundImage: CIImage) -> CIImage
  {
    let compositingFilter = CIFilter(name: "CISourceAtopCompositing")!
    let transformFilter = CIFilter(name: "CIAffineTransform")!
    
    let halfNoseWidth = noseImage.extent.width / 2
    let halfNoseHeight = noseImage.extent.height / 2
    
    if let features = detector.featuresInImage(cameraImage).first as? CIFaceFeature
      where features.hasMouthPosition
    {
      let nosePosition = CGAffineTransformMakeTranslation(
        features.mouthPosition.x - halfNoseWidth,
        features.mouthPosition.y - halfNoseHeight)
      
      transformFilter.setValue(noseImage, forKey: "inputImage")
      transformFilter.setValue(NSValue(CGAffineTransform: nosePosition), forKey: "inputTransform")
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
  }
  
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
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
  
  // On select of the item in collection view, set the images that get put onto face.
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    noseImage = CIImage(image: overlays[indexPath.row].mouth!)!
    eyeballImage = CIImage(image: overlays[indexPath.row].leftEye!)!
    eyeRightImage = CIImage(image: overlays[indexPath.row].rightEye!)!
  }
  
  //IBAction to take picture.
  @IBAction func takePicture(sender: AnyObject) {
    
    let image = UIImage(CIImage: outputImage!)
    capturedImage.image = image
    performSegueWithIdentifier("previewMaskSegue", sender: self)
    
  }
  
  //IBAction unwind
  @IBAction func unwindToLive(segue: UIStoryboardSegue) {
    
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if let pmVC = segue.destinationViewController as? PreviewMaskController {
      pmVC.imagePassed = capturedImage
      
    }
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
    
    let leftEyeImage = eyeImage(cameraImage, backgroundImage: cameraImage)
    let rightEyeImage = eyeRightImage(cameraImage, backgroundImage: leftEyeImage)
    let noseResult = noseImage(cameraImage, backgroundImage: rightEyeImage)
    
    //let outputImage = noseResult as CIImage
    outputImage = noseResult
    
    ciContext.drawImage(outputImage!,
      inRect: CGRect(x: 0, y: 0,
        width: imageView.drawableWidth,
        height: imageView.drawableHeight),
      fromRect: outputImage!.extent)
  }
}


