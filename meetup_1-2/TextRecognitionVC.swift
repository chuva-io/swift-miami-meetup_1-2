//
//  TextRecognitionVC.swift
//  meetup_1-2
//
//  Created by Nilson Nascimento on 5/28/18.
//  Copyright © 2018 Nilson Nascimento. All rights reserved.
//

import UIKit
import AVFoundation
import Vision

class TextRecognitionVC: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    
    let captureSession = AVCaptureSession()
    var textDetectionRequest: VNDetectTextRectanglesRequest!
    lazy var cameraLayer: AVCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // session input
        let captureDevice = AVCaptureDevice.default(for: .video)!
        let input = try! AVCaptureDeviceInput(device: captureDevice)
        
        // session output
        captureSession.sessionPreset = .photo
        let output = AVCaptureVideoDataOutput()
        output.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
        output.setSampleBufferDelegate(self, queue: DispatchQueue.global())
        
        captureSession.addInput(input)
        captureSession.addOutput(output)
        
        let imageLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        imageLayer.frame = imageView.bounds
        imageView.layer.addSublayer(imageLayer)
        
        captureSession.startRunning()
        
        // text detection
        textDetectionRequest = VNDetectTextRectanglesRequest { request, error in
            DispatchQueue.main.async {
                self.imageView.layer.sublayers?.removeSubrange(1...) // clear results
                let results = request.results as? [VNTextObservation] ?? []
                self.highlightWords(textObservations: results)
            }
        }
        
        textDetectionRequest.reportCharacterBoxes = true
    }
    
    func highlightWords(textObservations: [VNTextObservation]) {
        for result in textObservations {
            let border = CALayer()
            border.borderWidth = 2.0
            border.borderColor = UIColor.red.cgColor
            border.frame = transformedFrame(frame: result.boundingBox)
            
            imageView.layer.addSublayer(border)
            
            highlightCharacters(textObservations: result.characterBoxes ?? [])
        }
    }
    
    func highlightCharacters(textObservations: [VNRectangleObservation]) {
        for result in textObservations {
            let border = CALayer()
            border.borderWidth = 1.0
            border.borderColor = UIColor.blue.cgColor
            border.frame = transformedFrame(frame: result.boundingBox)
            
            imageView.layer.addSublayer(border)
        }
    }
    
    func transformedFrame(frame: CGRect) -> CGRect {
        return CGRect(x: frame.minX * imageView.bounds.width,
                      y: (1 - frame.maxY) * imageView.bounds.height,
                      width: frame.width * imageView.bounds.width,
                      height: frame.height * imageView.bounds.height)
    }
    
}


extension TextRecognitionVC: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer,
                                            orientation: .right,
                                            options: [:])
        try? handler.perform([textDetectionRequest])
    }
    
}
