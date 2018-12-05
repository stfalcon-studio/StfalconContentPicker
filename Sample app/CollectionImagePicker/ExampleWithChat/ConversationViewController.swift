//
//  ConversationViewController.swift
//  CollectionImagePicker
//
//  Created by Vitalii Vasylyda on 11/20/18.
//  Copyright © 2018 stFalcon. All rights reserved.
//

import UIKit
import MapKit
import MessageKit
import Photos
import AVKit
import StfalconContentPicker

// if you want to have default realization for get access to photo gallery, you will need to conform your controller to AskGalleryPermision, Alertable protocols. Or you can them self implemented AskGalleryPermision protocols method with your own realization.

class ConversationViewController: ChatViewController, Alertable, MediaPickerProtocol, AskGalleryPermision {
    let outgoingAvatarOverlap: CGFloat = 17.5

    // MARK: - AskGalleryPermision properties
    
    var allowOpenMediaPickerCallback: (() -> ())?
    
    // MARK: - MediaPickerProtocol properties
    
    var mediaPickerEventTypeCallback: ((CollectionAssetActionsType) -> ())?
    
    private var isMediaPickerIsOpen = false
    private var isNeedReloadInputView = true
    
    override func viewDidLoad() {
        becomeFirstResponder()
        messagesCollectionView = MessagesCollectionView(frame: .zero, collectionViewLayout: CustomMessagesFlowLayout())
        messagesCollectionView.register(CustomCell.self)
        super.viewDidLoad()

        updateTitleView(title: "Chat", subtitle: "2 Online")
        handleMediaPickerStates()
        
        NotificationCenter.default.addObserver(self, selector: #selector(textViewDidBeginEditing(_:)), name: UITextView.textDidBeginEditingNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardState(_:)), name: UIResponder.keyboardDidHideNotification, object: nil)
    }
  
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.isNeedReloadInputView = true
        
        MockSocket.shared.connect(with: [SampleData.shared.steven, SampleData.shared.wu])
            .onTypingStatus { [weak self] in
                self?.setTypingIndicatorHidden(false)
            }.onNewMessage { [weak self] message in
                self?.setTypingIndicatorHidden(true, performUpdates: {
                    //                    self?.insertMessage(message)
                })
                self?.insertMessage(message)
        }
    }

    override func loadFirstMessages() {
        DispatchQueue.global(qos: .userInitiated).async {
            let count = UserDefaults.standard.mockMessagesCount()
            SampleData.shared.getAdvancedMessages(count: count) { messages in
                DispatchQueue.main.async {
                    self.messageList = messages
                    self.messagesCollectionView.reloadData()
                    self.messagesCollectionView.scrollToBottom()
                }
            }
        }
    }

    override func loadMoreMessages() {
        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 1) {
            SampleData.shared.getAdvancedMessages(count: 20) { messages in
                DispatchQueue.main.async {
                    self.messageList.insert(contentsOf: messages, at: 0)
                    self.messagesCollectionView.reloadDataAndKeepOffset()
                    self.refreshControl.endRefreshing()
                }
            }
        }
    }
    
    override func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        
        for component in inputBar.inputTextView.components {
            
            if let str = component as? String {
                let message = MockMessage(text: str, sender: currentSender(), messageId: UUID().uuidString, date: Date())
                insertMessage(message)
            } else if let img = component as? UIImage {
                let message = MockMessage(image: img, sender: currentSender(), messageId: UUID().uuidString, date: Date())
                insertMessage(message)
            }
            
        }
        inputBar.inputTextView.text = String()
        messagesCollectionView.scrollToBottom(animated: true)
    }
    
    override func configureMessageCollectionView() {
        super.configureMessageCollectionView()

        let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout
        layout?.sectionInset = UIEdgeInsets(top: 1, left: 8, bottom: 1, right: 8)

        // Hide the outgoing avatar and adjust the label alignment to line up with the messages
        layout?.setMessageOutgoingAvatarSize(.zero)
        layout?.setMessageOutgoingMessageTopLabelAlignment(LabelAlignment(textAlignment: .right, textInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)))
        layout?.setMessageOutgoingMessageBottomLabelAlignment(LabelAlignment(textAlignment: .right, textInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)))

        // Set outgoing avatar to overlap with the message bubble
        layout?.setMessageIncomingMessageTopLabelAlignment(LabelAlignment(textAlignment: .left, textInsets: UIEdgeInsets(top: 0, left: 18, bottom: outgoingAvatarOverlap, right: 0)))
        layout?.setMessageIncomingAvatarSize(CGSize(width: 30, height: 30))
        layout?.setMessageIncomingMessagePadding(UIEdgeInsets(top: -outgoingAvatarOverlap, left: -18, bottom: outgoingAvatarOverlap, right: 18))

        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
    }

    override func configureMessageInputBar() {
        super.configureMessageInputBar()
        
        messageInputBar.isTranslucent = true
        messageInputBar.separatorLine.isHidden = true
        messageInputBar.inputTextView.tintColor = .primaryColor
        messageInputBar.inputTextView.backgroundColor = UIColor(red: 245/255, green: 245/255, blue: 245/255, alpha: 1)
        messageInputBar.inputTextView.placeholderTextColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
        messageInputBar.inputTextView.textContainerInset = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 36)
        messageInputBar.inputTextView.placeholderLabelInsets = UIEdgeInsets(top: 8, left: 20, bottom: 8, right: 36)
        messageInputBar.inputTextView.layer.borderColor = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1).cgColor
        messageInputBar.inputTextView.layer.borderWidth = 1.0
        messageInputBar.inputTextView.layer.cornerRadius = 16.0
        messageInputBar.inputTextView.layer.masksToBounds = true
        messageInputBar.inputTextView.scrollIndicatorInsets = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        configureInputBarItems()
    }
    
    private func configureInputBarItems() {
        messageInputBar.setRightStackViewWidthConstant(to: 36, animated: false)
        messageInputBar.sendButton.imageView?.backgroundColor = UIColor(white: 0.85, alpha: 1)
        messageInputBar.sendButton.contentEdgeInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        messageInputBar.sendButton.setSize(CGSize(width: 36, height: 36), animated: false)
        messageInputBar.sendButton.image = #imageLiteral(resourceName: "ic_up")
        messageInputBar.sendButton.title = nil
        messageInputBar.sendButton.imageView?.layer.cornerRadius = 16
        messageInputBar.textViewPadding.right = -38

        let charCountButton = InputBarButtonItem()
            .configure {
                $0.title = "0/140"
                $0.contentHorizontalAlignment = .right
                $0.setTitleColor(UIColor(white: 0.6, alpha: 1), for: .normal)
                $0.titleLabel?.font = UIFont.systemFont(ofSize: 10, weight: .bold)
                $0.setSize(CGSize(width: 50, height: 25), animated: false)
            }.onTextViewDidChange { (item, textView) in
                item.title = "\(textView.text.count)/140"
                let isOverLimit = textView.text.count > 140
                item.messageInputBar?.shouldManageSendButtonEnabledState = !isOverLimit // Disable automated management when over limit
                if isOverLimit {
                    item.messageInputBar?.sendButton.isEnabled = false
                }
                let color = isOverLimit ? .red : UIColor(white: 0.6, alpha: 1)
                item.setTitleColor(color, for: .normal)
        }
        let bottomItems = [makeButton(named: "ic_at"), makeButton(named: "ic_hashtag"), makeButton(named: "ic_library"), .flexibleSpace, charCountButton]
        messageInputBar.textViewPadding.bottom = 8
        messageInputBar.setStackViewItems(bottomItems, forStack: .bottom, animated: false)

        // This just adds some more flare
        messageInputBar.sendButton
            .onEnabled { item in
                UIView.animate(withDuration: 0.3, animations: {
                    item.imageView?.backgroundColor = .primaryColor
                })
            }.onDisabled { item in
                UIView.animate(withDuration: 0.3, animations: {
                    item.imageView?.backgroundColor = UIColor(white: 0.85, alpha: 1)
                })
        }
    }
    
    // MARK: - Helpers
    
    @IBAction func dismissButtonAction(_ sender: UIBarButtonItem) {
        messageInputBar.inputTextView.resignFirstResponder()
        messageInputBar.isHidden = true
        dismiss(animated: true)
    }
    
    // MARK: - Helpers

    func isTimeLabelVisible(at indexPath: IndexPath) -> Bool {
        return indexPath.section % 3 == 0 && !isPreviousMessageSameSender(at: indexPath)
    }

    func isPreviousMessageSameSender(at indexPath: IndexPath) -> Bool {
        guard indexPath.section - 1 >= 0 else { return false }
        return messageList[indexPath.section].sender == messageList[indexPath.section - 1].sender
    }

    func isNextMessageSameSender(at indexPath: IndexPath) -> Bool {
        guard indexPath.section + 1 < messageList.count else { return false }
        return messageList[indexPath.section].sender == messageList[indexPath.section + 1].sender
    }

    func setTypingIndicatorHidden(_ isHidden: Bool, performUpdates updates: (() -> Void)? = nil) {
        updateTitleView(title: "Chat", subtitle: isHidden ? "2 Online" : "Typing...")
    }
    
    private func makeButton(named: String) -> InputBarButtonItem {
        return InputBarButtonItem()
            .configure {
                $0.spacing = .fixed(10)
                $0.image = UIImage(named: named)?.withRenderingMode(.alwaysTemplate)
                $0.setSize(CGSize(width: 25, height: 25), animated: false)
                $0.tintColor = UIColor(white: 0.8, alpha: 1)
            }.onSelected {
                $0.tintColor = .primaryColor
            }.onDeselected {
                $0.tintColor = UIColor(white: 0.8, alpha: 1)
            }.onTouchUpInside { _ in
                self.isMediaPickerIsOpen = true
                self.checkGalleryPermisions()
        }
    }

    // MARK: - UICollectionViewDataSource

    public override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let messagesDataSource = messagesCollectionView.messagesDataSource else {
            fatalError("Ouch. nil data source for messages")
        }

        //        guard !isSectionReservedForTypingBubble(indexPath.section) else {
        //            return super.collectionView(collectionView, cellForItemAt: indexPath)
        //        }

        let message = messagesDataSource.messageForItem(at: indexPath, in: messagesCollectionView)
        if case .custom = message.kind {
            let cell = messagesCollectionView.dequeueReusableCell(CustomCell.self, for: indexPath)
            cell.configure(with: message, at: indexPath, and: messagesCollectionView)
            return cell
        }
        return super.collectionView(collectionView, cellForItemAt: indexPath)
    }

    // MARK: - MessagesDataSource

    override func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if isTimeLabelVisible(at: indexPath) {
            return NSAttributedString(string: MessageKitDateFormatter.shared.string(from: message.sentDate), attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10), NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        }
        return nil
    }

    override func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if !isPreviousMessageSameSender(at: indexPath) {
            let name = message.sender.displayName
            return NSAttributedString(string: name, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption1)])
        }
        return nil
    }

    override func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {

        if !isNextMessageSameSender(at: indexPath) && isFromCurrentSender(message: message) {
            return NSAttributedString(string: "Delivered", attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption1)])
        }
        return nil
    }

}

// MARK: - MessagesDisplayDelegate

extension ConversationViewController: MessagesDisplayDelegate {

    // MARK: - Text Messages

    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .white : .darkText
    }

    func detectorAttributes(for detector: DetectorType, and message: MessageType, at indexPath: IndexPath) -> [NSAttributedString.Key: Any] {
        return MessageLabel.defaultAttributes
    }

    func enabledDetectors(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> [DetectorType] {
        return [.url, .address, .phoneNumber, .date, .transitInformation]
    }

    // MARK: - All Messages

    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? UIColor(red: 0.30, green: 0.38, blue: 0.84, alpha: 1.0) : UIColor(red: 0.93, green: 0.93, blue: 0.93, alpha: 1.0)
    }

    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {

        var corners: UIRectCorner = []
        var tintColor = UIColor(red: 0.93, green: 0.93, blue: 0.93, alpha: 1.0)
        
        if isFromCurrentSender(message: message) {
            tintColor = UIColor(red: 0.30, green: 0.38, blue: 0.84, alpha: 1.0)
            corners.formUnion(.topLeft)
            corners.formUnion(.bottomLeft)
            corners.formUnion(.topRight)
            if !isPreviousMessageSameSender(at: indexPath) {
                corners.formUnion(.topRight)
            }
            if !isNextMessageSameSender(at: indexPath) {
                corners.formUnion(.bottomRight)
            }
        } else {
            corners.formUnion(.topRight)
            corners.formUnion(.bottomRight)
            corners.formUnion(.topLeft)
            
            if !isPreviousMessageSameSender(at: indexPath) {
                corners.formUnion(.topLeft)
            }
            if !isNextMessageSameSender(at: indexPath) {
                corners.formUnion(.bottomLeft)
            }
        }
        
        return .custom { view in
            let radius: CGFloat = 18
            let path = UIBezierPath(roundedRect: view.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
            let mask = CAShapeLayer()
            mask.path = path.cgPath
            view.layer.mask = mask
            view.tintColor = tintColor
        }
    }

    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        let avatar = SampleData.shared.getAvatarFor(sender: message.sender)
        avatarView.set(avatar: avatar)
        avatarView.isHidden = isNextMessageSameSender(at: indexPath)
        avatarView.layer.borderWidth = 2
        avatarView.layer.borderColor = UIColor.primaryColor.cgColor
    }

    func configureAccessoryView(_ accessoryView: UIView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        // Cells are reused, so only add a button here once. For real use you would need to
        // ensure any subviews are removed if not needed
        guard accessoryView.subviews.isEmpty else { return }
        let button = UIButton(type: .infoLight)
        button.tintColor = .primaryColor
        accessoryView.addSubview(button)
        button.frame = accessoryView.bounds
        button.isUserInteractionEnabled = false // respond to accessoryView tap through `MessageCellDelegate`
        accessoryView.layer.cornerRadius = accessoryView.frame.height / 2
        accessoryView.backgroundColor = UIColor.primaryColor.withAlphaComponent(0.3)
    }

    // MARK: - Location Messages

    func annotationViewForLocation(message: MessageType, at indexPath: IndexPath, in messageCollectionView: MessagesCollectionView) -> MKAnnotationView? {
        let annotationView = MKAnnotationView(annotation: nil, reuseIdentifier: nil)
        let pinImage = #imageLiteral(resourceName: "ic_map_marker")
        annotationView.image = pinImage
        annotationView.centerOffset = CGPoint(x: 0, y: -pinImage.size.height / 2)
        return annotationView
    }

    func animationBlockForLocation(message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> ((UIImageView) -> Void)? {
        return { view in
            view.layer.transform = CATransform3DMakeScale(2, 2, 2)
            UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0, options: [], animations: {
                view.layer.transform = CATransform3DIdentity
            }, completion: nil)
        }
    }

    func snapshotOptionsForLocation(message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> LocationMessageSnapshotOptions {

        return LocationMessageSnapshotOptions(showsBuildings: true, showsPointsOfInterest: true, span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10))
    }

}

// MARK: - MessagesLayoutDelegate

extension ConversationViewController: MessagesLayoutDelegate {

    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        if isTimeLabelVisible(at: indexPath) {
            return 18
        }
        return 0
    }

    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        if isFromCurrentSender(message: message) {
            return !isPreviousMessageSameSender(at: indexPath) ? 20 : 0
        } else {
            return !isPreviousMessageSameSender(at: indexPath) ? (20 + outgoingAvatarOverlap) : 0
        }
    }

    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return (!isNextMessageSameSender(at: indexPath) && isFromCurrentSender(message: message)) ? 16 : 0
    }

}

// MARK: - MediaPicker methods

extension ConversationViewController {
    @objc private func textViewDidBeginEditing(_ notification: Notification) {
        if !isMediaPickerIsOpen {
            self.messageInputBar.inputTextView.inputView = nil
            self.messageInputBar.inputTextView.reloadInputViews()
        }
    }
    
    @objc private func handleKeyboardState(_ notification: Notification) {
        if isNeedReloadInputView {
            self.messageInputBar.inputTextView.inputView = nil
            self.messageInputBar.inputTextView.reloadInputViews()
            isMediaPickerIsOpen = false
        }
    }
    
    func getCollectionAssetView() -> CollectionAssetView {
        // you can inherit from Collection Asset View and create your own class with custom UI elemenets.
        return CollectionAssetView.loadFromNib()
    }
    
    func handleMediaPickerStates() {
        // in this method we are handle all states that has collection Asset view
        
        mediaPickerEventTypeCallback = { [unowned self] action in
            switch action {
            case .didDeselectedItem(let mediaAsset):
                print(mediaAsset)
                
            case .didSelectedItem(let mediaAsset):
                print(mediaAsset)
                
            case .didTapOnImage(let mediaAsset):
                print(mediaAsset)
                
            case .didTapOnVideo(let mediaAsset):
                self.isNeedReloadInputView = false
                self.showVideoWith(mediaAsset.url)
                
            case .didDinishSelectedAssets(let mediaAssets):
                // send our selected assets and reload input view for text view for display normal keyboard after user will start enter some text in text view.
                self.sendMediaMessages(mediaAssets)
                self.messageInputBar.inputTextView.resignFirstResponder()
                self.isMediaPickerIsOpen = false
                self.isNeedReloadInputView = true
                self.messageInputBar.inputTextView.inputView = nil
                self.messageInputBar.inputTextView.reloadInputViews()
            }
        }
        
        // handle state if user has permission for use gallery
        allowOpenMediaPickerCallback = { [weak self] in
            guard let textView = self?.messageInputBar.inputTextView else { return }
            // send text view or text field as parametr. Need for add media picker view as input view to view.
            self?.showMediaPickerWithInputView(view: textView)
            textView.reloadInputViews()
        }
    }
    
    private func sendMediaMessages(_ mediaAssets: [MediaAsset]) {
        mediaAssets.forEach { item in
            let message = MockMessage(image: item.preview!, sender: currentSender(), messageId: UUID().uuidString, date: Date())
            insertMessage(message)
        }
        
        messagesCollectionView.scrollToBottom(animated: true)
    }
    
    private func showVideoWith(_ url: URL?) {
        guard let url = url else { return }
        
        let playerVC = AVPlayerViewController()
        playerVC.player = AVPlayer(url: url)
        
        present(playerVC, animated: true) {
            playerVC.player?.play()
        }
    }
}
