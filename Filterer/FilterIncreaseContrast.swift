// instafilter assignment
// author - darlene.py@gmail.com
// October 23, 2015

import UIKit

//
// FilterIncreaseContrast.swift
//
public class FilterIncreaseContrast: FilterBase {
    override public init (intensity: Double = 10.0) {
        super.init()
        self.intensity = intensity
    }
    
    // Make darks really dark, make lights slightly lighter
    override public var filtername:String {
        return "Increase Contrast By 10 Filter"
    }
    
    override public func run(rgbaImage: RGBAImage) -> RGBAImage {
        let averages = calculate_averages(rgbaImage)
        
        // apply a filter to each pixel of the image
        for y in 0..<rgbaImage.height {
            for x in 0..<rgbaImage.width {
                let index = y * rgbaImage.width + x
                var pixel = rgbaImage.pixels[index]
                
                let redDelta = Int(pixel.red) - averages.avgRed
                let greenDelta = Int(pixel.green) - averages.avgGreen
                let blueDelta = Int(pixel.blue) - averages.avgBlue
                
                let redVal: Double = Double(averages.avgRed) + self.intensity * Double(redDelta)
                let greenVal: Double = Double(averages.avgGreen) + self.intensity + Double(greenDelta)
                let blueVal: Double = Double(averages.avgBlue) + self.intensity + Double(blueDelta)
                pixel.red = UInt8(max(min(255, redVal), 0))
                pixel.green = UInt8(max(min(255, greenVal), 0))
                pixel.blue = UInt8(max(min(255, blueVal), 0))
                
                rgbaImage.pixels[index] = pixel
            }
        }
        return rgbaImage
    }
}
