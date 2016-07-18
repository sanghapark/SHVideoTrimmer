//
//  SHVideoTrimmerView.swift
//  SHVideoTrimmerView
//
//  Created by ParkSangHa on 2016. 7. 16..
//  Copyright © 2016년 parksangha1021. All rights reserved.
//

import UIKit
import AVFoundation


protocol SHVideoTrimmerViewDelegate {
    func changeStartTime(startTime: Float64)
}

class SHVideoTrimmerView: UIView {
    
    final let handleWidth: CGFloat = 15
    
    var delegate: SHVideoTrimmerViewDelegate?
    
    var leftShadingView = UIView(frame: CGRectZero)
    var rightShadingView = UIView(frame: CGRectZero)
    
    var trimView = UIView(frame: CGRectZero)
    var leftHandleView = UIView(frame: CGRectZero)
    var rightHandView = UIView(frame: CGRectZero)
    
    var startTime: Float64 {
        get {
            let numerator = leftHandleView.frame.origin.x + leftHandleView.frame.width - handleWidth
            let denominator = frame.width - (2 * handleWidth)
            let frontSkippedTime = Float64(numerator / denominator) * duration!
            return frontSkippedTime
        }
    }
    
    var endTime: Float64 {
        get {
            let numerator = rightHandView.frame.origin.x - handleWidth
            let denominator = frame.width - (2 * handleWidth)
            let backSkippedTime = Float64(numerator / denominator) * duration!
            return backSkippedTime
        }
    }
    
    var avAsset: AVAsset?
    var imageGenerator: AVAssetImageGenerator?
    
    
    var duration: Float64? {
        get {
            return avAsset != nil ? CMTimeGetSeconds(avAsset!.duration) : nil
        }
    }
    
    var trimmedDuration: Float64 {
        get {
            return endTime - startTime
        }
    }
    
    var thumbnailViews = [UIImageView]()
    var imageSetCount = 0

    
    init(frame: CGRect, avAsset: AVAsset) {
        super.init(frame: frame)
        self.avAsset = avAsset
        self.imageGenerator = AVAssetImageGenerator(asset: avAsset)

        let size = getThumbnailFrameSize()
        
        getThumbnailFrames(size!)
        
        
        trimView.frame = CGRectMake(0, 0, frame.width, frame.height)
        trimView.layer.borderColor = UIColor.yellowColor().CGColor
        trimView.layer.borderWidth = 2.0
        trimView.layer.cornerRadius = 2.0
        addSubview(trimView)
        
        let selectionPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(SHVideoTrimmerView.selectionPan))
        trimView.addGestureRecognizer(selectionPanGestureRecognizer)
        
        leftHandleView.frame = CGRectMake(0, 0, 15, frame.height)
        leftHandleView.backgroundColor = UIColor.yellowColor()
        leftHandleView.userInteractionEnabled = true
        leftHandleView.layer.cornerRadius = 2.0
        addSubview(leftHandleView)
        
        let leftKnobView = UIView(frame: CGRectMake(0, 0, 2, frame.height / 2))
        leftKnobView.backgroundColor = UIColor.darkGrayColor()
        leftKnobView.center = leftHandleView.center
        leftHandleView.addSubview(leftKnobView)
        
        let leftPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(SHVideoTrimmerView.leftHandlePan))
        leftHandleView.addGestureRecognizer(leftPanGestureRecognizer)

        
        rightHandView.frame = CGRectMake(frame.width - handleWidth, 0, 15, frame.height)
        rightHandView.backgroundColor = UIColor.yellowColor()
        rightHandView.userInteractionEnabled = true
        rightHandView.layer.cornerRadius = 2.0
        addSubview(rightHandView)
        
        let rightKnobView = UIView(frame: CGRectMake(0, 0, 2, frame.height / 2))
        rightKnobView.backgroundColor = UIColor.darkGrayColor()
        rightKnobView.center = CGPointMake(rightHandView.frame.width / 2, rightHandView.frame.height / 2)
        print(rightHandView.center)
        rightHandView.addSubview(rightKnobView)
        
        let rightPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(SHVideoTrimmerView.rightHandlePan))
        rightHandView.addGestureRecognizer(rightPanGestureRecognizer)
        
        leftShadingView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.7)
        rightShadingView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.7)
        addSubview(leftShadingView)
        addSubview(rightShadingView)
        
        layer.zPosition = 1
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    private func setup() {
        
    }
    
    

    func leftHandlePan(gestureRecognizer: UIPanGestureRecognizer) {
        guard let view = gestureRecognizer.view else { return }
        guard let superview = view.superview else { return }
        
        if gestureRecognizer.state == UIGestureRecognizerState.Began || gestureRecognizer.state == UIGestureRecognizerState.Changed {
                
            let translation = gestureRecognizer.translationInView(superview)
            
            if translation.x > 0 {
                let futureOriginX = view.frame.origin.x + translation.x
                let delta = rightHandView.frame.origin.x - (futureOriginX + view.frame.width)
                if delta > widthForOneSecond() {
                    if view.frame.origin.x >= 0 {
                        view.center = CGPointMake(view.center.x + translation.x, view.center.y)
                        
                    } else {
                        view.center = CGPointMake(self.handleWidth, view.center.y)
                    }
                    
                }
            } else {
                let futureOriginX = view.frame.origin.x + translation.x
                if futureOriginX <= 0 {
                    view.frame.origin.x = 0
                } else {
                    view.center = CGPointMake(view.center.x + translation.x, view.center.y)
                }
            }
            self.trimView.frame = CGRectMake(view.frame.origin.x, 0, (self.rightHandView.frame.origin.x + self.rightHandView.frame.width) - view.frame.origin.x, self.trimView.frame.height)

            gestureRecognizer.setTranslation(CGPointMake(0, 0), inView: self)
            leftShadingView.frame = CGRectMake(0, 0, leftHandleView.frame.origin.x - handleWidth >= 0 ? leftHandleView.frame.origin.x : 0, frame.height)
            
            delegate?.changeStartTime(startTime)
        }
    }
    
    
    func rightHandlePan(gestureRecognizer: UIPanGestureRecognizer) {

        
        guard let view = gestureRecognizer.view else { return }
        guard let superview = view.superview else { return }
        
        if gestureRecognizer.state == UIGestureRecognizerState.Began || gestureRecognizer.state == UIGestureRecognizerState.Changed {
            
            let translation = gestureRecognizer.translationInView(superview)
            
            if translation.x < 0 {
                let futureOriginX = view.frame.origin.x + translation.x
                let delta = futureOriginX - (leftHandleView.frame.origin.x + leftHandleView.frame.width)
                if delta > widthForOneSecond() {
                    if frame.height <= futureOriginX + view.frame.width {
                        view.center = CGPointMake(view.center.x + translation.x, view.center.y)
                    } else {
                        view.frame.origin.x = self.frame.width - self.handleWidth
                    }
                }
            } else {
                let futureOriginX = view.frame.origin.x + translation.x
                if futureOriginX + view.frame.width > frame.width{
                    view.frame.origin.x = self.frame.width - self.handleWidth
                } else {
                    view.center = CGPointMake(view.center.x + translation.x, view.center.y)
                }
            }
            self.trimView.frame = CGRectMake(self.leftHandleView.frame.origin.x, 0, (view.frame.origin.x + view.frame.width) - self.leftHandleView.frame.origin.x, self.trimView.frame.height)

            gestureRecognizer.setTranslation(CGPointMake(0, 0), inView: self)
            rightShadingView.frame = CGRectMake(rightHandView.frame.origin.x + rightHandView.frame.width, 0, frame.width - (rightHandView.frame.origin.x + rightHandView.frame.width), frame.height)
        }
    }
    
    func selectionPan(gestureRecognizer: UIPanGestureRecognizer) {
//        guard let view = gestureRecognizer.view else { return }
//        guard let superview = view.superview else { return }
//        if gestureRecognizer.state == UIGestureRecognizerState.Began || gestureRecognizer.state == UIGestureRecognizerState.Changed {
//            let translation = gestureRecognizer.translationInView(superview)
//            
//        }
    }
    
    
    private func getThumbnailFrameSize() -> CGSize? {
        guard let track = self.avAsset!.tracksWithMediaType(AVMediaTypeVideo).first else { return nil}
        let size = CGSizeApplyAffineTransform(track.naturalSize, track.preferredTransform)
        
        let height = self.frame.height
        var width:CGFloat = 0
        let ratio:CGFloat = size.width / size.height
        if size.width > size.height {
            width = height * ratio
        } else if size.width < size.height {
            width = height * ratio
        } else {
            width = height
        }
        return  CGSizeMake(fabs(width), fabs(height))
    }
    
    private func getThumbnailFrames(thumbnailSize: CGSize) {
        
        let thumbnailCount = ceil((self.frame.width - (2 * self.handleWidth)) / thumbnailSize.width)
        
        createThumbnailViews(Int(thumbnailCount), size: thumbnailSize)
        
        let timeInclement = duration! / Float64(thumbnailCount)
        
        var timesForThumbnails = [Float64]()
        for index in 0..<Int(thumbnailCount) {
            timesForThumbnails.append(timeInclement * Float64(index))
        }
        imageGenerator!.appliesPreferredTrackTransform = true // return true orientated video resolution
        imageGenerator!.generateCGImagesAsynchronouslyForTimes(timesForThumbnails) { [weak self]
            (cmTime1: CMTime, cgimage: CGImage?, cmTime2: CMTime, result: AVAssetImageGeneratorResult, error: NSError?) in
            
            if let strongSelf = self {
                if error == nil && result == AVAssetImageGeneratorResult.Succeeded{
                    if cgimage != nil {
                        dispatch_async(dispatch_get_main_queue(), { [strongSelf]
                            let uiimage = UIImage(CGImage: cgimage!, scale: 1.0, orientation: UIImageOrientation.Up)
                            strongSelf.thumbnailViews[strongSelf.imageSetCount].image = uiimage
                            strongSelf.imageSetCount += 1
                        })
                        
                        
                    }
                }
            }
            

        }
    }
    
    
    private func createThumbnailViews(count: Int, size: CGSize) -> [UIImageView] {
        
        for index in 0..<count {
            
            let thumbnailView = UIImageView(frame: CGRectZero)
            thumbnailView.clipsToBounds = true
            
            let viewEndX = CGFloat(index) * size.width + size.width + handleWidth
            
            if viewEndX > frame.width - handleWidth {
                thumbnailView.frame.size = CGSizeMake(size.width - (handleWidth - (frame.width - viewEndX)), size.height)
                thumbnailView.contentMode = .ScaleAspectFill
            } else {
                thumbnailView.frame.size = size
                thumbnailView.contentMode = .ScaleAspectFit
            }
            
            thumbnailView.frame.origin = CGPointMake(CGFloat(index) * size.width + handleWidth, 0)
            thumbnailView.backgroundColor = UIColor.lightGrayColor()
            self.thumbnailViews.append(thumbnailView)
            self.addSubview(thumbnailView)
        }
        
        return self.thumbnailViews
    }
    
    
    func widthForOneSecond() -> CGFloat{
        return (self.frame.width - 2 * handleWidth) / CGFloat(duration!)
    }
    
    
    
    

}













































