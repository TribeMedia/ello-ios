////
///  ImageRegionSpec.swift
//

import Foundation
import Ello
import Quick
import Nimble

class ImageRegionSpec: QuickSpec {
    override func spec() {

        describe("+fromJSON:") {

            it("parses image region correctly") {
                let data = stubbedJSONData("image-region", "region")
                let region = ImageRegion.fromJSON(data) as! ImageRegion

                expect(region.url!.absoluteString) == "https://example.com/test.jpg"
                expect(region.alt) == "region-alt.jpeg"

                let asset = region.asset!

                expect(asset.id) == "85"

                let hdpi = asset.hdpi!

                expect(hdpi.url.absoluteString) == "https://example.com/85/hdpi.jpg"
                expect(hdpi.size) == 77464
                expect(hdpi.type) == "image/jpeg"
                expect(hdpi.width) == 750
                expect(hdpi.height) == 321

                let xhdpi = asset.xhdpi!
                expect(xhdpi.url.absoluteString) == "https://example.com/85/xhdpi.jpg"
                expect(xhdpi.size) == 274363
                expect(xhdpi.type) == "image/jpeg"
                expect(xhdpi.width) == 1500
                expect(xhdpi.height) == 641
            }

            it("parses buy-button region correctly") {
                let data = stubbedJSONData("buy-button-image-region", "region")
                let region = ImageRegion.fromJSON(data) as! ImageRegion

                expect(region.url!.absoluteString) == "https://example.com/test.jpg"
                expect(region.buyButtonURL!.absoluteString) == "https://amazon.com"
                expect(region.alt) == "region-alt.jpeg"

                let asset = region.asset!

                expect(asset.id) == "85"

                let hdpi = asset.hdpi!

                expect(hdpi.url.absoluteString) == "https://example.com/85/hdpi.jpg"
                expect(hdpi.size) == 77464
                expect(hdpi.type) == "image/jpeg"
                expect(hdpi.width) == 750
                expect(hdpi.height) == 321

                let xhdpi = asset.xhdpi!
                expect(xhdpi.url.absoluteString) == "https://example.com/85/xhdpi.jpg"
                expect(xhdpi.size) == 274363
                expect(xhdpi.type) == "image/jpeg"
                expect(xhdpi.width) == 1500
                expect(xhdpi.height) == 641
            }

        }

        context("NSCoding") {

            var filePath = ""
            if let url = NSURL(string: NSFileManager.ElloDocumentsDir()) {
                filePath = url.URLByAppendingPathComponent("ImageRegionSpec").absoluteString
            }

            afterEach {
                do {
                    try NSFileManager.defaultManager().removeItemAtPath(filePath)
                }
                catch {

                }
            }

            context("encoding") {

                it("encodes successfully") {
                    let region: ImageRegion = stub([:])

                    let wasSuccessfulArchived = NSKeyedArchiver.archiveRootObject(region, toFile: filePath)

                    expect(wasSuccessfulArchived).to(beTrue())
                }
            }

            context("decoding") {

                it("decodes successfully") {
                    let hdpi: Attachment = stub([
                        "url" : NSURL(string: "http://www.example.com")!,
                        "height" : 2,
                        "width" : 5,
                        "type" : "jpeg",
                        "size" : 45644
                    ])

                    let xxhdpi: Attachment = stub([
                        "url" : NSURL(string: "http://www.example2.com")!,
                        "height" : 67,
                        "width" : 999,
                        "type" : "png",
                        "size" : 114574
                    ])

                    let asset: Asset = stub([
                        "id" : "qwerty",
                        "hdpi" : hdpi,
                        "xxhdpi" : xxhdpi
                    ])

                    let imageRegion: ImageRegion = stub([
                        "asset" : asset,
                        "alt" : "some-altness",
                        "url" : NSURL(string: "http://www.example5.com")!
                    ])

                    NSKeyedArchiver.archiveRootObject(imageRegion, toFile: filePath)
                    let unArchivedRegion = NSKeyedUnarchiver.unarchiveObjectWithFile(filePath) as! ImageRegion

                    expect(unArchivedRegion).toNot(beNil())
                    expect(unArchivedRegion.version) == 1

                    expect(unArchivedRegion.url!.absoluteString) == "http://www.example5.com"
                    expect(unArchivedRegion.alt) == "some-altness"

                    let unArchivedAsset = unArchivedRegion.asset!

                    expect(unArchivedAsset.id) == "qwerty"

                    let unArchivedHdpi = unArchivedAsset.hdpi!

                    expect(unArchivedHdpi.url.absoluteString) == "http://www.example.com"
                    expect(unArchivedHdpi.size) == 45644
                    expect(unArchivedHdpi.type) == "jpeg"
                    expect(unArchivedHdpi.width) == 5
                    expect(unArchivedHdpi.height) == 2

                    let unArchivedXxhdpi = unArchivedAsset.xxhdpi!

                    expect(unArchivedXxhdpi.url.absoluteString) == "http://www.example2.com"
                    expect(unArchivedXxhdpi.size) == 114574
                    expect(unArchivedXxhdpi.type) == "png"
                    expect(unArchivedXxhdpi.width) == 999
                    expect(unArchivedXxhdpi.height) == 67
                }
            }
        }
    }
}
