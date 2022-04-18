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
