//
//  DetailViewController.swift
//  MusicList
//
//  Created by Nick Yang on 2022/3/30.
//

import UIKit

class DetailViewController: UIViewController {
    var track: Track
    
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
        
        let firstRow  = makeRow(title: "Name: ", content: track.name)
        let secondRow = makeRow(title: "Artist: ", content: track.artist)
        let thirdRow  = makeRow(title: "URL: ", content: track.collectionViewURL.absoluteString)
        let fourthRow  = UIImageView(image: UIImage(systemName: "photo"))
        do {
            let data = try Data(contentsOf: track.artworkURL)
            let image = UIImage(data: data)
            fourthRow.image = image
            
        } catch {
            print("Cannot download image")
        }
        
        @UseAutoLayout var contentView = UIStackView(arrangedSubviews: [firstRow, secondRow, thirdRow, fourthRow])
        contentView.translatesAutoresizingMaskIntoConstraints = false
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
    
    private func makeRow(title: String, content: String) -> UIView {
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
}

@propertyWrapper
struct UseAutoLayout<T: UIView> {
    var wrappedValue: T {
        didSet { setAutoLayout() }
    }
    
    init(wrappedValue: T) {
        self.wrappedValue = wrappedValue
        setAutoLayout()
    }
    
    func setAutoLayout() {
        wrappedValue.translatesAutoresizingMaskIntoConstraints = false
    }
}

