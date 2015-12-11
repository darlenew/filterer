//
//  ViewController.swift
//  Filterer
//
//  Modified by darlene.py@gmail.com on Dec 9, 2015.
//  Created by Jack on 2015-09-22.
//  Copyright © 2015 UofT. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var filteredImage: UIImage?
    
    @IBOutlet var imageView: UIImageView!
    
    // main menu
    @IBOutlet var bottomMenu: UIView!
    @IBOutlet var filterButton: UIButton!
    @IBOutlet weak var compareButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    
    // secondary menu
    @IBOutlet var secondaryMenu: UIView!
    @IBOutlet weak var redFilterButton: UIButton!
    @IBOutlet weak var greenFilterButton: UIButton!
    @IBOutlet weak var blueFilterButton: UIButton!
    @IBOutlet weak var yellowFilterButton: UIButton!
    @IBOutlet weak var purpleFilterButton: UIButton!
    
    // save filtered images
    var originalImage: UIImage!
    var currentImage: UIImage! // might be the original or the filtered image
    
    override func viewDidLoad() {
        super.viewDidLoad()
        secondaryMenu.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.5)
        secondaryMenu.translatesAutoresizingMaskIntoConstraints = false
    }

    // from http://stackoverflow.com/questions/28906914/how-do-i-add-text-to-an-image-in-ios-swift
    func addTextToImage(drawText: NSString, inImage: UIImage, atPoint:CGPoint)->UIImage{
        
        // Setup the font specific variables
        var textColor: UIColor = UIColor.whiteColor()
        var textFont: UIFont = UIFont(name: "Helvetica Bold", size: 12)!
        
        //Setup the image context using the passed image.
        UIGraphicsBeginImageContext(inImage.size)
        
        //Setups up the font attributes that will be later used to dictate how the text should be drawn
        let textFontAttributes = [
            NSFontAttributeName: textFont,
            NSForegroundColorAttributeName: textColor,
        ]
        
        //Put the image into a rectangle as large as the original image.
        inImage.drawInRect(CGRectMake(0, 0, inImage.size.width, inImage.size.height))
        
        // Creating a point within the space that is as bit as the image.
        var rect: CGRect = CGRectMake(atPoint.x, atPoint.y, inImage.size.width, inImage.size.height)
        
        //Now Draw the text into an image.
        drawText.drawInRect(rect, withAttributes: textFontAttributes)
        
        // Create a new image out of the images we have created
        var newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        
        // End the context now that we have the image we need
        UIGraphicsEndImageContext()
        
        //And pass it back up to the caller.
        return newImage
        
    }
    
    // MARK: Share
    @IBAction func onShare(sender: AnyObject) {
        let activityController = UIActivityViewController(activityItems: ["Check out our really cool app", imageView.image!], applicationActivities: nil)
        presentViewController(activityController, animated: true, completion: nil)
    }
    
    // MARK: New Photo
    @IBAction func onNewPhoto(sender: AnyObject) {
        let actionSheet = UIAlertController(title: "New Photo", message: nil, preferredStyle: .ActionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .Default, handler: { action in
            self.showCamera()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Album", style: .Default, handler: { action in
            self.showAlbum()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        
        self.presentViewController(actionSheet, animated: true, completion: nil)
    }
    
    func showCamera() {
        let cameraPicker = UIImagePickerController()
        cameraPicker.delegate = self
        cameraPicker.sourceType = .Camera
        
        presentViewController(cameraPicker, animated: true, completion: nil)
    }
    
    func showAlbum() {
        let cameraPicker = UIImagePickerController()
        cameraPicker.delegate = self
        cameraPicker.sourceType = .PhotoLibrary
        
        presentViewController(cameraPicker, animated: true, completion: nil)
    }
    
    // MARK: UIImagePickerControllerDelegate
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        dismissViewControllerAnimated(true, completion: nil)
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.image = image // display the selected image
            originalImage = imageView.image // save the selected image for comparing against
            compareButton.enabled = false // disable comparisons until the image is filtered
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: Filter Menu
    @IBAction func onFilter(sender: UIButton) {
        if (sender.selected) {
            hideSecondaryMenu()
            sender.selected = false
        } else {
            // save the original image, if it hasn't been saved already
            // this may be the case when initially loading the app using the default image
            if originalImage == nil {
                originalImage = imageView.image!
            }
            showSecondaryMenu()
            sender.selected = true
        }
    }
    
    func showSecondaryMenu() {
        view.addSubview(secondaryMenu)
        
        let bottomConstraint = secondaryMenu.bottomAnchor.constraintEqualToAnchor(bottomMenu.topAnchor)
        let leftConstraint = secondaryMenu.leftAnchor.constraintEqualToAnchor(view.leftAnchor)
        let rightConstraint = secondaryMenu.rightAnchor.constraintEqualToAnchor(view.rightAnchor)
        
        let heightConstraint = secondaryMenu.heightAnchor.constraintEqualToConstant(44)
        
        NSLayoutConstraint.activateConstraints([bottomConstraint, leftConstraint, rightConstraint, heightConstraint])
        
        view.layoutIfNeeded()
        
        self.secondaryMenu.alpha = 0
        UIView.animateWithDuration(0.4) {
            self.secondaryMenu.alpha = 1.0
        }
    }

    func hideSecondaryMenu() {
        UIView.animateWithDuration(0.4, animations: {
            self.secondaryMenu.alpha = 0
            }) { completed in
                if completed == true {
                    self.secondaryMenu.removeFromSuperview()
                }
        }
    }
    
    func crossFadeToImage(image: UIImage) {
        // crossfade to this image
        // based on http://stackoverflow.com/questions/7638831/fade-dissolve-when-changing-uiimageviews-image
        UIView.transitionWithView(imageView,
            duration:1,
            options: UIViewAnimationOptions.TransitionCrossDissolve,
            animations: { self.imageView.image = image},
            completion: nil)
    }
    
    @IBAction func onFilterRed(sender: AnyObject) {
        // apply the red filter to the image
        let rgbaImage = RGBAImage(image: imageView.image!)
        let filter = FilterRed()
        let filtered: RGBAImage = filter.run(rgbaImage!)
        if let image = filtered.toUIImage() {
            crossFadeToImage(image)
            self.compareButton.enabled = true
            self.originalImage = addTextToImage("original", inImage: originalImage, atPoint: CGPointMake(20, 20))
        }
    }
    
    @IBAction func compareOriginal(sender: AnyObject) {
        // the compare button is being held down, peek at the original image
        print("compare to original")
        print(imageView.image)
        currentImage = imageView.image
        crossFadeToImage(originalImage)
        
    }

    @IBAction func compareFiltered(sender: AnyObject) {
        // the compare button was being held down, but is now let go, 
        // so revert to filtered image
        print("compare to filtered")
        crossFadeToImage(currentImage)
    }
    
}

