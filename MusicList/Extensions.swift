//
//  Extensions.swift
//  MusicList
//
//  Created by Nick Yang on 2022/3/31.
//

import Foundation
import UIKit

extension UIViewController {
    
    func showIndicatorView() {
        @UseAutoLayout var indicatorView = UIActivityIndicatorView(style: .large)
        indicatorView.tag = 0xFFEEFF
        self.view.addSubview(indicatorView)
        NSLayoutConstraint.activate([
            indicatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            indicatorView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        self.view.bringSubviewToFront(indicatorView)
        indicatorView.startAnimating()
    }
    
    func hideIndicatorView() {
        while let found = self.view.viewWithTag(0xFFEEFF) {
            found.removeFromSuperview()
        }
    }
}

protocol ViewModel {
    func configCell(_ track: Track)
    func downloadImage(with url: URL, completion: @escaping (Result<UIImage, NetworkError>) -> Void)
}

enum NetworkError: Error {
    case requestError(Error)
    case invalidData
}

fileprivate var imageCache = NSCache<NSURL, UIImage>()

extension UITableViewCell: ViewModel {
    
    func configCell(_ track: Track) {
        var content = self.defaultContentConfiguration()
        content.text = "\(track.name)"
        content.secondaryText = track.artist
        DispatchQueue.global().async { [weak self] in
            self?.downloadImage(with: track.artworkURL) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let image):
                        content.image = image
                        self?.contentConfiguration = content
                    case .failure(let error):
                        print("load image failed: \(error.localizedDescription)")
                        content.image = UIImage(systemName: "photo")
                        self?.contentConfiguration = content
                    }
                }
            }
        }
        content.image = UIImage(systemName: "photo")
        content.imageProperties.reservedLayoutSize = CGSize(width: 64, height: 64)
        content.imageProperties.maximumSize = CGSize(width: 50, height: 50)
        self.contentConfiguration = content
    }
    
    func downloadImage(with url: URL, completion: @escaping (Result<UIImage, NetworkError>) -> Void) {
        if let image = imageCache.object(forKey: url as NSURL) {
            completion(.success(image))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
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
                imageCache.setObject(image, forKey: url as NSURL)
                completion(.success(image))
            }
        }
        task.resume()
    }
    
}
