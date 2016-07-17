//
//  AVAssetExtension.swift
//  SHVideoTrimmerView
//
//  Created by ParkSangHa on 2016. 7. 17..
//  Copyright © 2016년 parksangha1021. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit


extension AVAsset {
    
    func videoOrientation() -> (orientation: UIInterfaceOrientation, device: AVCaptureDevicePosition) {
        var orientation: UIInterfaceOrientation = .Unknown
        var device: AVCaptureDevicePosition = .Unspecified
        
        let tracks :[AVAssetTrack] = self.tracksWithMediaType(AVMediaTypeVideo)
        if let videoTrack = tracks.first {
            
            let t = videoTrack.preferredTransform
            
            if (t.a == 0 && t.b == 1.0 && t.d == 0) {
                orientation = .Portrait
                
                if t.c == 1.0 {
                    device = .Front
                } else if t.c == -1.0 {
                    device = .Back
                }
            }
            else if (t.a == 0 && t.b == -1.0 && t.d == 0) {
                orientation = .PortraitUpsideDown
                
                if t.c == -1.0 {
                    device = .Front
                } else if t.c == 1.0 {
                    device = .Back
                }
            }
            else if (t.a == 1.0 && t.b == 0 && t.c == 0) {
                orientation = .LandscapeRight
                
                if t.d == -1.0 {
                    device = .Front
                } else if t.d == 1.0 {
                    device = .Back
                }
            }
            else if (t.a == -1.0 && t.b == 0 && t.c == 0) {
                orientation = .LandscapeLeft
                
                if t.d == 1.0 {
                    device = .Front
                } else if t.d == -1.0 {
                    device = .Back
                }
            }
        }
        
        return (orientation, device)
    }
}