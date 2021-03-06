/*
* Copyright (c) 2016 Magnet Systems, Inc.
* All rights reserved.
*
* Licensed under the Apache License, Version 2.0 (the "License"); you
* may not use this file except in compliance with the License. You
* may obtain a copy of the License at
*
* http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
* implied. See the License for the specific language governing
* permissions and limitations under the License.
*/

import DZVideoPlayerViewController
import MagnetMax

public class VideoPlayerViewController: UIViewController, DZVideoPlayerViewControllerDelegate {
    
    
    //MARK: Public properties
    
    
    var attachment: MMAttachment!
    var fileURL: NSURL!
    private var hideStatusBar = true
    @IBOutlet weak var videoContainerView: DZVideoPlayerViewControllerContainerView!
    var videoPlayerViewController: DZVideoPlayerViewController!
   
    
    //MARK: Overrides

   
    public init() {
        super.init(nibName: String(VideoPlayerViewController.self), bundle: NSBundle(forClass: VideoPlayerViewController.self))
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
   public override func preferredStatusBarUpdateAnimation() -> UIStatusBarAnimation {
        return .None
    }
    
   public override func prefersStatusBarHidden() -> Bool {
        return hideStatusBar
    }
    
   public override func viewDidLoad() {
        super.viewDidLoad()
        
        //Show player
        self.videoPlayerViewController = self.videoContainerView.videoPlayerViewController
        self.videoPlayerViewController.delegate = self
        self.videoPlayerViewController.configuration.isShowFullscreenExpandAndShrinkButtonsEnabled = false
        self.videoPlayerViewController.activityIndicatorView?.startAnimating()
        
        // Download file
        let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        let documentsUrl = NSURL(fileURLWithPath: documentsPath, isDirectory: true)
        fileURL = documentsUrl.URLByAppendingPathComponent(attachment!.name!)
        print(fileURL!)
        
        attachment.downloadToFile(fileURL, success: { [weak self] () in
            self?.startPlay()
        }) { [weak self] error in
            print(error)
            self?.videoPlayerViewController.activityIndicatorView?.stopAnimating()
            self?.playerFailedToLoadAssetWithError(error)
        }
    }
    
   public override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        // Show Status Bar
        hideStatusBar = false
        setNeedsStatusBarAppearanceUpdate()
        
        if NSFileManager.defaultManager().fileExistsAtPath(fileURL!.path!) {
            try! NSFileManager.defaultManager().removeItemAtURL(fileURL!)
        }
    }
    

    //MARK: Public Methods
    
    
    public func startPlay() {
        self.videoPlayerViewController.activityIndicatorView?.stopAnimating()
        self.videoPlayerViewController.videoURL = fileURL
        self.videoPlayerViewController.prepareAndPlayAutomatically(true)
    }
    
    
    //MARK: - DZVideoPlayerViewControllerDelegate
    
    
    public func playerDoneButtonTouched() {
        self.videoContainerView.videoPlayerViewController.stop()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    public func playerFailedToLoadAssetWithError(error: NSError!) {
        showAlert(error.localizedDescription, title: "Error", closeTitle: "Close") { [weak self] _ in
            self?.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
}
