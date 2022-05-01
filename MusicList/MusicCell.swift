//
//  MusicCell.swift
//  MusicList
//
//  Created by Nick Yang on 2022/4/18.
//

import UIKit

protocol ViewModel {
    func configCell(_ track: Track)
}

enum NetworkError: Error {
    case requestError(Error)
    case invalidData
}

class MusicCell: UITableViewCell, ViewModel {
    
    static let identifier = "Music Cell"
    private let maxFetchCount = 2
    private var fetchCount = 0

    override func prepareForReuse() {
        fetchCount = 0
    }
    
    func configCell(_ track: Track) {
        var content = self.defaultContentConfiguration()
        content.text = "\(track.name)"
        content.secondaryText = track.artist
        content.image = UIImage(systemName: "photo")
        content.imageProperties.reservedLayoutSize = CGSize(width: 64, height: 64)
        content.imageProperties.maximumSize = CGSize(width: 50, height: 50)

        guard fetchCount < maxFetchCount else {
            self.contentConfiguration = content
            return
        }
        fetchCount += 1
        
        DispatchQueue.global().async { [weak self] in
            ImageDownloadService.shared.downloadImage(with: track.artworkURL) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let image):
                        content.image = image
                        self?.contentConfiguration = content
                    case .failure(let error):
                        print("load image failed: \(error.localizedDescription)")
                        self?.configCell(track)
                    }
                }
            }
        }
        self.contentConfiguration = content
    }
    
}
