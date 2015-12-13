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
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var compareButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    
    // secondary menu
    @IBOutlet var secondaryMenu: UIView!
    @IBOutlet weak var redFilterButton: UIButton!
    @IBOutlet weak var greenFilterButton: UIButton!
    @IBOutlet weak var blueFilterButton: UIButton!
    @IBOutlet weak var yellowFilterButton: UIButton!
    var secondaryMenuConstraints = [NSLayoutConstraint]()
    
    // slider menu
    @IBOutlet var sliderMenu: UIView!
    @IBOutlet weak var intensitySlider: UISlider!
    var sliderMenuConstraints = [NSLayoutConstraint]()
    
    // save filtered images
    var originalImage: UIImage!
    var currentImage: UIImage! // might be the original or the filtered image
    var filterName: String!
    var filterMap = ["B/W": FilterGrayscale.self,
                      "Contrast": FilterIncreaseContrast.self,
                      "Red": FilterRed.self,
                      "RedGrayscale": FilterRedGrayscale.self,
                     ]
    
    // overlay view
    var overlay: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        secondaryMenu.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.5)
        secondaryMenu.translatesAutoresizingMaskIntoConstraints = false
        sliderMenu.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.5)
        sliderMenu.translatesAutoresizingMaskIntoConstraints = false

        // set up imageView to recognize long presses
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: "overlayLongPressed:")
        imageView.userInteractionEnabled = false
        
        // set up overlay view to limit the gesture recognizing region
        // direct math on CGFloats is kinda screwy
        // http://stackoverflow.com/questions/18422389/unexpected-result-when-subtracting-two-floats-defined-as-constants
        overlay = UIView(frame: CGRectMake(0, 0, self.imageView.frame.size.width, CGFloat(self.view.frame.size.height - 88)))
        overlay.userInteractionEnabled = true
        overlay.opaque = false
        overlay.backgroundColor = UIColor(white:1, alpha: 0)
        overlay.addGestureRecognizer(longPressRecognizer)
        self.view.addSubview(overlay)
        
        print(filterButton.state)
    }

    // from http://stackoverflow.com/questions/28906914/how-do-i-add-text-to-an-image-in-ios-swift
    func addTextToImage(drawText: NSString, inImage: UIImage, atPoint:CGPoint)->UIImage{
        
        // Setup the font specific variables
        var textColor: UIColor = UIColor.whiteColor()
        var textFont: UIFont = UIFont(name: "Helvetica Bold", size: 24)!
        
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
    
    func setupNewImage(image: UIImage) {
        // got a new image to filter, update state
        print("updating state")
        hideSecondaryMenu()
        hideSliderMenu()

        imageView.image = image // display the selected image
        self.originalImage = image // save the selected image for comparing against
        // disable comparisons and edits until image is filtered
        compareButton.enabled = false
        editButton.enabled = false
    }
    
    // MARK: UIImagePickerControllerDelegate
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        dismissViewControllerAnimated(true, completion: nil)
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            setupNewImage(image)
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: Filter Menu
    @IBAction func onFilter(sender: UIButton) {
        print(sender)
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
    
    //
    // secondary menu
    //
    
    func showSecondaryMenu() {
        print(filterButton.state)
        print(filterButton)
        hideSliderMenu()
        view.addSubview(secondaryMenu)
        
        let bottomConstraint = secondaryMenu.bottomAnchor.constraintEqualToAnchor(bottomMenu.topAnchor)
        let leftConstraint = secondaryMenu.leftAnchor.constraintEqualToAnchor(view.leftAnchor)
        let rightConstraint = secondaryMenu.rightAnchor.constraintEqualToAnchor(view.rightAnchor)
        
        let heightConstraint = secondaryMenu.heightAnchor.constraintEqualToConstant(44)
        
        secondaryMenuConstraints = [bottomConstraint, leftConstraint, rightConstraint, heightConstraint]
        NSLayoutConstraint.activateConstraints(secondaryMenuConstraints)
        

        
        self.secondaryMenu.alpha = 0
        UIView.animateWithDuration(0.4) {
            self.secondaryMenu.alpha = 1.0
        }
        
        view.layoutIfNeeded()
    }

    func hideSecondaryMenu() {
        print(filterButton.state)
        print(filterButton)
        print("hide secondary")
        if !self.secondaryMenu.isDescendantOfView(view) {
            return
        }

        UIView.animateWithDuration(0.4, animations: {
            self.secondaryMenu.alpha = 0
            }) { completed in
                if completed == true {
                    self.secondaryMenu.removeFromSuperview()
                }
        }
        //NSLayoutConstraint.deactivateConstraints(secondaryMenuConstraints)
    }
    
    //
    // slider menu
    //
    
    func showSliderMenu() {
        // show slider menu for editing the filter parameter
        hideSecondaryMenu()
        print(filterButton.state)
        print(filterButton)
        print("show slider")
        view.addSubview(sliderMenu)
        
        
        let bottomConstraint = sliderMenu.bottomAnchor.constraintEqualToAnchor(bottomMenu.topAnchor)
        print(bottomConstraint)
        let leftConstraint = sliderMenu.leftAnchor.constraintEqualToAnchor(view.leftAnchor)
        print(leftConstraint)
        let rightConstraint = sliderMenu.rightAnchor.constraintEqualToAnchor(view.rightAnchor)
        print(rightConstraint)
        
        let heightConstraint = sliderMenu.heightAnchor.constraintEqualToConstant(44)
        print(heightConstraint)
        
        sliderMenuConstraints = [bottomConstraint, leftConstraint, rightConstraint, heightConstraint]
        NSLayoutConstraint.activateConstraints(sliderMenuConstraints)
        

        view.layoutIfNeeded()
        
        self.sliderMenu.alpha = 0
        UIView.animateWithDuration(0.4) {
            self.sliderMenu.alpha = 1.0
        }

        print(intensitySlider.frame)
    }
    
    func hideSliderMenu() {
        // hide slider menu
        print(filterButton.state)
        print(filterButton)
        print("hide slider")
        NSLayoutConstraint.deactivateConstraints(sliderMenuConstraints)
        UIView.animateWithDuration(0.4, animations: {
            self.sliderMenu.alpha = 0
            }) { completed in
                if completed == true {
                    self.sliderMenu.removeFromSuperview()
                }
        }
    }
    
    @IBAction func onSliderTouchUpInside(sender: AnyObject) {
        let intensity = self.intensitySlider.value
        var filter: FilterBase
        switch filterName {
            case "B/W":
                filter = FilterGrayscale(intensity: Double(intensity))
            case "Contrast":
                filter = FilterIncreaseContrast(intensity: Double(intensity))
            case "Red":
                filter = FilterRed(intensity: Double(intensity))
            case "RedGrayscale":
                filter = FilterRedGrayscale(intensity: Double(intensity))
            default:
                filter = FilterGrayscale(intensity: Double(intensity))
        }
        applyFilter(filter, image: originalImage)
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

    func onFilterComplete() {
        // image filtering completed
        self.compareButton.enabled = true
        self.editButton.enabled = true
    }
    
    func applyFilter(filter: FilterBase, image: UIImage) {
        // apply the filter
        if let rgbaImage = RGBAImage(image: image) {
            let filtered = filter.run(rgbaImage)
            if let image = filtered.toUIImage() {
                crossFadeToImage(image)
                onFilterComplete()
            }
        }
    }
    
    @IBAction func onFilterRed(sender: AnyObject) {
        // apply the red filter to the image
        filterName = "Red"
        let filter = FilterRed(intensity: 12.0)
        applyFilter(filter, image: originalImage)
    }
    
    @IBAction func onFilterRedGrayscale(sender: AnyObject) {
        filterName = "RedGrayscale"
        let filter = FilterRedGrayscale(intensity: 12.0)
        applyFilter(filter, image: originalImage)
    }
    
    @IBAction func onFilterIncreaseContrast(sender: AnyObject) {
        filterName = "Contrast"
        let filter = FilterIncreaseContrast(intensity: 12.0)
        applyFilter(filter, image: originalImage)
    }
    
    @IBAction func onFilterGrayscale(sender: AnyObject) {
        filterName = "B/W"
        let filter = FilterGrayscale(intensity: 12.0)
        applyFilter(filter, image: originalImage)
    }
    
    @IBAction func onEdit(sender: AnyObject) {
        // edit button pressed
        hideSecondaryMenu()
        showSliderMenu()
    }
    
    //
    // compare
    // 
    
    func doStartCompare() {
        // compare to original image, if one exists
        if let original = originalImage {
            currentImage = imageView.image
            // add a "original" label to the image before displaying
            let labeledImage = addTextToImage("original", inImage: original, atPoint: CGPointMake(20, 20))
            crossFadeToImage(labeledImage)
        }
    }
    
    func doEndCompare() {
        // comparison is done.  if there was an original image, 
        // revert to the current image.
        if let _ = originalImage {
            crossFadeToImage(currentImage)
        }
    }
    
    @IBAction func compareOriginal(sender: AnyObject) {
        // the compare button is being held down, peek at the original image
        doStartCompare()
    }

    @IBAction func compareFiltered(sender: AnyObject) {
        // the compare button was being held down, but is now let go, 
        // so revert to filtered image
        doEndCompare()
    }
    
    func overlayLongPressed(longPress: UIGestureRecognizer) {
        if (longPress.state == UIGestureRecognizerState.Ended) {
            doEndCompare()
        }else if (longPress.state == UIGestureRecognizerState.Began) {
            doStartCompare()
        }
    }
}

