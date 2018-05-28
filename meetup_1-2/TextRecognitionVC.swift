//
//  TextRecognitionVC.swift
//  meetup_1-2
//
//  Created by Nilson Nascimento on 5/28/18.
//  Copyright © 2018 Nilson Nascimento. All rights reserved.
//

import UIKit
import AVFoundation

class TextRecognitionVC: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    
    let captureSession = AVCaptureSession()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // input
        let captureDevice = AVCaptureDevice.default(for: .video)!
        let input = try! AVCaptureDeviceInput(device: captureDevice)
        
        // output
        captureSession.sessionPreset = .photo
        let output = AVCaptureVideoDataOutput()
        output.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA] // kCVPixelFormatType_32RGBA
        output.setSampleBufferDelegate(self, queue: DispatchQueue.global())
        
        captureSession.addInput(input)
        captureSession.addOutput(output)
        
        let image = AVCaptureVideoPreviewLayer(session: captureSession)
        image.frame = imageView.bounds
        imageView.layer.addSublayer(image)
        
        captureSession.startRunning()
    }
    
}


extension TextRecognitionVC: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
    }
}
