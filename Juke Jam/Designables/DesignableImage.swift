//
//  DesignableImage.swift
//  Juke Jam
//
//  Created by Jeffrey Barros Peña on 7/18/18.
//  Copyright © 2018 Barros Peña. All rights reserved.
//

import UIKit

@IBDesignable class DesignableImage: UIImageView {
    // rounded corners
    @IBInspectable var cornerRadius: CGFloat = 0.0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
        }
    }
}
