// instafilter assignment
// author - darlene.py@gmail.com
// October 23, 2015

import UIKit

//
// FilterRed.swift
//
public class FilterRed: FilterBase {
    override public init (intensity: Double = 10.0) {
        super.init()
        self.intensity = intensity
    }
    
    // Make the image a bit more reddish
    override public var filtername:String {
        return "Increase Redness Filter"
    }
    
    override public func run(rgbaImage: RGBAImage) -> RGBAImage {
        let averages = calculate_averages(rgbaImage)
        
        // apply a filter to each pixel of the image
        for y in 0..<rgbaImage.height {
            for x in 0..<rgbaImage.width {
                let index = y * rgbaImage.width + x
                var pixel = rgbaImage.pixels[index]
                
                let redDelta = Int(pixel.red) - averages.avgRed
                // increase the reds, don't modify blues and greens
                if (Int(pixel.red) > averages.avgRed) {
                    pixel.red = UInt8(max(min(255, (Double(averages.avgRed) + self.intensity * Double(redDelta))), 0))
                } else {
                    
                }
                rgbaImage.pixels[index] = pixel
            }
        }
        return rgbaImage
    }
}

