//
//  PreviewMaskController
//  SportsFaceOverlay
//
//  Created by Paulo Tam on 30/05/2016.
//  Copyright © 2016 Paulo Tam. All rights reserved.
//

import UIKit

class PreviewMaskController: UIViewController, UITextFieldDelegate {
  
  var imagePassed: UIImageView?
  
  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var shareText: UITextField!
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    imageView.image = imagePassed!.image
    
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.shareText.delegate = self;
  }
  

  @IBAction func shareButton(sender: AnyObject) {
    // TODO: share code
    let objectsToShare = [shareText.text!, imageView.image! as UIImage]
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

