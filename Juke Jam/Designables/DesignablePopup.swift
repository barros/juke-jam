//
//  DesignablePopup.swift
//  Juke Jam
//
//  Created by Jeffrey Barros Peña on 7/17/18.
//  Copyright © 2018 Barros Peña. All rights reserved.
//

import UIKit

@IBDesignable class DesignablePopup: UIView {

    // rounded corners
    @IBInspectable var cornerRadius: CGFloat = 0.0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
        }
    }
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

}
