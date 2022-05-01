//
//  ImageDownloadService.swift
//  MusicList
//
//  Created by Nick Yang on 2022/4/24.
//

import Foundation
import UIKit

class ImageDownloadService {
    static let shared = ImageDownloadService()
    
    private var imageCache = NSCache<NSURL, UIImage>()
    
    func downloadImage(with url: URL, completion: @escaping (Result<UIImage, NetworkError>) -> Void) {
        if let image = imageCache.object(forKey: url as NSURL) {
            completion(.success(image))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            if let error = error {
                completion(.failure(.requestError(error)))
                return
            }
            
            guard let data = data,
                  let image = UIImage(data: data)
            else {
                completion(.failure(.invalidData))
                return
            }
            
            DispatchQueue.main.async {
                self?.imageCache.setObject(image, forKey: url as NSURL)
                completion(.success(image))
            }
        }
        task.resume()
    }

}
