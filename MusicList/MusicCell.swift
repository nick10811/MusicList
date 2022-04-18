//
//  MusicCell.swift
//  MusicList
//
//  Created by Nick Yang on 2022/4/18.
//

import UIKit

protocol ViewModel {
    func configCell(_ track: Track)
    func downloadImage(with url: URL, completion: @escaping (Result<UIImage, NetworkError>) -> Void)
}

enum NetworkError: Error {
    case requestError(Error)
    case invalidData
}

fileprivate var imageCache = NSCache<NSURL, UIImage>()

class MusicCell: UITableViewCell, ViewModel {
    
    static let identifier = "Music Cell"

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
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
