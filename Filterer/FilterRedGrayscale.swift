// instafilter assignment
// author - darlene.py@gmail.com
// October 23, 2015

import UIKit

//
// FilterRedGrayscale
//
public class FilterRedGrayscale: FilterBase {
    override public init (intensity: Double = 2.0) {
        super.init()
        self.intensity = intensity
    }
    
    // Make the image grayscale, except for reds, make them redder
    override public var filtername: String {
        return "Red-Grayscale Filter"
    }
    
    override public func run(rgbaImage: RGBAImage) -> RGBAImage {
        let averages = calculate_averages(rgbaImage)
        
        // apply a filter to each pixel of the image
        for y in 0..<rgbaImage.height {
            for x in 0..<rgbaImage.width {
                let index = y * rgbaImage.width + x
                var pixel = rgbaImage.pixels[index]
                //let redDelta = Int(pixel.red) - averages.avgRed
                let greenDelta = Int(pixel.green) - averages.avgGreen
                let blueDelta = Int(pixel.blue) - averages.avgBlue
                
                // coefficients obtained from:
                // http://stackoverflow.com/questions/687261/converting-rgb-to-grayscale-intensity
                let red = 0.2126 * Double(pixel.red)
                let green = 0.5870 * Double(pixel.green)
                let blue = 0.1140 * Double(pixel.blue)
                let l = red + green + blue
                
                if (Int(pixel.red) > 190) {
                    pixel.red = UInt8(max(min(255, Double(pixel.red) * self.intensity), 0))
                    pixel.green = UInt8(max(min(255, Double(averages.avgGreen) - self.intensity * self.intensity * Double(greenDelta)), 0))
                    pixel.blue = UInt8(max(min(255, Double(averages.avgBlue) - self.intensity * self.intensity * Double(blueDelta)), 0))
                    
                    
                } else {
                    pixel.red = UInt8(l)
                    pixel.green = UInt8(l)
                    pixel.blue = UInt8(l)
                }
                rgbaImage.pixels[index] = pixel
            }
        }
        return rgbaImage
    }
}

