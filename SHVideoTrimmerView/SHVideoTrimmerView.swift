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
        print(size)
        
        getThumbnailFrames(size!)
        
        self.layer.bou
    
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
        
        let thumbnailCount = ceil(self.frame.width / thumbnailSize.width)
        
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
                        
                        let uiimage = UIImage(CGImage: cgimage!, scale: 1.0, orientation: UIImageOrientation.Up)
                        
                        dispatch_async(dispatch_get_main_queue(), { 
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
            thumbnailView.contentMode = .ScaleAspectFit
            thumbnailView.clipsToBounds = true
            thumbnailView.frame.size = size
            thumbnailView.frame.origin = CGPointMake(CGFloat(index) * size.width, 0)
            thumbnailView.backgroundColor = UIColor.lightGrayColor()
            self.thumbnailViews.append(thumbnailView)
            self.addSubview(thumbnailView)
        }
        
        return self.thumbnailViews
    }
    
    

    private func getFrames() -> [UIImage] {
        
        let images = [UIImage]()
        
        
        
        
        return images
    }
}
















































