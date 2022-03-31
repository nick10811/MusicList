//
//  Utility.swift
//  MusicList
//
//  Created by Nick Yang on 2022/3/31.
//

import Foundation
import UIKit

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
