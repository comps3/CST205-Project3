import UIKit
import AVFoundation
import MobileCoreServices

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    var newMedia = false
    var context: CIContext!
    var currentFilter: CIFilter!
    var originalImage: UIImage!
    
    override func viewDidLoad() {
        // Sets the header color to Black
        navigationController?.navigationBar.barTintColor = UIColor.blackColor()
        imageView.userInteractionEnabled = true
    }
    
    // MARK: - Enables Hardware Camera
    @IBAction func useCamera(sender: AnyObject) {
        
        // Checks if phone has a camera enabled
        if UIImagePickerController.isSourceTypeAvailable(
            UIImagePickerControllerSourceType.Camera) {
                // Initializes a UIImagePickerController
                let imagePicker = UIImagePickerController()
                
                imagePicker.delegate = self
                imagePicker.sourceType =
                    UIImagePickerControllerSourceType.Camera
                imagePicker.mediaTypes = [kUTTypeImage as NSString]
                imagePicker.allowsEditing = false
                // Present UIImagePickerController view onto view
                self.presentViewController(imagePicker, animated: true,
                    completion: nil)
                newMedia = true
        }
        
    }
    
    // MARK: - Enables usage of user's cameraroll
    @IBAction func useCameraRoll(sender: AnyObject) {
        
        if UIImagePickerController.isSourceTypeAvailable(
            UIImagePickerControllerSourceType.SavedPhotosAlbum) {
                // Initializes a UIImagePickerController
                let imagePicker = UIImagePickerController()
                
                imagePicker.delegate = self
                // Sets the source of the images to Camera Roll
                imagePicker.sourceType =
                    UIImagePickerControllerSourceType.PhotoLibrary
                imagePicker.mediaTypes = [kUTTypeImage as NSString]
                imagePicker.allowsEditing = false
                self.presentViewController(imagePicker, animated: true,
                    completion: nil)
                newMedia = true
        }
    }
    
    // MARK: - Filter Menu
    @IBAction func pickFilter(sender: AnyObject) {
        
        if newMedia {
            // When 'Filter' button is pressed, it presents a menu that allows the users to select a filter
            let ac = UIAlertController(title: "Choose filter", message: nil, preferredStyle: .ActionSheet)
            // List of filters
            // When a filter is choosen, it calls a function that determines which filter to apply
            ac.addAction(UIAlertAction(title: "Original", style: .Default, handler: applyFilter))
            ac.addAction(UIAlertAction(title: "Sobel", style: .Default, handler: applyFilter))
            ac.addAction(UIAlertAction(title: "Brighten", style: .Default, handler: applyFilter))
            ac.addAction(UIAlertAction(title: "Invert", style: .Default, handler: applyFilter))
            ac.addAction(UIAlertAction(title: "Green Red", style: .Default, handler: applyFilter))
            ac.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
            // Presents filter menu onscreen
            presentViewController(ac, animated: true, completion: nil)
            
        }
            
        else {
            // If a photo has not been taken, the app displays an alert to the user
            // asking for the user to take a photo before applying a filter
            let noPhoto = UIAlertController(title: "Alert", message: "Filter can not be applied without a photo", preferredStyle: .Alert)
            noPhoto.addAction(UIAlertAction(title: "Exit", style: .Cancel, handler: nil))
            presentViewController(noPhoto, animated: true, completion: nil)
        }
    }
    
    // MARK: - Save Filtered Photos
    @IBAction func saveFilteredPhoto(sender: AnyObject) {
        // An alert is displayed once the photo has been saved to the user's camera roll.
        let photoSavedNotification = UIAlertController(title: "Alert", message: "Photo has been saved", preferredStyle: .Alert)
            photoSavedNotification.addAction(UIAlertAction(title: "Exit", style: .Cancel, handler: nil))
            presentViewController(photoSavedNotification, animated: true, completion: nil)
        UIImageWriteToSavedPhotosAlbum(self.imageView.image, self, Selector("image:didFinishSavingWithError:contextInfo:"), nil)
    }
    
    // MARK: - Opens Share Sheet
    @IBAction func sharePhoto(sender: AnyObject) {
        // A menu pane is displayed when the user clicks 'Share' button
        // User is able to share one's creation on social media or AirDrop
        if newMedia {
            let activityItems = [UIActivityTypePostToFacebook, UIActivityTypePostToTwitter, UIActivityTypeMessage, UIActivityTypeMail, UIActivityTypeAirDrop]
            let convertImage: UIImage = self.imageView.image!
            let imageShared = [convertImage]
            let shareViewController = UIActivityViewController(activityItems: imageShared, applicationActivities: nil)
            shareViewController.excludedActivityTypes =  [UIActivityTypePrint]
            presentViewController(shareViewController, animated: true, completion: nil)
        }
        
    }
    
    
    // MARK: - Filter implementation hub; Lets user select which filter to apply
    func applyFilter(action: UIAlertAction!) {
        // Gets the name of the filter the user desires
        let filterRequested = action.title
        // Tranforms the original image to CIImage
        let startingImage = CIImage(image: originalImage)
        var finalImage = UIImage()
        // Control flow that determines which filter should be applied
        if filterRequested == "Original" {
            self.imageView.image = originalImage
            return
        }
        else if filterRequested == "Sobel" {
            let filter = SobelFilter()
            filter.inputImage = startingImage
            let outputImage = filter.outputImage
            finalImage = UIImage(CIImage: outputImage)!
        }
        else if filterRequested == "Brighten" {
            let filter = BrightenFilter()
            filter.inputImage = CIImage(image: originalImage)
            let outputImage = filter.outputImage
            finalImage = UIImage(CIImage: outputImage)!
        }
        else if filterRequested == "Invert" {
            let filter = InvertColorFilter()
            filter.inputImage = CIImage(image: originalImage)
            let outputImage = filter.outputImage
            finalImage = UIImage(CIImage: outputImage)!
        }
        else if filterRequested == "Green Red" {
            let filter = GreenRedFilter()
            filter.inputImage = CIImage(image: originalImage)
            let outputImage = filter.outputImage
            finalImage = UIImage(CIImage: outputImage)!
        }
        
        // Function call to 'imageWithImage' that corrects the aspect ratio
        // of the photo in order for it to properly fit on the user's screen
        self.imageView.image = imageWithImage(finalImage, scaledToWidth: 750)
        self.imageView.contentMode = UIViewContentMode.ScaleAspectFit        
    }
    
    // MARK: - Fix image aspect ratio (fit screen)
    func imageWithImage(image: UIImage, scaledToWidth: CGFloat) -> UIImage {
        var oldWidth: CGFloat = image.size.width
        var scaleFactor: CGFloat = scaledToWidth / oldWidth
        
        var newHeight = image.size.height * scaleFactor
        var newWidth = oldWidth * scaleFactor
        
        // Creates a new image that scales to the screen's height and width
        UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight))
        image.drawInRect(CGRect(x: 0,y: 0, width: newWidth, height: newHeight))
        var newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        var rotatedImage = UIImage(CGImage:newImage.CGImage, scale: 1.0, orientation: UIImageOrientation.Right)
        UIGraphicsEndImageContext()
        return rotatedImage!
    }
    
    
    // MARK: - Save Image from Camera Frame
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        
        let mediaType = info[UIImagePickerControllerMediaType] as! NSString
        
        // Pushes away the camera view controller once user finished
        // taking the photo
        self.dismissViewControllerAnimated(true, completion: nil)
        
        if mediaType.isEqualToString(kUTTypeImage as String) {
            let image = info[UIImagePickerControllerOriginalImage]
                as! UIImage
            
            // Save the image taken
            imageView.image = image
            originalImage = image
            
            if (newMedia == true) {
                //UIImageWriteToSavedPhotosAlbum(image, self,
                //    "image:didFinishSavingWithError:contextInfo:", nil)
            } else if mediaType.isEqualToString(kUTTypeMovie as String) {
                // Code to support video here
            }
        }
    }
    
    // MARK: - Error checking
    func image(image: UIImage, didFinishSavingWithError error: NSErrorPointer, contextInfo:UnsafePointer<Void>) {
        // In case if the app is unable to save the image
        if error != nil {
            let alert = UIAlertController(title: "Save Failed",
                message: "Failed to save image",
                preferredStyle: UIAlertControllerStyle.Alert)
            
            let cancelAction = UIAlertAction(title: "OK",
                style: .Cancel, handler: nil)
            
            alert.addAction(cancelAction)
            self.presentViewController(alert, animated: true,
                completion: nil)
        }
    }
    
    // MARK: -  Dismisses camera view if user hits cancel
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
