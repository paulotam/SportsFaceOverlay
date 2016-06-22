//
//  Overlay.swift
//  SportsFaceOverlay
//
//  Created by Paulo Tam on 2/06/2016.
//  Copyright © 2016 Paulo Tam. All rights reserved.
//

class Overlay {
  var title: String?
  var icon: UIImage?
  var mouth: UIImage?
  var leftEye: UIImage?
  var rightEye: UIImage?
  
  init(title: String?, icon: UIImage?, mouth: UIImage?, leftEye: UIImage?, rightEye: UIImage?) {
    self.title = title
    self.icon = icon
    self.mouth = mouth
    self.leftEye = leftEye
    self.rightEye = rightEye
  }
}

import UIKit

