//
//  MessageView.swift
//  CMPE-ISA-Demo
//
//  Created by Ankit Thanekar on 16/03/20.
//  Copyright © 2020 Ankit Thanekar. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore
import GoogleSignIn
import MessageKit
import InputBarAccessoryView

class MessageView: MessagesViewController {
    
    @IBOutlet private var backgroundView : NoDataView!
    
    private var chatReference : CollectionReference!
    private var db : Firestore!
    var channel : Channel!
    private var masterMessageList : [Message] = []
    private let dataController = MessageDataController.shared
    private var messageListener: ListenerRegistration?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()
        title = channel.channelName
        
        if let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout {
            layout.textMessageSizeCalculator.outgoingAvatarSize = .zero
            layout.textMessageSizeCalculator.incomingAvatarSize = .zero
        }
        
        messagesCollectionView.keyboardDismissMode = .onDrag
        
        setupChatController()
        listenToChannels()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        dataController.masterMessageList.removeAll()
    }
    
    private func setupChatController() {
        maintainPositionOnKeyboardFrameChanged = true
        messageInputBar.inputTextView.tintColor = .black
        messageInputBar.sendButton.setTitleColor(.black, for: .normal)
        
        messageInputBar.delegate = self
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        
        dataController.delegate = self
        
        messageInputBar.leftStackView.alignment = .center
        messageInputBar.leftStackView.layer.borderColor = UIColor.black.cgColor
        messageInputBar.setLeftStackViewWidthConstant(to: 50, animated: false)
    }
    
    private func listenToChannels() {
        guard let channel = channel else { return  }
        chatReference = db.collection(["channels", channel.channelID, "messages"].joined(separator: "/"))
        chatReference.addSnapshotListener { (querySnapshot, error) in
            if let e = error {
                print(e)
            }
            guard let snapshot = querySnapshot else {
                print("Error listening for message updates: \(error?.localizedDescription ?? "No error")")
                return
            }
            snapshot.documentChanges.forEach {[weak self] change in
                self?.dataController.handleMessageUpdate(change: change)
            }
        }
    }
    
    func sendMessage(_ message : String){
        
        var messages : [String : Any] = [:]
        messages["message"] = message
        messages["senderID"] =  GIDSignIn.sharedInstance()?.currentUser.userID
        messages["senderName"] = GIDSignIn.sharedInstance()?.currentUser.profile.givenName
        messages["timestamp"] = Date.init().currentDateString()
        messages["epoch"] = Date.init().timeIntervalSince1970
        
        chatReference.addDocument(data: messages) { (error) in
            if let e = error {
                print("Error saving channel: \(e.localizedDescription)")
            }
        }
    }
}

// MARK: - MessagesDisplayDelegate

extension MessageView: MessagesDisplayDelegate {
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return .darkGray
    }
    
    func shouldDisplayHeader(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> Bool {
        return false
    }
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        let message = masterMessageList[indexPath.row]
        let uid = GIDSignIn.sharedInstance()?.currentUser.userID
        return (uid == message.senderID) ? .bubbleTail(.bottomRight, .curved) : .bubbleTail(.bottomLeft, .curved)
    }
    
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return .white
    }
}

// MARK: - MessagesLayoutDelegate

extension MessageView: MessagesLayoutDelegate {
    
    func avatarSize(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGSize {
        return CGSize.zero
    }
}

// MARK: - MessagesDataSource

extension MessageView: MessagesDataSource {
    
    func numberOfItems(inSection section: Int, in messagesCollectionView: MessagesCollectionView) -> Int {
        messagesCollectionView.backgroundView = masterMessageList.count > 0 ? nil : backgroundView
        return masterMessageList.count
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return 1
    }
    
    func messageForItem(at indexPath: IndexPath,
                        in messagesCollectionView: MessagesCollectionView) -> MessageType {
        let message = masterMessageList[indexPath.row]
        return message
    }
    
    func currentSender() -> SenderType {
        let user = GIDSignIn.sharedInstance()?.currentUser
        let uid = user?.userID ?? "No ID"
        let name = user?.profile.givenName ?? "No Name"
        return Sender(id: uid, displayName: name)
    }
    
    func numberOfMessages(in messagesCollectionView: MessagesCollectionView) -> Int {
        return masterMessageList.count
    }
    
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let name = message.sender.displayName
        let message = masterMessageList[indexPath.row]
        let uid = GIDSignIn.sharedInstance()?.currentUser.userID
        let paragraphStyle: NSMutableParagraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = uid == message.senderID ? .right : .left
        return NSAttributedString(
            string: name,
            attributes: [
                .font: UIFont.preferredFont(forTextStyle: .caption1),
                .foregroundColor: UIColor(white: 0.3, alpha: 1),
                .paragraphStyle : paragraphStyle
            ]
        )
    }
    
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 20
    }
    
}

extension MessageView : MessageInputBarDelegate {
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        sendMessage(text)
        inputBar.inputTextView.text = ""
    }
}

extension MessageView : ObserveMessages {
    
    func messagesDidUpdate() {
        masterMessageList = dataController.masterMessageList
        self.messagesCollectionView.reloadDataAndKeepOffset()
    }
}
