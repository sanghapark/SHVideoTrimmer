//
//  SHVideoTrimmerView.swift
//  SHVideoTrimmerView
//
//  Created by ParkSangHa on 2016. 7. 16..
//  Copyright © 2016년 parksangha1021. All rights reserved.
//

import UIKit
import AVFoundation

class SHVideoTrimmerView: UIView {
    
    final let handleWidth: CGFloat = 15
    
    var trimView = UIView(frame: CGRectZero)
    var leftHandleView = UIView(frame: CGRectZero)
    var rightHandView = UIView(frame: CGRectZero)
    
    var avAsset: AVAsset?
    var imageGenerator: AVAssetImageGenerator?
    
    
    var duration: Float64? {
        get {
            return avAsset != nil ? CMTimeGetSeconds(avAsset!.duration) : nil
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
        trimView.layer.borderWidth = 1.0
        trimView.layer.cornerRadius = trimView.frame.height / 10
        trimView.clipsToBounds = true
        addSubview(trimView)
        
        leftHandleView.frame = CGRectMake(0, 0, 15, frame.height)
        leftHandleView.backgroundColor = UIColor.yellowColor()
        trimView.addSubview(leftHandleView)

        
        rightHandView.frame = CGRectMake(frame.width - handleWidth, 0, 15, frame.height)
        rightHandView.backgroundColor = UIColor.yellowColor()
        trimView.addSubview(rightHandView)
//        rightHandView.layer.zPosition = 1
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    private func setup() {
        
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
        
        print(duration)
        print(timesForThumbnails)
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
//            thumbnailView.frame.size = size
//            thumbnailView.contentMode = .ScaleAspectFit
            
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
    
    

}
















































