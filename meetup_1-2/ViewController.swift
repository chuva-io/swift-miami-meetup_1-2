//
//  ViewController.swift
//  meetup_1-2
//
//  Created by Nilson Nascimento on 5/14/18.
//  Copyright © 2018 Nilson Nascimento. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UINavigationControllerDelegate {

    @IBOutlet weak var confidenceLabel: UILabel!
    @IBOutlet weak var classificationLabel: UILabel!
    @IBOutlet weak var selectedImage: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        confidenceLabel.text = ""
        classificationLabel.text = ""
    }
    
    @IBAction func clearButtonTapped(_ sender: UIBarButtonItem) {
        confidenceLabel.text = nil
        classificationLabel.text = nil
        selectedImage.image = nil
    }
    
    @IBAction func selectImageTapped(_ sender: UIBarButtonItem) {
        let sources: [UIImagePickerControllerSourceType] = [.photoLibrary,
                                                            .camera,
                                                            .savedPhotosAlbum]
        
        let mediaTypes = sources.map { UIImagePickerController.availableMediaTypes(for: $0) ?? [] }
            .reduce([]) { $0 + $1 }
        
        let vc = UIImagePickerController()
        vc.delegate = self
        vc.mediaTypes = mediaTypes
        present(vc, animated: true)
    }

} 

extension ViewController: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let image = info[UIImagePickerControllerOriginalImage]! as! UIImage
        selectedImage.image = image
        picker.dismiss(animated: true)
        
        let size = 299
        UIGraphicsBeginImageContextWithOptions(CGSize(width: size, height: size), true, 1.0)
        image.draw(in: CGRect(x: 0,
                              y: 0,
                              width: size,
                              height: size))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
                     kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault,
                                         Int(newImage.size.width),
                                         Int(newImage.size.height),
                                         kCVPixelFormatType_32ARGB,
                                         attrs,
                                         &pixelBuffer)
        
        guard (status == kCVReturnSuccess) else { return }
        
        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)
        
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: pixelData,
                                width: Int(newImage.size.width),
                                height: Int(newImage.size.height),
                                bitsPerComponent: 8,
                                bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!),
                                space: rgbColorSpace,
                                bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
        
        context?.translateBy(x: 0, y: newImage.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)
        
        UIGraphicsPushContext(context!)
        newImage.draw(in: CGRect(x: 0,
                                 y: 0,
                                 width: newImage.size.width,
                                 height: newImage.size.height))
        UIGraphicsPopContext()
        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        
        selectedImage.image = newImage
        
        let model = Inceptionv3()
        guard let prediction = try? model.prediction(image: pixelBuffer!) else { return }
        classificationLabel.text = prediction.classLabel
        let confidence = prediction.classLabelProbs[prediction.classLabel]!
        confidenceLabel.text = String(format: "%0.2f", confidence * 100) + " %"
        
    }
    
}
