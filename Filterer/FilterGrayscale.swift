// instafilter assignment
// author - darlene.py@gmail.com
// October 23, 2015

import UIKit

//
// FilterGrayscale.swift
//
public class FilterGrayscale: FilterBase {
    
    // Make the image grayscale
    override public var filtername: String {
        return "Grayscale Filter"
    }
    
    override public func run(rgbaImage: RGBAImage) -> RGBAImage {
        // apply a filter to each pixel of the image
        for y in 0..<rgbaImage.height {
            for x in 0..<rgbaImage.width {
                let index = y * rgbaImage.width + x
                var pixel = rgbaImage.pixels[index]
                
                // coefficients obtained from:
                // http://stackoverflow.com/questions/687261/converting-rgb-to-grayscale-intensity
                let red = 0.2126 * self.intensity * Double(pixel.red)
                let green = 0.5870 * self.intensity * Double(pixel.green)
                let blue = 0.1140 * self.intensity * Double(pixel.blue)
                let l = red + green + blue
                
                pixel.red = UInt8(l)
                pixel.green = UInt8(l)
                pixel.blue = UInt8(l)
                rgbaImage.pixels[index] = pixel
            }
        }
        return rgbaImage
    }
}
