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
        navigationController?.navigationBar.barTintColor = UIColor.blackColor()
        imageView.userInteractionEnabled = true
        //imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "imageEditorSegue:"))
    }
    
    // MARK: - Enables Hardware Camera
    @IBAction func useCamera(sender: AnyObject) {
        
        if UIImagePickerController.isSourceTypeAvailable(
            UIImagePickerControllerSourceType.Camera) {
                
                let imagePicker = UIImagePickerController()
                
                imagePicker.delegate = self
                imagePicker.sourceType =
                    UIImagePickerControllerSourceType.Camera
                imagePicker.mediaTypes = [kUTTypeImage as NSString]
                imagePicker.allowsEditing = false
                
                self.presentViewController(imagePicker, animated: true,
                    completion: nil)
                newMedia = true
        }
        
    }
    
    // MARK: - Enables usage of User's Camera
    @IBAction func useCameraRoll(sender: AnyObject) {
        
        if UIImagePickerController.isSourceTypeAvailable(
            UIImagePickerControllerSourceType.SavedPhotosAlbum) {
                let imagePicker = UIImagePickerController()
                
                imagePicker.delegate = self
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
            
            let ac = UIAlertController(title: "Choose filter", message: nil, preferredStyle: .ActionSheet)
            
            ac.addAction(UIAlertAction(title: "Original", style: .Default, handler: applyFilter))
            ac.addAction(UIAlertAction(title: "Sobel", style: .Default, handler: applyFilter))
            ac.addAction(UIAlertAction(title: "Brighten", style: .Default, handler: applyFilter))
            ac.addAction(UIAlertAction(title: "Invert", style: .Default, handler: applyFilter))
            ac.addAction(UIAlertAction(title: "Green Red", style: .Default, handler: applyFilter))
            ac.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
            
            presentViewController(ac, animated: true, completion: nil)
            
        }
            
        else {
            let noPhoto = UIAlertController(title: "Alert", message: "Filter can not be applied without a photo", preferredStyle: .Alert)
            noPhoto.addAction(UIAlertAction(title: "Exit", style: .Cancel, handler: nil))
            presentViewController(noPhoto, animated: true, completion: nil)
        }
    }
    
    // MARK: - Save Filtered Photos
    @IBAction func saveFilteredPhoto(sender: AnyObject) {
        let photoSavedNotification = UIAlertController(title: "Alert", message: "Photo has been saved", preferredStyle: .Alert)
            photoSavedNotification.addAction(UIAlertAction(title: "Exit", style: .Cancel, handler: nil))
            presentViewController(photoSavedNotification, animated: true, completion: nil)
        UIImageWriteToSavedPhotosAlbum(self.imageView.image, self, Selector("image:didFinishSavingWithError:contextInfo:"), nil)
    }
    
    // MARK: - Opens Share Sheet
    @IBAction func sharePhoto(sender: AnyObject) {
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
        
        let filterRequested = action.title
        let startingImage = CIImage(image: originalImage)
        var finalImage = UIImage()
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
        
        self.imageView.image = imageWithImage(finalImage, scaledToWidth: 750)
        self.imageView.contentMode = UIViewContentMode.ScaleAspectFit        
    }
    
    // MARK: - Fix image aspect ratio (fit screen)
    func imageWithImage(image: UIImage, scaledToWidth: CGFloat) -> UIImage {
        var oldWidth: CGFloat = image.size.width
        var scaleFactor: CGFloat = scaledToWidth / oldWidth
        
        var newHeight = image.size.height * scaleFactor
        var newWidth = oldWidth * scaleFactor
        
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
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
        if mediaType.isEqualToString(kUTTypeImage as String) {
            let image = info[UIImagePickerControllerOriginalImage]
                as! UIImage
            
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
