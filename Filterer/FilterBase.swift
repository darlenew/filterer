// instafilter assignment
// author - darlene.py@gmail.com
// October 23, 2015

import UIKit

//
// FilterBase.swift
//
public class FilterBase {
    var intensity: Double = 0.0
    
    public init (intensity: Double = 1.0) {
        self.intensity = intensity
    }
    
    // Image filter base class
    public var filtername: String {
        return "Filter"
    }
    
    public func calculate_averages(rgbaImage: RGBAImage) -> (avgRed: Int, avgGreen: Int, avgBlue: Int) {
        // Each pixel is made up of a red, green, and blue value.
        // Return the average red value across all pixels, the average green, and average blue.
        // The average red value is the sum of all red values, divided by the total number of pixels.  And so on for the other colors.
        var totalRed = 0
        var totalGreen = 0
        var totalBlue = 0
        for y in 0..<rgbaImage.height {
            for x in 0..<rgbaImage.width{
                let index = y * rgbaImage.width + x
                let pixel = rgbaImage.pixels[index]
                
                totalRed += Int(pixel.red)
                totalGreen += Int(pixel.green)
                totalBlue += Int(pixel.blue)
            }
        }
        
        let pixelCount = rgbaImage.width * rgbaImage.height
        let avgRed = totalRed / pixelCount
        let avgGreen = totalGreen / pixelCount
        let avgBlue = totalBlue / pixelCount
        
        return (avgRed, avgGreen, avgBlue) // TODO cache these values
    }
    
    public func run(rgbaImage: RGBAImage) -> RGBAImage{
        // override this in the subclass
        return rgbaImage
    }
}
