//
//  VideoPlayerVC.swift
//  SHVideoTrimmerView
//
//  Created by ParkSangHa on 2016. 7. 16..
//  Copyright © 2016년 parksangha1021. All rights reserved.
//

import UIKit
import Photos
import AVFoundation

class VideoPlayerVC: UIViewController {
    

    var asset: PHAsset?
    var videoDimension: CGSize?
    var duration: Float64?
    
    var videoPath: String?
    
    var trimmerView: SHVideoTrimmerView?
    
    
    var playerView = UIView(frame: CGRectZero)
    var player: AVPlayer?
    var didFinishPlaying = false
    
    var toolBar = UIView(frame: CGRectZero)
    var dismissButton = UIButton(frame: CGRectZero)
    var playButton = UIButton(frame: CGRectZero)
    
    

    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initViews()
        
        let asset = PHAsset.fetchAssetsWithMediaType(.Video, options: nil)
        if asset.count > 0 {
            if let phAsset = asset[asset.count-1] as? PHAsset {
                self.asset = phAsset
                phAsset.getAssetUrl({ [phAsset] (url) in
                    phAsset.getResolution({ (dimension, orientation) in
                        self.videoDimension = dimension
                        dispatch_async(dispatch_get_main_queue(), { [url]
                            let view = self.createPlayerView(dimension!, orientation: orientation!)
                            self.playVideo(url!, playerView: view)
                        })
                    })
                })
            }
        } else {
            
        }
        
        
        if videoPath != nil {
            dispatch_async(dispatch_get_main_queue(), {
                
                let view = self.createPlayerView(self.videoDimension!)
                let nsUrl = NSURL(fileURLWithPath: self.videoPath!)
                self.playVideo(nsUrl, playerView: view)
                
            })
        }
        
        PHImageManager.defaultManager().requestAVAssetForVideo(self.asset!, options: nil) { [weak self]
            (avAsset: AVAsset?, audioMix: AVAudioMix?, info: [NSObject : AnyObject]?) in
            
            if let strongSelf = self {
                if avAsset != nil {
                    dispatch_async(dispatch_get_main_queue(), { [strongSelf]
                        let rect = CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height / 20)
                        strongSelf.trimmerView = SHVideoTrimmerView(frame: rect, avAsset: avAsset!)
                        strongSelf.trimmerView!.backgroundColor = UIColor.blueColor().colorWithAlphaComponent(0.5)
                        strongSelf.view.addSubview(strongSelf.trimmerView!)
                    })
                }
            }

        }
        
        
    }

    
    func disableButtons(){
        playButton.enabled = false
        dismissButton.enabled = false
    }
    
    
    func initViews() {
        self.title = "비디오"
        self.view.backgroundColor = UIColor.blackColor()
        
        let toolBarHeight:CGFloat = 66
        toolBar.frame = CGRectMake(0, UIScreen.mainScreen().bounds.height - toolBarHeight, UIScreen.mainScreen().bounds.width, toolBarHeight)
        //        toolBar.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.9)
        toolBar.layer.zPosition = 1
        view.addSubview(toolBar)
        
        let blurEffect = UIBlurEffect(style: .Dark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = CGRectMake(0, 0, toolBar.frame.width, toolBar.frame.height)
        blurView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        toolBar.addSubview(blurView)
        
        dismissButton.setTitle("취소", forState: .Normal)
        dismissButton.sizeToFit()
        dismissButton.frame.origin.x = 15
        dismissButton.center.y = toolBarHeight / 2
        dismissButton.addTarget(self, action: #selector(VideoPlayerVC.dismiss(_:)), forControlEvents: .TouchUpInside)
        toolBar.addSubview(dismissButton)
        
        
        playButton.setImage(UIImage(named: "video_play_solid"), forState: .Normal)
        playButton.frame.size = CGSizeMake(44, 44)
        playButton.center  = CGPointMake(toolBar.frame.width / 2, toolBar.frame.height / 2)
        playButton.addTarget(self, action: #selector(VideoPlayerVC.play(_:)), forControlEvents: .TouchUpInside)
        toolBar.addSubview(playButton)
        
    }
    
    func dismiss(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func play(sender: UIButton) {
        guard let player = self.player else { return }
        if player.rate == 0 {
            if didFinishPlaying {
                player.seekToTime(kCMTimeZero)
            }
            
            player.play()
            playButton.setImage(UIImage(named: "video_pause_solid"), forState: .Normal)
            
        } else {
            player.pause()
            playButton.setImage(UIImage(named: "video_play_solid"), forState: .Normal)
        }
    }
    
    
    
    
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        if toolBar.alpha == 1 {
            UIView.animateWithDuration(0.25, animations: {
                self.toolBar.alpha = 0
            })
        } else {
            UIView.animateWithDuration(0.25, animations: {
                self.toolBar.alpha = 1
            })
        }
    }
    
    
    func createPlayerView(size: CGSize, orientation: UIInterfaceOrientation? = nil) -> UIView {
        let screenWidth = UIScreen.mainScreen().bounds.width
        
        var realSize = CGSize(width: size.width, height: size.height)
        
        if orientation != nil {
            if orientation!.isPortrait {
                if size.width > size.height {
                    realSize.width = size.height
                    realSize.height = size.width
                }
            } else if orientation!.isLandscape {
                if size.width < size.height {
                    realSize.width = size.height
                    realSize.height = size.width
                }
            }
        }
        
        
        let playerViewWidth: CGFloat = screenWidth
        var playerViewHeight: CGFloat  = 0
        if realSize.width > realSize.height {
            playerViewHeight = playerViewWidth * (realSize.height / realSize.width)
        } else if realSize.width < realSize.height {
            playerViewHeight = playerViewWidth * (realSize.height / realSize.width)
        } else {
            playerViewHeight = playerViewWidth
        }
        
        playerView.frame = CGRectMake(0, 0, playerViewWidth, playerViewHeight)
        playerView.center = view.center
        
        playerView.backgroundColor = UIColor.blueColor()
        
        view.addSubview(playerView)
        playerView.userInteractionEnabled = false
        return playerView
    }
    
    
    func playVideo(url: NSURL, playerView: UIView) {
        let playerItem = AVPlayerItem(URL: url)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(VideoPlayerVC.itemDidFinishPlaying(_:)) , name: AVPlayerItemDidPlayToEndTimeNotification, object: playerItem)
        
        self.player = AVPlayer(playerItem: playerItem)
        
        self.duration = CMTimeGetSeconds(self.player!.currentItem!.asset.duration)
        
        let layer: AVPlayerLayer = AVPlayerLayer(player: player)
        layer.backgroundColor = UIColor.whiteColor().CGColor
        layer.frame = CGRectMake(0, 0, playerView.frame.width, playerView.frame.height)
        layer.videoGravity = AVLayerVideoGravityResizeAspectFill
        playerView.layer.addSublayer(layer)
    }
    
    func itemDidFinishPlaying(notification: NSNotification) {
        playButton.setImage(UIImage(named: "video_play_solid"), forState: .Normal)
        didFinishPlaying = true
    }
}

extension PHAsset {
    func getResolution(cb: (dimension: CGSize?, orientation: UIInterfaceOrientation?)->() ) {
        if self.mediaType == .Image {
            
        } else if self.mediaType == .Video {
            let options = PHVideoRequestOptions()
            options.version = .Original
            PHImageManager.defaultManager().requestAVAssetForVideo(self, options: options, resultHandler: { (avAsset: AVAsset?, avAudioMix: AVAudioMix?, info: [NSObject : AnyObject]?) in
                
                if let assetTrack = avAsset?.tracksWithMediaType(AVMediaTypeVideo).first {
                    
                    let orientation = avAsset!.videoOrientation().orientation
                    cb(dimension: assetTrack.naturalSize, orientation: orientation)
                    
                } else {
                    cb(dimension: nil, orientation: nil)
                }
            })
        }
    }
    
    
    func getAssetUrl(cb: (url: NSURL?)->() ) {
        if self.mediaType == .Image {
            let options = PHContentEditingInputRequestOptions()
            options.canHandleAdjustmentData = { (adjustmeta: PHAdjustmentData) -> Bool in
                return true
            }
            self.requestContentEditingInputWithOptions(options, completionHandler: { (contentEditingInput: PHContentEditingInput?, info: [NSObject : AnyObject]) in
                cb(url: contentEditingInput?.fullSizeImageURL)
            })
        } else if self.mediaType == .Video {
            let options = PHVideoRequestOptions()
            options.version = .Original
            PHImageManager.defaultManager().requestAVAssetForVideo(self, options: options, resultHandler: { (avAsset: AVAsset?, avAudioMix: AVAudioMix?, info: [NSObject : AnyObject]?) in
                if let urlAsset = avAsset as? AVURLAsset {
                    let localVideoUrl : NSURL = urlAsset.URL
                    cb(url: localVideoUrl)
                } else {
                    cb(url: nil)
                }
            })
        }
    }
}