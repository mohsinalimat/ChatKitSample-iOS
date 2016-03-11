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
import MagnetMax


//MARK: MagnetChatViewController


public class MMXChatViewController: ChatViewController {
    
    
    //Private Variables
    
    
    private var requestNumber : Int = 0
    
    
    
    //MARK: Public Variables
    
    
    public var showDetails = true
    
    public var channel : MMXChannel? {
        get {
            return chat
        }
    }
    
    public var delegate : ChatViewControllerDelegate?
    public var datasource : ChatViewControllerDatasource?
    public var useNavigationBarNotifier : Bool? {
        didSet {
            if useNavigationBarNotifier == true {
                navigationBarNotifier = NavigationNotifier(viewController: self, exceptFor: self.channel)
            } else {
                navigationBarNotifier = nil
            }
        }
    }
    
    public override var chat  : MMXChannel? {
        didSet {
            useNavigationBarNotifier = true
        }
    }
    
    //MARK: Init
    
    
    public override init() {
        useNavigationBarNotifier = false
        super.init()
    }
    
    public convenience init(channel : MMXChannel) {
        self.init()
        self.chat = channel
    }
    
    public convenience init(recipients : [MMUser]) {
        self.init()
        self.recipients = recipients
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    //MARK: Public Methods
    
    
    public override func hasMore() -> Bool {
        if let datasource = self.datasource {
            return datasource.mmxControllerHasMore()
        }
        return super.hasMore()
    }
    
    public func loadingContext() -> Int {
        return self.requestNumber
    }
    
    override public func loadMore(channel : MMXChannel?, offset: Int) {
        self.datasource?.mmxControllerLoadMore(channel, offset: offset)
    }
    
    private func newLoadingContext() {
        self.requestNumber++
    }
    
    public func reloadData() {
        self.append([])
    }
    
    
    //MARK: Overrides
    
    
    override public func setupViewController() {
        super.setupViewController()
        
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        self.datasource = DefaultChatViewControllerDatasource()
        if let datasource = self.datasource as? DefaultChatViewControllerDatasource {
            datasource.controller = self
        }
        self.delegate = DefaultChatViewControllerDelegate()
        if let delegate = self.delegate as? DefaultChatViewControllerDelegate {
            delegate.controller = self
        }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.tintColor = self.appearance.tintColor
    }
    
    override public func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        generateNavBars()
    }
    
    
    //MARK: Private Methods
    
    
    private func generateNavBars() {
        if showDetails {
            let rightBtn = UIBarButtonItem.init(title: "Details", style: .Plain, target: self, action: "detailsAction")
            self.navigationItem.rightBarButtonItem = rightBtn
            if channel == nil {
                self.navigationItem.rightBarButtonItem?.enabled = false
            }
        }
    }
    
    
    //MARK: Actions
    
    
    func detailsAction() {
        
        if let currentUser = MMUser.currentUser() {
            let contacts = MMXContactsPickerController(disabledUsers: [currentUser])
            contacts.barButtonNext = nil
            let subDatasource = SubscribersDatasource()
            subDatasource.magnetPicker = contacts
            contacts.datasource = subDatasource
            subDatasource.channel = self.channel
            subDatasource.chatViewController = self
            contacts.tableView.allowsSelection = false
            contacts.canSearch = false
            contacts.title = CKStrings.kStr_Subscribers
            self.navigationController?.pushViewController(contacts, animated: true)
        }
        
    }
    
    
    //MARK:  DataMethod Overrides
    
    
    override public func onChannelCreated(mmxChannel: MMXChannel) {
        self.useNavigationBarNotifier = true
        self.delegate?.mmxChatDidCreateChannel(mmxChannel)
    }
    
    override public func onMessageRecived(mmxMessage: MMXMessage) {
        self.delegate?.mmxChatDidRecieveMessage(mmxMessage)
    }
    
    override public func onMessageSent(mmxMessage: MMXMessage) {
        self.delegate?.mmxChatDidSendMessage(mmxMessage)
    }
}