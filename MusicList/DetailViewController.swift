//
//  DetailViewController.swift
//  MusicList
//
//  Created by Nick Yang on 2022/3/30.
//

import UIKit

class DetailViewController: UIViewController {
    private var track: Track
    private var imageID: UUID? = nil
    private var stopToDownload = false
    
    init(track: Track) {
        self.track = track
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Details"
        
        let firstRow  = makeRow(of: "Name: ", with: track.name)
        let secondRow = makeRow(of: "Artist: ", with: track.artist)
        let thirdRow  = makeRow(of: "URL: ", with: track.collectionViewURL.absoluteString)
        let fourthRow = UIImageView(image: UIImage(systemName: "photo"))
        // it needs to turn on in the UIImageView if you have customized gesture
        fourthRow.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(stopDownloadingImage(_:)))
        fourthRow.addGestureRecognizer(tapGesture)
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            self.imageID = ImageDownloadService.shared.downloadImage(with: self.track.artworkURL, completion: { result in
                switch result {
                case .success(let image):
                    DispatchQueue.main.asyncAfter(deadline: .now()+3) {
                        if !self.stopToDownload {
                            fourthRow.image = image
                        }
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        self.showError(message: error.localizedDescription)
                    }
                }
            })
        }
        
        @UseAutoLayout var contentView = UIStackView(arrangedSubviews: [firstRow, secondRow, thirdRow, fourthRow])
        contentView.axis = .vertical
        contentView.distribution = .fill
        contentView.spacing = 10
        view.addSubview(contentView)
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            contentView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 30),
            contentView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -30),
            fourthRow.heightAnchor.constraint(equalTo: contentView.widthAnchor)
        ])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        stopToDownload = false
    }
    
}

extension DetailViewController {
    private func makeLabel(with text: String) -> UILabel {
        let label = UILabel(frame: .zero)
        label.textColor = .black
        label.font = .systemFont(ofSize: 14)
        label.numberOfLines = 0
        label.text = text
        return label
    }
    
    private func makeRow(of title: String, with content: String) -> UIView {
        let titleLabel = makeLabel(with: title)
        let contentLabel = makeLabel(with: content)
        @UseAutoLayout var contentView = UIStackView(arrangedSubviews: [titleLabel, contentLabel])
        contentView.axis = .horizontal
        contentView.distribution = .fillProportionally
        NSLayoutConstraint.activate([
            titleLabel.widthAnchor.constraint(equalToConstant: 50)
        ])
        return contentView
    }
    
    @objc private func stopDownloadingImage(_ sender: UIGestureRecognizer) {
        print("tap gesture is clicking.")
        
        let alertController = UIAlertController(title: "Alert", message: "Do you want to stop to download the image?", preferredStyle: .alert)
        let noAction = UIAlertAction(title: "NO", style: .cancel, handler: nil)
        let yesAction = UIAlertAction(title: "YES", style: .default) { [weak self] action in
            if let uuid = self?.imageID {
                ImageDownloadService.shared.cancelLoad(uuid)
            }
            self?.stopToDownload = true
            self?.imageID = nil
        }
        
        alertController.addAction(noAction)
        alertController.addAction(yesAction)
        self.present(alertController, animated: true, completion: nil)
    }
}
