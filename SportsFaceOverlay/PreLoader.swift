//
//  preloader.swift
//  SportsFaceOverlay
//
//  Created by Paulo Tam on 30/05/2016.
//  Copyright © 2016 Paulo Tam. All rights reserved.
//

import UIKit

class PreLoader: UIViewController {

  var over18: Bool = false
  
  @IBOutlet weak var buttonText: UIButton!
  @IBOutlet weak var startButton: UIButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // alamo fire to download new images.
    
    // show downloading faces?
    
    // second thread
    // let imageData = NSData(contentsOfURL: NSURL(string: "http://...")!)!
    
    // back on main thread
    // UIImage(data: imageData)
    
    //lazy loading of images from alamofire
    
  }
  
  @IBAction func startButton(sender: AnyObject) {
    performSegueWithIdentifier("loadCameraSegue", sender: self)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

}