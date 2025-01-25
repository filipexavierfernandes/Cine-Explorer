//
//  UIImage+Extensions.swift
//  globoplay-desafio-ios
//
//  Created by Filipe Xavier Fernandes on 24/01/25.
//

import Foundation
import UIKit

extension UIImage {
    func applyBlur(radius: CGFloat) -> UIImage? {
        let context = CIContext(options: nil)
        guard let inputImage = CIImage(image: self) else { return nil }
        guard let blurFilter = CIFilter(name: "CIGaussianBlur") else { return nil }
        blurFilter.setValue(inputImage, forKey: kCIInputImageKey)
        blurFilter.setValue(radius, forKey: "inputRadius")

        guard let outputImage = blurFilter.outputImage else { return nil }
        guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else { return nil }
        return UIImage(cgImage: cgImage)
    }
}
