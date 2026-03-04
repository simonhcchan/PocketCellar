//
//  RattingView.swift
//  RattingXIBDemo
//
//  Created by IE13 on 11/01/24.

import UIKit
protocol Datapass {
    func dataPassing(ratting: Int)
}

class RattingView: UIView {

    @IBOutlet var containerView: UIView!
    @IBOutlet var stackView: UIStackView!
    var panGesture: UIPanGestureRecognizer!
    var tapGesture: UITapGestureRecognizer!
    var delegate: Datapass?
    var lastIndex = -1
    var selectedRating = -1 {
        didSet {
            starAction(selectedRating)
        }
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initializeView()
        setupPanGesture()
        setupTapGesture()
    }

    func initializeView() {
        Bundle.main.loadNibNamed("RattingView", owner: self, options: nil)
        addSubview(containerView)
        containerView.frame = bounds
        containerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }

    func setupPanGesture() {
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        containerView.addGestureRecognizer(panGesture)
    }

    func setupTapGesture() {
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        containerView.addGestureRecognizer(tapGesture)
    }

    @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
        let location = gesture.location(in: stackView)
        handleGesture(location)
    }

    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: stackView)
        handleGestureByTap(location)
    }

    private func handleGesture(_ location: CGPoint) {
        for (index, imageView) in stackView.arrangedSubviews.enumerated() {
            if imageView.frame.contains(location) {
                selectedRating = index
                break
            }
        }
        if location.x <= 15 {
            selectedRating = -1
            return
        }
        starAction(selectedRating)
        delegate?.dataPassing(ratting: selectedRating + 1)
    }
 
    private func handleGestureByTap(_ location: CGPoint) {
        for (index, imageView) in stackView.arrangedSubviews.enumerated() {
            if imageView.frame.contains(location) {
                if lastIndex == index {
                    selectedRating = index - 1
                    lastIndex = index - 1
                } else {
                    selectedRating = index
                    lastIndex = index
                }
                break
            }
        }
        starAction(selectedRating)
        delegate?.dataPassing(ratting: selectedRating + 1)
    }
    
    private func starAction(_ selectedRating: Int) {
        print(selectedRating)
        for (index, imageView) in stackView.arrangedSubviews.enumerated() {
            if let imageView = imageView as? UIImageView {
                if selectedRating == -1{}else{
                    imageView.image = index <= selectedRating ? UIImage(named: StringConstants.ImageConstant.starFilled) : UIImage(named: StringConstants.ImageConstant.starUnfilled)
                }
            }
        }
    }
}
