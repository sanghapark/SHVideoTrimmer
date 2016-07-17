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

    
//    var collectionView: UICollectionView = UICollectionView(frame: CGRectZero)
    
    init(frame: CGRect, avAsset: AVAsset) {
        super.init(frame: frame)
        self.avAsset = avAsset
        self.imageGenerator = AVAssetImageGenerator(asset: avAsset)

        let size = getThumbnailFrameSize()
        print(size)
        
        getThumbnailFrames(size!)
    
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    private func setup() {
//        collectionView.frame = CGRectMake(0, 0, frame.width, frame.height)
        
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
        let timeInclement = duration! / Float64(thumbnailCount)
        
        var timesForThumbnails = [Float64]()
        for index in 0..<Int(thumbnailCount) {
            timesForThumbnails.append(timeInclement * Float64(index))
        }
        
        print(duration)
        print(timesForThumbnails)
        imageGenerator!.appliesPreferredTrackTransform = true // return true orientated video resolution
        imageGenerator!.generateCGImagesAsynchronouslyForTimes(timesForThumbnails) {
            (cmTime1: CMTime, cgimage: CGImage?, cmTime2: CMTime, result: AVAssetImageGeneratorResult, error: NSError?) in
            
            if error == nil && result == AVAssetImageGeneratorResult.Succeeded{
                if cgimage != nil {

                    let uiimage = UIImage(CGImage: cgimage!, scale: 1.0, orientation: UIImageOrientation.Up)
                    
                }
            }
        }
    }
    
    

    private func getFrames() -> [UIImage] {
        
        let images = [UIImage]()
        
        
        
        
        return images
    }
}
















































