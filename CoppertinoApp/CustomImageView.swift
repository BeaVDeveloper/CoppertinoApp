//
//  CustomImageView.swift
//  CoppertinoApp
//
//  Created by Yura Velko on 9/6/19.
//  Copyright © 2019 Yura Velko. All rights reserved.
//

import UIKit
var imageCache = [String: UIImage]()

class CustomImageView: UIImageView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentMode = .scaleAspectFill
        clipsToBounds = true
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    
    //Setting image and image caching
    var lastURLUsedToLoadImage: String?
    
    func loadImage(urlString: String) {
        lastURLUsedToLoadImage = urlString
        
        self.image = nil
        
        if let cacheImage = imageCache[urlString] {
            self.image = cacheImage
            return
        }
        
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { (data, response, err) in
            if let err = err {
                print("Failed to fecth post image: ", err)
                return
            }
            
            if url.absoluteString != self.lastURLUsedToLoadImage {
                return
            }
            
            guard let imageData = data else { return }
            
            let photoImage = UIImage(data: imageData)
            
            imageCache[url.absoluteString] = photoImage
            
            DispatchQueue.main.async {
                self.image = photoImage
            }
        }.resume()
    }
}
