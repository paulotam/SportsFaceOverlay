//
//  PreviewMaskController
//  SportsFaceOverlay
//
//  Created by Paulo Tam on 30/05/2016.
//  Copyright © 2016 Paulo Tam. All rights reserved.
//

import UIKit

class PreviewMaskController: UIViewController {
  
  var imagePassed: UIImageView?
  
  @IBOutlet weak var imageView: UIImageView!
  
  let shareText:String = "I just created my Sports Face with Sportsbets SportsFace App #sportsbetcomau"
  
  @IBAction func backButton(sender: AnyObject) {
    self.performSegueWithIdentifier("unwindToLive", sender: self)
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    imageView.image = imagePassed!.image
    
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  

  @IBAction func shareButton(sender: AnyObject) {
    UIGraphicsBeginImageContext(imageView.frame.size)
    imageView.layer.renderInContext(UIGraphicsGetCurrentContext()!)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    let objectsToShare = [shareText, image]
    let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
    activityVC.popoverPresentationController?.sourceView = sender as? UIView
    self.presentViewController(activityVC, animated: true, completion: nil)
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    self.view.endEditing(true)
    return false
  }
  
}

