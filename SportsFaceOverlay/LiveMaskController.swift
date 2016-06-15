//
//  MaskPreviewController
//  SportsFaceOverlay
//
//  Created by Paulo Tam on 30/05/2016.
//  Copyright © 2016 Paulo Tam. All rights reserved.
//

import UIKit
import AVFoundation

//add delegates
//need to conform it!
class LiveMaskController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  
  var captureSession : AVCaptureSession?
  var stillImageOutput : AVCaptureStillImageOutput?
  var previewLayer : AVCaptureVideoPreviewLayer?
  
  @IBOutlet weak var imageOverlay: UIImageView!
  @IBOutlet weak var cameraView: UIView!
  
  @IBOutlet weak var capturedImage: UIImageView!
  
  @IBOutlet weak var collectionView: UICollectionView!

  private var overlays: [Overlay] = [
    Overlay( title: "Hawks", icon: UIImage(named: "Hawks")),
    Overlay( title: "Hawks", icon: UIImage(named: "Hawks")),
    Overlay( title: "Hawks", icon: UIImage(named: "Hawks")),
    Overlay( title: "Hawks", icon: UIImage(named: "Hawks")),
    Overlay( title: "Hawks", icon: UIImage(named: "Hawks")),
    Overlay( title: "Hawks", icon: UIImage(named: "Hawks")),
    Overlay( title: "Hawks", icon: UIImage(named: "Hawks"))]

  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    //reload the data in the colelction view.
    collectionView.reloadData()
    
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
    
    
  }

  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    collectionView.dataSource = self
    collectionView.delegate = self
    collectionView.reloadData()
    
   
    
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    previewLayer?.frame = cameraView.bounds
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
    if let videoConnection = stillImageOutput!.connectionWithMediaType(AVMediaTypeVideo) {
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
    }
  }
  
  //image recognition
  
  // if there is a library for camera overlay??
  
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
}

