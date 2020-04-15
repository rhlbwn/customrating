//
//  RatingView.swift
//  StamuraiAssignment
//
//  Created by Rahul Bawane on 14/04/20.
//  Copyright © 2020 Rahul Bawane. All rights reserved.
//

import UIKit

protocol RatingViewDelegate {
    func updatedRating(rating: Int)
    func updatingRating(rating: Int)
}

/// A simple rating view that can set whole, half or floating point ratings.
@IBDesignable
@objcMembers
open class RatingView: UIView {
    
    // MARK: Properties
    
    var delegate: RatingViewDelegate!

    /// Array of empty image views
    private var emptyImageViews: [UIImageView] = []

    /// Array of full image views
    private var fullImageViews: [UIImageView] = []

    /// Sets the empty image (e.g. a star outline)
    @IBInspectable open var emptyImage: UIImage? {
        didSet {
            // Update empty image views
            for imageView in emptyImageViews {
                imageView.image = emptyImage
            }
            refresh()
        }
    }

    /// Sets the full image that is overlayed on top of the empty image.
    /// Should be same size and shape as the empty image.
    @IBInspectable open var fullImage: UIImage? {
        didSet {
            // Update full image views
            for imageView in fullImageViews {
                imageView.image = fullImage
            }
            refresh()
        }
    }

    /// Sets the empty and full image view content mode.
    open var imageContentMode: UIView.ContentMode = .scaleAspectFit

    /// Minimum rating.
    @IBInspectable open var minRating: Int = 0 {
        didSet {
            // Update current rating if needed
            if rating < minRating {
                rating = minRating
                refresh()
            }
        }
    }

    /// Max rating value.
    @IBInspectable open var maxRating: Int = 5 {
        didSet {
            if maxRating != oldValue {
                removeImageViews()
                initImageViews()
                
                // Relayout and refresh
                setNeedsLayout()
                refresh()
            }
        }
    }

    /// Minimum image size.
    @IBInspectable open var minImageSize = CGSize(width: 5.0, height: 5.0)

    /// Set the current rating.
    @IBInspectable open var rating: Int = 0 {
        didSet {
            if rating != oldValue {
                refresh()
            }
        }
    }

    /// Sets whether or not the rating view can be changed by panning.
    @IBInspectable open var editable = true

     
    required override public init(frame: CGRect) {
        super.init(frame: frame)
        
        initImageViews()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        initImageViews()
    }
    
    // MARK: Helper methods

    private func initImageViews() {
        guard emptyImageViews.isEmpty && fullImageViews.isEmpty else {
            return
        }

        // Add new image views
        for _ in 0..<maxRating {
            let emptyImageView = UIImageView()
            emptyImageView.contentMode = imageContentMode
            emptyImageView.image = emptyImage
            emptyImageViews.append(emptyImageView)
            addSubview(emptyImageView)

            let fullImageView = UIImageView()
            fullImageView.contentMode = imageContentMode
            fullImageView.image = fullImage
            fullImageViews.append(fullImageView)
            addSubview(fullImageView)
        }
    }

    private func removeImageViews() {
        // Remove old image views
        for i in 0..<emptyImageViews.count {
            var imageView = emptyImageViews[i]
            imageView.removeFromSuperview()
            imageView = fullImageViews[i]
            imageView.removeFromSuperview()
        }
        emptyImageViews.removeAll(keepingCapacity: false)
        fullImageViews.removeAll(keepingCapacity: false)
    }

    // Refresh hides or shows full images
    private func refresh() {
        for i in 0..<fullImageViews.count {
            let imageView = fullImageViews[i]

            if rating >= i+1 {
                imageView.layer.mask = nil
                imageView.isHidden = false
            } else if rating > i && rating < i+1 {
                // Set mask layer for full image
                let maskLayer = CALayer()
                maskLayer.frame = CGRect(x: 0, y: 0, width: CGFloat(rating-i)*imageView.frame.size.width, height: imageView.frame.size.height)
                maskLayer.backgroundColor = UIColor.black.cgColor
                imageView.layer.mask = maskLayer
                imageView.isHidden = false
            } else {
                imageView.layer.mask = nil;
                imageView.isHidden = true
            }
        }
    }
    
    // Calculates the ideal ImageView size in a given CGSize
    private func sizeForImage(_ image: UIImage, inSize size: CGSize) -> CGSize {
        let imageRatio = image.size.width / image.size.height
        let viewRatio = size.width / size.height
        
        if imageRatio < viewRatio {
            let scale = size.height / image.size.height
            let width = scale * image.size.width
            
            return CGSize(width: width, height: size.height)
        } else {
            let scale = size.width / image.size.width
            let height = scale * image.size.height
            
            return CGSize(width: size.width, height: height)
        }
    }

    // Calculates new rating based on touch location in view
    private func updateLocation(_ touch: UITouch) {
        guard editable else {
            return
        }

        let touchLocation = touch.location(in: self)
        var newRating: Int = 0
        for i in stride(from: (maxRating-1), through: 0, by: -1) {
            let imageView = emptyImageViews[i]
            guard touchLocation.x > imageView.frame.origin.x else {
                continue
            }
            newRating = i + 1
            break
        }

        // Check min rating
        rating = newRating < minRating ? minRating : newRating

        // Update delegate
        delegate.updatingRating(rating: rating)
    }


    // MARK: UIView
    
    // Override to calculate ImageView frames
    override open func layoutSubviews() {
        super.layoutSubviews()

        guard let emptyImage = emptyImage else {
            return
        }

        let desiredImageWidth = frame.size.width / CGFloat(emptyImageViews.count)
        let maxImageWidth = max(minImageSize.width, desiredImageWidth)
        let maxImageHeight = max(minImageSize.height, frame.size.height)
        let imageViewSize = sizeForImage(emptyImage, inSize: CGSize(width: maxImageWidth, height: maxImageHeight))
        let imageXOffset = (frame.size.width - (imageViewSize.width * CGFloat(emptyImageViews.count))) /
                            CGFloat((emptyImageViews.count - 1))
        
        for i in 0..<maxRating {
            let imageFrame = CGRect(x: i == 0 ? 0 : CGFloat(i)*(imageXOffset+imageViewSize.width), y: 0, width: imageViewSize.width, height: imageViewSize.height)
            
            var imageView = emptyImageViews[i]
            imageView.frame = imageFrame
            
            imageView = fullImageViews[i]
            imageView.frame = imageFrame
        }
        
        refresh()
    }


    // MARK: Touch events

    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        updateLocation(touch)
    }

    override open func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        updateLocation(touch)
    }
    
    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        delegate.updatingRating(rating: Int(rating))
    }
    
    override open func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        delegate.updatedRating(rating: Int(rating))
    }
}


