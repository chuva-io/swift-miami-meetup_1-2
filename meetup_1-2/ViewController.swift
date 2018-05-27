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
        
    }
    
}
