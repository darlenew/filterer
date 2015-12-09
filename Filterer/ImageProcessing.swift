// instafilter assignment
// author - darlene.py@gmail.com
// October 23, 2015

import UIKit

//
// ImageProcessing.swift
//
public class ImageProcessing {
    // Manage and apply Filter instances to an image
    var my_image_name: String // name of file containing image
    //var _pipeline: [FilterBase]
    var my_pipeline: Array<AnyObject> = []
    var filter_map = [ String: FilterBase ]()
    
    
    init(image_name: String, pipeline: Array<AnyObject>) {
        
        
        my_image_name = image_name
        my_pipeline = pipeline
        self.filter_map = [
            "B/W": FilterGrayscale(),
            "More Contrast": FilterIncreaseContrast(),
            "More Red": FilterRed(),
            "Black and White and Red All Over": FilterRedGrayscale(),
        ]

    }
    
    func run() -> RGBAImage {
        var rgbaImage = RGBAImage(image: UIImage(named: my_image_name)!)!
        var f: FilterBase = FilterBase()
        
        for filter in my_pipeline {
            if (filter is String) {
                if let obj = filter_map[filter as! NSCopying as! String] {
                    f = obj as! FilterBase
                } else {
                    // invalid filter
                }
            } else {
                f = filter as! FilterBase
            }
            print("\(f.filtername)")
            rgbaImage = f.run(rgbaImage)
        }
        
        return rgbaImage
    }
}


// Filter pipeline, can hold arbitrary number of filters
var filterpipeline: Array<AnyObject> = ["B/W",                   // Default B/W filter parameters, specified as String
                                        FilterRed(intensity: 6), // FilterRed formula with intensity of 6
                                        ]
var image_processing = ImageProcessing(image_name: "sample", pipeline: filterpipeline)
var rgbaImage: RGBAImage
rgbaImage = image_processing.run()
let newImage = rgbaImage.toUIImage()


















