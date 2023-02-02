//
//  Collapsible.swift
//  CollapsibleView
//
//  Created by Prahash Barman on 21/01/23.
//

import Foundation
import UIKit

protocol Collapsible {
    func collapse()
    func expand()
    func setOrRemoveGradient(flag: Bool)
}

extension Collapsible {
    func setOrRemoveGradient(flag: Bool) {}
}

extension UIStackView : Collapsible {
    
    public func collapse() {
        DispatchQueue.main.async {
            for index in 1..<self.arrangedSubviews.count {
                self.arrangedSubviews[index].isHidden = true
            }
            self.arrangedSubviews.first?.isHidden = false
        }
        setOrRemoveGradient(flag: true)
    }
    public func expand() {
        DispatchQueue.main.async {
            for index in 1..<self.arrangedSubviews.count {
                self.arrangedSubviews[index].isHidden = false
            }
            self.arrangedSubviews.first?.isHidden = true
        }
        setOrRemoveGradient(flag: false)
    }
}
