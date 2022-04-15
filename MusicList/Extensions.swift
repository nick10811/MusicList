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
    func downloadImage(with url: URL, completion: @escaping (UIImage?) -> Void)
}

extension UITableViewCell: ViewModel {
    func configCell(_ track: Track) {
        var content = self.defaultContentConfiguration()
        content.text = "\(track.name)"
        content.secondaryText = track.artist
        DispatchQueue.global().async { [weak self] in
            self?.downloadImage(with: track.artworkURL) { [weak self] image in
                DispatchQueue.main.async {
                    content.image = image
                    self?.contentConfiguration = content
                }
            }
        }
        content.image = UIImage(systemName: "photo")
        content.imageProperties.reservedLayoutSize = CGSize(width: 64, height: 64)
        content.imageProperties.maximumSize = CGSize(width: 50, height: 50)
        self.contentConfiguration = content
    }
    
    func downloadImage(with url: URL, completion: @escaping (UIImage?) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data else { return }
            DispatchQueue.main.async {
                let image = UIImage(data: data)
                completion(image)
            }
        }
        task.resume()
    }
    
}
