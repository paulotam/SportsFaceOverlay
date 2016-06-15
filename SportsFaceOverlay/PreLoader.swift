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
    
    // view.layer.sublayers![0]
    // Do any additional setup after loading the view, typically from a nib.
    
    // Show preloader?
    
    // alamo fire to download.
    
    // show downloading faces and odds?
    
    // Once it has loaded push to next screen via perform segue
    
    // place a segue on the view controller that will then call the next view controller.
       
  }
  
  
  @IBAction func ageButton(sender: AnyObject) {
    over18 = !over18
    if over18 == true {
      buttonText.setTitle("Yes", forState: UIControlState.Normal)
    } else {
      buttonText.setTitle("No", forState: UIControlState.Normal)
    }
  }
  
  
  @IBAction func startButton(sender: AnyObject) {
    performSegueWithIdentifier("loadCameraSegue", sender: self)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

}