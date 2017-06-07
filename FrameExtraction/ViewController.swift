//
//  ViewController.swift
//  Created by Bobo on 29/12/2016.
//

import UIKit
import CoreML

class ViewController: UIViewController, FrameExtractorDelegate {
    
    let newImageSize:CGFloat = 224.0
    let newHeight:CGFloat = newImageSize
    let newWidth:CGFloat = newImageSize
    
    var frameExtractor: FrameExtractor!
    let model = Resnet50()
    
    var prediction:Resnet50Output?
    var predictionReady = false
    var flag = 0
    
    var maxProb:Double = 0.0
    var labelWithMaxProb = "0"
    
    
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var resultProbLabel: UILabel!
    /*@IBAction func flipButton(_ sender: UIButton) {
        frameExtractor.flipCamera()
    }*/
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        frameExtractor = FrameExtractor()
        frameExtractor.delegate = self
        
    }
    
    func captured(image: UIImage) {
        
        
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        self.imageView.image = newImage
        
        DispatchQueue.global(qos: .userInitiated).async {
            
            let ciImage = CIImage (image: newImage!)
            let context = CIContext(options: nil)
            let cgImage = context.createCGImage(ciImage!, from: ciImage!.extent)
            
            let newImageBuffer = self.newPixelBufferFrom(cgImage: cgImage!)
            
            if self.flag == 9 {
                guard let prediction = try? self.model.prediction(image: newImageBuffer!) else {
                    fatalError("Unexpected runtime error.")
                }
                let dict = prediction.classLabelProbs
                for (key, value) in dict {
                    if value == dict.values.max() {
                        self.maxProb = value
                        self.labelWithMaxProb = key
                        break;
                    }
                }
                
                // self.prediction = prediction
                self.predictionReady = true
                
                self.flag = 0
            } else {
                self.flag = self.flag + 1
            }
            
            //self.resultProbLabel.text = (self.prediction?.classLabelProbs)!
            
            
        }
        
        if predictionReady {
            self.resultLabel.text = labelWithMaxProb
            self.resultProbLabel.text = String(format:"%.4f /%", maxProb)
        }
        
    }
    
    func newPixelBufferFrom(cgImage:CGImage) -> CVPixelBuffer?{
        let options:[String: Any] = [kCVPixelBufferCGImageCompatibilityKey as String: true, kCVPixelBufferCGBitmapContextCompatibilityKey as String: true]
        var pxbuffer:CVPixelBuffer?
        let frameWidth = newWidth
        let frameHeight = newHeight
        
        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(frameWidth), Int(frameHeight), kCVPixelFormatType_32ARGB, options as CFDictionary?, &pxbuffer)
        assert(status == kCVReturnSuccess && pxbuffer != nil, "newPixelBuffer failed")
        
        
        CVPixelBufferLockBaseAddress(pxbuffer!, CVPixelBufferLockFlags(rawValue: 0))
        let pxdata = CVPixelBufferGetBaseAddress(pxbuffer!)
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: pxdata, width: Int(frameWidth), height: Int(frameHeight), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pxbuffer!), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
        assert(context != nil, "context is nil")
        
        context!.concatenate(CGAffineTransform.identity)
        context!.draw(cgImage, in: CGRect(x: 0, y: 0, width: frameWidth, height: frameHeight))
        CVPixelBufferUnlockBaseAddress(pxbuffer!, CVPixelBufferLockFlags(rawValue: 0))
        return pxbuffer
    }
    
}

