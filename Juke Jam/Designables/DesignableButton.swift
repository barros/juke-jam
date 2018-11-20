//
//  DesignableButton.swift
//  Juke Jam
//
//  Created by Jeffrey Barros Peña on 6/4/18.
//  Copyright © 2018 Barros Peña. All rights reserved.
//

import UIKit

@IBDesignable class DesignableButton: UIButton {
    
  @IBInspectable var borderWidth: CGFloat = 0.0 {
    didSet {
      self.layer.borderWidth = borderWidth
    }
  }
  
  @IBInspectable var borderColor: UIColor = UIColor.clear {
    didSet {
      self.layer.borderColor = borderColor.cgColor
    }
  }
  
  // rounded corners
  @IBInspectable var cornerRadius: CGFloat = 0.0 {
    didSet {
      self.layer.cornerRadius = cornerRadius
    }
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesBegan(touches, with: event)
    self.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
    
    UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 6, options: .allowUserInteraction, animations: {
        self.transform = CGAffineTransform.identity
    }, completion: nil)
  }
    
}
