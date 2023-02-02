//
//  ViewController.swift
//  TestCollapsibleStacks
//
//  Created by Himangshu Barman on 21/01/23.
//

import UIKit
import CollapsibleView
import SwiftUI

class ViewController: UIViewController {

    @IBOutlet weak var nextActionButton: UIButton!
    @IBOutlet weak var stackviewContainer: UIStackView!
    @IBOutlet weak var sliderContainer: UIView!
    @IBOutlet weak var activity: UIActivityIndicatorView!
    @IBOutlet weak var activityTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var activityBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var creditRepaymentDurationLabel: UILabel!
    
    private var circularSliderView: CircularSliderView?
    private var expandedRowIndex:Int = 0
    private var creditValue:Int = 0
    private let buttonTickImage: UIImage? = UIImage(systemName: "checkmark.circle.fill")?.withTintColor(.black, renderingMode: .alwaysOriginal)
    private let buttonEmptyImage: UIImage = UIImage()
    
    private let expandedData: [(String,String)] = [("prahash, how much do you need?", "move the dial and set any amount you need upto ₹ 9,50,000"),
                                         ("how do you wish to repay?", "choose one of our recommended plans or make your own"),
                                         ("where should we send the money?", "amount will be credited to this bank account, EMI will also be debited from this bank account")]
    private var collapsedData: [(String,String)] = [("credit amount","₹1,50,000"),("EMI","₹4,245 /mo")]
    private let nextButtonText: [String] = ["Proceed to EMI selection", "Select your bank account", "Tap for 1-click KYC"]
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.main.async {
            self.activity.startAnimating()
            self.configureButtons()
            self.configureStackViews()
            self.drawCustomSlider()
            self.activity.stopAnimating()
            self.activityTopConstraint.constant = (UIApplication.shared.currentUIWindow()?.safeAreaInsets.bottom ?? 0) + 80
            self.activityBottomConstraint.constant = (UIApplication.shared.currentUIWindow()?.safeAreaInsets.bottom ?? 0) + 60
        } 
        
    }
    
    //MARK: Utility methods for drawing UI
    private func drawCustomSlider() {
        circularSliderView = CircularSliderView()
        circularSliderView?.delegate = self
        let childView = UIHostingController(rootView: self.circularSliderView!)
        childView.view.contentMode = .scaleToFill
        let width = sliderContainer.bounds.width
        childView.view.frame = CGRect(x: (width - 250.0)/2, y: 20.0, width: 250, height: 250)
        childView.view.contentMode = .center
        childView.view.backgroundColor = .clear
        
        sliderContainer.addSubview(childView.view)
        sliderContainer.layoutSubviews()
    }
    
    private func configureStackViews() {
        stackviewContainer.applyCredCornerLayer()
        
        for index in 0..<self.stackviewContainer.arrangedSubviews.count {
            if let stack = self.stackviewContainer.arrangedSubviews[index] as? CredStackView {
                stack.arrangedSubviews.first?.isHidden = true
                //No collapsed view for the last cell
                if (index<2) {
                    stack.secondaryTitleLabel.text = collapsedData[index].0
                    stack.secondarySubtitleLabel.text = collapsedData[index].1
                }
                stack.titleLabel.text = expandedData[index].0
                stack.subtitleLabel.text = expandedData[index].1
            }
            //Show only the first cell initially
            if (index != 0) {self.stackviewContainer.arrangedSubviews[index].isHidden = true}
        }
    }

    private func configureButtons() {
        nextActionButton.clipsToBounds = true
        nextActionButton.applyCredCornerLayer()
        nextActionButton.setAttributedTitle(createButtonAttributedString(text: nextButtonText[0]), for: .normal)
        
        //Selecting the recommended EMI plan by default
        if let button = self.view.viewWithTag(21) as? UIButton {
            button.isSelected = true
            button.setImage(buttonTickImage, for: .normal)
        }
    }
    
    private func createButtonAttributedString(text: String) -> NSAttributedString {
        let attr = [ NSAttributedString.Key.foregroundColor: UIColor.yellow.withAlphaComponent(0.6),
                      NSAttributedString.Key.font: UIFont(name: "Avenir-Heavy", size: 16.0)! ]
        let attrStr = NSAttributedString(string: text, attributes: attr)
        return attrStr
    }
    
    private func createGradientView(frame: CGRect) -> CAGradientLayer {
        let gradient = CAGradientLayer()
        gradient.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1.0)
        gradient.frame = frame
        gradient.colors = [UIColor.white.cgColor, UIColor.black.cgColor]
        gradient.opacity = 0.05
        gradient.cornerRadius = 15.0
        gradient.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        return gradient
    }
    
    private func updateCollapsedRows(rowIndex: Int) {
        switch rowIndex {
        //Get the credit meter set by user
        case 0:
            var tempCredit:String = creditValue.description
            var parts:[String] = [tempCredit.suffix(3).description]
            if tempCredit.count > 2 {
                tempCredit.removeLast(3)
                while (tempCredit.count > 1) {
                    parts.append(tempCredit.suffix(2).description)
                    if tempCredit.count > 1 {tempCredit.removeLast(2)}
                }
                parts.append(tempCredit.suffix(2).description)
            }
            var creditValString = "₹ "
            for part in parts.reversed() {
                if (Int(part) != nil) {creditValString += part + ","}
            }
            creditValString.removeLast()
            collapsedData[0].1 = creditValString
            if let credStack = stackviewContainer.arrangedSubviews[0] as? CredStackView {
                credStack.secondarySubtitleLabel.text = self.collapsedData[0].1
            }
        //Get the repayment plan chosen by user
        case 1:
            var selectedButtonIndex = 0
            for index in 20...23 {
                if let button = self.view.viewWithTag(index) as? UIButton {
                    if button.isSelected {selectedButtonIndex = index - 20; break;}
                }
            }
            let text  = self.view.viewWithTag(25 + selectedButtonIndex)
            if let labelText = text as? UILabel {
                collapsedData[1].1 = labelText.text?.components(separatedBy: "\n").first ?? ""
                if let credStack = stackviewContainer.arrangedSubviews[1] as? CredStackView {
                    credStack.secondarySubtitleLabel.text = self.collapsedData[1].1
                }
                let repaymentPlanWordsArray : [String] = labelText.text?.components(separatedBy: " ") ?? []
                let repaymentPeriod: String = repaymentPlanWordsArray.last(where: { num in
                    return Int(num) != nil
                }) ?? "0"
                creditRepaymentDurationLabel.text = repaymentPeriod + " months"
            }
        default: print("default case")
        }
    }
    
    //MARK: IBAction methods
    @IBAction func nextButtonTapped(_ sender: UIButton) {
        if (expandedRowIndex == 2) {
            print("go to next screen")
            return
        }
        
        //Expand the next cell and collapse the current cell
        DispatchQueue.main.async { [weak self] in
            self?.updateCollapsedRows(rowIndex: self?.expandedRowIndex ?? 0)
            
            if let collapsedStack = self?.stackviewContainer.arrangedSubviews[self?.expandedRowIndex ?? 0] as? CredStackView {
                collapsedStack.collapse()
                collapsedStack.isExpanded = false
            }
            
            self?.expandedRowIndex += 1
            let buttonAttrString = self?.createButtonAttributedString(text: self?.nextButtonText[self?.expandedRowIndex ?? 0] ?? "")
            self?.nextActionButton.setAttributedTitle(buttonAttrString, for: .normal)
            
            UIView.animate(withDuration: 0.25) {
                self?.stackviewContainer.arrangedSubviews[self?.expandedRowIndex ?? 0].isHidden = false
                self?.stackviewContainer.layoutIfNeeded()
            }
        }
    }
    
    @IBAction func dropDownTapped(_ sender: UIButton) {
        //Expand the selected cell, cells below it are hidden
        DispatchQueue.main.async { [weak self] in
            self?.activity.isHidden = false
            self?.activity.startAnimating()
            while self?.expandedRowIndex ?? -1>sender.tag {
                
                self?.stackviewContainer.arrangedSubviews[self?.expandedRowIndex ?? 0].isHidden = true
                self?.expandedRowIndex -= 1
                if let view = self?.stackviewContainer.arrangedSubviews[self?.expandedRowIndex ?? 0] as? CredStackView {
                    view.expand()
                    view.isExpanded = true
                }
            }
            let buttonAttrString = self?.createButtonAttributedString(text: self?.nextButtonText[self?.expandedRowIndex ?? 0] ?? "")
            self?.nextActionButton.setAttributedTitle(buttonAttrString, for: .normal)
            self?.activity.stopAnimating()
        }
    }
    
    //TODO: Dismiss action for cross button
    @IBAction func crossTapped(_ sender: UIButton) {
        print("dismiss")
    }
    
    //TODO: Change account for multiple bank account holders
    @IBAction func changeAccount() {
        print("change your bank account")
    }
    
    //TODO: Select the bank account from options
    @IBAction func selectAccount(_ sender: UIButton){
        print("selected bank account")
    }
    
    @IBAction func planSelected(_ sender: UIButton) {
        if sender.isSelected {
            sender.isSelected = false
            sender.setImage(buttonEmptyImage, for: .normal)
        } else {
            sender.isSelected = true
            sender.setImage(buttonTickImage, for: .normal)
            for tag in 20...23 {
                if tag != sender.tag && (self.view.viewWithTag(tag) as? UIButton)?.isSelected == true {
                    (self.view.viewWithTag(tag) as? UIButton)?.isSelected = false
                    (self.view.viewWithTag(tag) as? UIButton)?.setImage(buttonEmptyImage, for: .normal)
                }
            }
        }
    }
    
    //TODO: Create a custom EMI plan
    @IBAction func createCustomPlan() {
        print("create custom plan")
    }
}

//MARK: SliderValueDelegate methods
extension ViewController : SliderValueDelegate {
    func valueChanged(value: Int) {
        creditValue = value
        print(creditValue)
    }
}
