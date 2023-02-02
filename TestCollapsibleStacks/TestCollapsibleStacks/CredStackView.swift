//
//  CredStackView.swift
//  TestCollapsibleStacks
//
//  Created by Himangshu Barman on 21/01/23.
//

import UIKit
import CollapsibleView

class CredStackView: UIStackView {
    
    var isExpanded: Bool = true {
        willSet {
            setOrRemoveGradient(flag: !newValue)
        }
    }

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var secondaryTitleLabel: UILabel!
    @IBOutlet weak var secondarySubtitleLabel: UILabel!
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        
        applyCredCornerLayer()
    }
    
    func setGradient() {
        let gradient = CAGradientLayer()
        gradient.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1.0)
        gradient.frame = self.bounds
        gradient.opacity = 1
        gradient.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        self.layer.insertSublayer(gradient, at: 0)
    }
    
    func removeGradient() {        
        for gradientLayer in self.layer.sublayers! {
            if let gradientLayer = gradientLayer as? CAGradientLayer {
                gradientLayer.removeFromSuperlayer()
            }
        }
    }
    
    func setOrRemoveGradient(flag: Bool) {
        if flag {setGradient()}
        else {removeGradient()}
    }
    
}

extension UIView {
    //Applies corners to top left and top right corners
    func applyCredCornerLayer() {
        self.layer.cornerRadius = 15
        self.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
    }
}
