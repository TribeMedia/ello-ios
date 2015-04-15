//
//  Asset.swift
//  Ello
//
//  Created by Sean on 2/11/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation
import SwiftyJSON

let AssetVersion = 1

public final class Asset: JSONAble {

    public let version: Int = AssetVersion
    public let assetId: String
    var isGif: Bool {
        return self.optimized?.imageType == "image/gif"
    }

    public let optimized: ImageAttachment?
    public let smallScreen: ImageAttachment?
    public let ldpi: ImageAttachment?
    public let mdpi: ImageAttachment?
    public let hdpi: ImageAttachment?
    public let xhdpi: ImageAttachment?
    public let xxhdpi: ImageAttachment?
    public let xxxhdpi: ImageAttachment?

// MARK: Initialization
    
    public init(assetId: String,
        optimized: ImageAttachment?,
        smallScreen: ImageAttachment?,
        ldpi: ImageAttachment?,
        mdpi: ImageAttachment?,
        hdpi: ImageAttachment?,
        xhdpi: ImageAttachment?,
        xxhdpi: ImageAttachment?,
        xxxhdpi: ImageAttachment?) {
            self.assetId = assetId
            self.optimized = optimized
            self.smallScreen = smallScreen
            self.ldpi = ldpi
            self.mdpi = mdpi
            self.hdpi = hdpi
            self.xhdpi = xhdpi
            self.xxhdpi = xxhdpi
            self.xxxhdpi = xxxhdpi
            super.init()
    }

// MARK: NSCoding

    public required init(coder aDecoder: NSCoder) {
        let decoder = Decoder(aDecoder)
        self.assetId = decoder.decodeKey("assetId")
        self.optimized = decoder.decodeOptionalKey("optimized")
        self.smallScreen = decoder.decodeOptionalKey("smallScreen")
        self.ldpi = decoder.decodeOptionalKey("ldpi")
        self.mdpi = decoder.decodeOptionalKey("mdpi")
        self.hdpi = decoder.decodeOptionalKey("hdpi")
        self.xhdpi = decoder.decodeOptionalKey("xhdpi")
        self.xxhdpi = decoder.decodeOptionalKey("xxhdpi")
        self.xxxhdpi = decoder.decodeOptionalKey("xxxhdpi")
        super.init(coder: aDecoder)
    }

    public override func encodeWithCoder(encoder: NSCoder) {

        encoder.encodeObject(self.assetId, forKey: "assetId")
                    
        if let optimized = self.optimized {
            encoder.encodeObject(optimized, forKey: "optimized")
        }

        if let smallScreen = self.smallScreen {
            encoder.encodeObject(smallScreen, forKey: "smallScreen")
        }

        if let ldpi = self.ldpi {
            encoder.encodeObject(ldpi, forKey: "ldpi")
        }

        if let mdpi = self.mdpi {
            encoder.encodeObject(mdpi, forKey: "mdpi")
        }

        if let hdpi = self.hdpi {
            encoder.encodeObject(hdpi, forKey: "hdpi")
        }

        if let xhdpi = self.xhdpi {
            encoder.encodeObject(xhdpi, forKey: "xhdpi")
        }

        if let xxhdpi = self.xxhdpi {
            encoder.encodeObject(xxhdpi, forKey: "xxhdpi")
        }

        if let xxxhdpi = self.xxxhdpi {
            encoder.encodeObject(xxxhdpi, forKey: "xxxhdpi")
        }
        super.encodeWithCoder(encoder)
    }
    
// MARK: JSONAble

    override class public func fromJSON(data:[String: AnyObject]) -> JSONAble {
        let json = JSON(data)
        let assetId = data["id"] as? String ?? ""
        let attachment = data["attachment"] as? [String:AnyObject]
        let optimized = Asset.createImageAttachment("optimized", attachment: attachment)
        let smallScreen = Asset.createImageAttachment("small_screen", attachment: attachment)
        let ldpi = Asset.createImageAttachment("ldpi", attachment: attachment)
        let mdpi = Asset.createImageAttachment("mdpi", attachment: attachment)
        let hdpi = Asset.createImageAttachment("hdpi", attachment: attachment)
        let xhdpi = Asset.createImageAttachment("xhdpi", attachment: attachment)
        let xxhdpi = Asset.createImageAttachment("xxhdpi", attachment: attachment)
        let xxxhdpi = Asset.createImageAttachment("xxxhdpi", attachment: attachment)

        return Asset(
            assetId: assetId,
            optimized: optimized,
            smallScreen: smallScreen,
            ldpi: ldpi,
            mdpi: mdpi,
            hdpi: hdpi,
            xhdpi: xhdpi,
            xxhdpi: xxhdpi,
            xxxhdpi: xxxhdpi
        )
    }

// MARK: Private

    private class func createImageAttachment(sizeKey:String, attachment:[String: AnyObject]?) -> ImageAttachment? {

        if let attachment = attachment {
            if let size = attachment[sizeKey] as? [String:AnyObject] {
                var uri = size["url"] as! String
                if uri.hasPrefix("//") {
                    uri = "https:" + uri
                }
                return ImageAttachment(
                    url: NSURL(string: uri),
                    height: size["metadata"]?["height"] as? Int,
                    width: size["metadata"]?["width"] as? Int,
                    imageType: size["metadata"]?["type"] as? String,
                    size: size["metadata"]?["size"] as? Int
                )
            }
        }
        
        return nil
    }
}
