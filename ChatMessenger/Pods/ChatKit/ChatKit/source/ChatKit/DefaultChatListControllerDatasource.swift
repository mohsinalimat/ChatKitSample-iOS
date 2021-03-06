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

import UIKit

import CocoaLumberjack
import MagnetMax

public class DefaultChatListControllerDatasource : NSObject, ChatListControllerDatasource {
    
    
    //MARK : Public Variables
    
    
    public weak var controller : MMXChatListViewController?
    public var hasMoreUsers : Bool = true
    public private(set) var channels : [MMXChannel] = []
    public let limit = 30
    
    
    // Public Functions
    
    
    public func createChat(from subscribers : [MMUser]) {
        let id = NSUUID().UUIDString
        
        MMXChannel.createWithName(id, summary: id, isPublic: false, publishPermissions: .Anyone, subscribers: Set(subscribers), success: { (channel) -> Void in
            self.controller?.reloadData()
            DDLogVerbose("[Channel Created] - (\(channel.name))")
            }) { (error) -> Void in
                DDLogError("[Error] - \(error.localizedDescription)")
        }
    }
    
    public func subscribedChannels(completion : ((channels : [MMXChannel]) -> Void)) {
        MMXChannel.subscribedChannelsWithSuccess({ ch in
            self.channels = ch
            completion(channels: self.channels)
            DDLogVerbose("[Retireved] - Channels (\(self.channels.count))")
            }) { error in
                completion(channels: [])
                DDLogError("[Error] - \(error.localizedDescription)")
        }
    }
    
    
    //Mark: ChatListControllerDatasource
    
    
    public  func mmxControllerHasMore() -> Bool {
        return self.hasMoreUsers
    }
    
    public func mmxControllerSearchUpdatesContinuously() ->Bool {
        return true
    }
    
    public func mmxControllerLoadMore(searchText : String?, offset : Int) {
        
        self.hasMoreUsers = offset == 0 ? true : self.hasMoreUsers
        //get request context
        let loadingContext = controller?.loadingContext()
        subscribedChannels({ channels in
            if loadingContext != self.controller?.loadingContext() {
                return
            }
            var offsetChannels : [MMXChannel] = []
            if offset < channels.count {
                offsetChannels = Array(channels[offset..<min((offset + self.limit), channels.count)])
            } else {
                self.hasMoreUsers = false
            }
            
            self.controller?.append(offsetChannels)
        })
    }
    
    public func mmxListImageForChannelDetails(imageView: UIImageView, channelDetails: MMXChannelDetailResponse) {
        if channelDetails.subscriberCount > 2 {
            let image = UIImage(named: "user_group_clear.png", inBundle: NSBundle(forClass: DefaultChatListControllerDatasource.self), compatibleWithTraitCollection: nil)
            imageView.backgroundColor = controller?.appearance.tintColor
            imageView.image = image
        } else {
            var subscribers = channelDetails.subscribers.filter({$0.userId != MMUser.currentUser()?.userID})
            if subscribers.count == 0 {
                subscribers = channelDetails.subscribers
            }
            if let userProfile = subscribers.first {
                let tmpUser = MMUser()
                tmpUser.extras = ["hasAvatar" : "true"]
                
                var fName : String?
                var lName : String?
                let nameComponents = userProfile.displayName.componentsSeparatedByString(" ")
                if let lastName = nameComponents.last where nameComponents.count > 1 {
                    lName = lastName
                }
                
                if let firstName = nameComponents.first {
                    fName = firstName
                }
                
                tmpUser.firstName = ""
                tmpUser.lastName = ""
                tmpUser.userName = userProfile.displayName
                tmpUser.userID = userProfile.userId
                let defaultImage = Utils.noAvatarImageForUser(fName, lastName: lName)
                Utils.loadImageWithUrl(tmpUser.avatarURL(), toImageView: imageView, placeholderImage:defaultImage)
            }
        }
    }
    
    public func mmxListCellForMMXChannel(tableView : UITableView,channel : MMXChannel, channelDetails : MMXChannelDetailResponse, row : Int) -> UITableViewCell? {
        return nil
    }
    
    public func mmxListCellHeightForMMXChannel(channel : MMXChannel, channelDetails : MMXChannelDetailResponse, row : Int) -> CGFloat {
        return 80
    }
    
    public func mmxListRegisterCells(tableView : UITableView) {
        //using standard cells
    }
}
