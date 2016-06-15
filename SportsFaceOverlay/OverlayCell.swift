//
//  OverlayCell.swift
//  SportsFaceOverlay
//
//  Created by Paulo Tam on 2/06/2016.
//  Copyright © 2016 Paulo Tam. All rights reserved.
//

class OverlayCell: UICollectionViewCell, OverlayCellType {
  
  @IBOutlet weak var titleLabel: UITextField!
  @IBOutlet weak var iconImage: UIImageView!
  
  var title: String? {
    didSet {
      titleLabel.text = title
    }
  }
  
  var icon: UIImage? {
    didSet {
      iconImage.image = icon
    }
  }
  
}

import UIKit
