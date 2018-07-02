//
//  UIImageView+LazyLoading.swift
//  FacebookPOC
//
//  Created by Shivaji Tanpure on 11/12/17.
//  Copyright © 2017 Virag Brahme. All rights reserved.
//

import Foundation
import UIKit
let imageCache = NSCache<NSString, AnyObject>()

extension UIImageView {
    
    func loadImageUsingUrlString(urlString:String){
        guard let url = URL(string: urlString) else { return }
        downloadImageFrom(url: url, imageMode: .scaleAspectFill)
    }
    
    func downloadImageFrom(url: URL, imageMode: UIViewContentMode) {
        contentMode = imageMode
        if let cachedImage = imageCache.object(forKey: url.absoluteString as NSString) as? UIImage {
            self.image = cachedImage
        } else {
            URLSession.shared.dataTask(with: url) { data, response, error in
                guard let data = data, error == nil else { return }
                DispatchQueue.main.async {
                    let imageToCache = UIImage(data: data)
                    imageCache.setObject(imageToCache!, forKey: url.absoluteString as NSString)
                    self.image = imageToCache
                }
                }.resume()
        }
    }
}
