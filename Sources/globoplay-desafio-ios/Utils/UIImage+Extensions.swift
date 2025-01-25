//
//  UIImage+Extensions.swift
//  globoplay-desafio-ios
//
//  Created by Filipe Xavier Fernandes on 24/01/25.
//

import Foundation
import UIKit

extension UIImage {
      func applyBlur(radius: CGFloat) -> UIImage {
        let context = CIContext(options: nil)
        guard let ciImage = CIImage(image: self) else { return self }
        let filter = CIFilter(name: "CIGaussianBlur", parameters: ["inputImage": ciImage, "inputRadius": radius])
        guard let outputImage = filter?.outputImage else { return self }
        let cgImage = context.createCGImage(outputImage, from: outputImage.extent)
        return UIImage(cgImage: cgImage!)
      }
}
