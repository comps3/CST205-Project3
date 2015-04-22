

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
        
    }
    
    // MARK: - Camera method
    
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
        ac.addAction(UIAlertAction(title: "Sobel", style: .Default, handler: setSobelFilter))
        ac.addAction(UIAlertAction(title: "Brighten", style: .Default, handler: setBrightenFilter))
        ac.addAction(UIAlertAction(title: "CIVignette", style: .Default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        presentViewController(ac, animated: true, completion: nil)
      }
        
    else {
        let noPhoto = UIAlertController(title: "Alert", message: "Filter can not be applied without a photo", preferredStyle: .ActionSheet)
        noPhoto.addAction(UIAlertAction(title: "Exit", style: .Cancel, handler: nil))
        presentViewController(noPhoto, animated: true, completion: nil)
        }
    }
    
    // MARK: - Save Filtered Photos
    
    @IBAction func saveFilteredPhoto(sender: AnyObject) {
        UIImageWriteToSavedPhotosAlbum(self.imageView.image, self, Selector("image:didFinishSavingWithError:contextInfo:"), nil)
    }
    
    
    func setFilter(action: UIAlertAction!) {
        
        let beginImage = CIImage(image: originalImage)
        context = CIContext(options: nil)
        currentFilter = CIFilter(name: action.title)
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        applyProcessing()
        
    }
    
    // MARK: - Custom Sobel Filter
    
    func setSobelFilter(action: UIAlertAction!) {
        let filter = SobelFilter()
        filter.inputImage = CIImage(image: originalImage)
        let outputImage = filter.outputImage
        let filteredImage = UIImage(CIImage: outputImage)!
        
        self.imageView.image = imageWithImage(filteredImage, scaledToWidth: 750)
        self.imageView.contentMode = UIViewContentMode.ScaleAspectFit
    }
    
    // MARK: - Custom Brighten Filter
    
    func setBrightenFilter(action: UIAlertAction!) {
        let filter = BrightenFilter()
        filter.inputImage = CIImage(image: originalImage)
        let outputImage = filter.outputImage
        let filteredImage = UIImage(CIImage: outputImage)!
        self.imageView.image = imageWithImage(filteredImage, scaledToWidth: 750)
        
    }
    
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

    
    func applyProcessing() {
        
        let inputKeys = currentFilter.inputKeys() as! [NSString]
        if contains(inputKeys, kCIInputIntensityKey) { currentFilter.setValue(1, forKey: kCIInputIntensityKey) }
        if contains(inputKeys, kCIInputRadiusKey) { currentFilter.setValue(200, forKey: kCIInputRadiusKey) }
        if contains(inputKeys, kCIInputScaleKey) { currentFilter.setValue(10, forKey: kCIInputScaleKey) }
        if contains(inputKeys, kCIInputCenterKey) { currentFilter.setValue(CIVector(x: imageView.image!.size.width / 2, y: imageView.image!.size.height / 2), forKey: kCIInputCenterKey) }
        
        let cgimg = context.createCGImage(currentFilter.outputImage, fromRect: currentFilter.outputImage.extent())
        let processedImage = UIImage(CGImage: cgimg, scale: 1.0, orientation: UIImageOrientation.Right)
        
        self.imageView.image = processedImage
    }
    
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        
        let mediaType = info[UIImagePickerControllerMediaType] as! NSString
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
        if mediaType.isEqualToString(kUTTypeImage as String) {
            let image = info[UIImagePickerControllerOriginalImage]
                as! UIImage
            
            imageView.image = image
            originalImage = image
            
            if (newMedia == true) {
                UIImageWriteToSavedPhotosAlbum(image, self,
                    "image:didFinishSavingWithError:contextInfo:", nil)
            } else if mediaType.isEqualToString(kUTTypeMovie as String) {
                // Code to support video here
            }
        }
    }
    
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
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}