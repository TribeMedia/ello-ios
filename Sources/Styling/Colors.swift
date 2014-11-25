//
//  Colors.swift
//  Ello
//
//  Created by Sean Dougherty on 11/21/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import UIKit

extension UIColor {
    public class func tabBarGray() -> UIColor { return UIColor(hex:0xF2F2F2) }
    public class func elloDarkGray() -> UIColor { return UIColor(hex:0x333333) }
    public class func elloLightGray() -> UIColor { return UIColor(hex:0xA9A9A9) }
    public class func elloTextFieldGray() -> UIColor { return UIColor(hex:0xE4E4E4) }
}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")

        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }

    convenience init(hex:Int) {
        self.init(red:(hex >> 16) & 0xff, green:(hex >> 8) & 0xff, blue:hex & 0xff)
    }
}