//
//  ChatViewController.swift
//  SBChat
//
//  Created by Jakob Mikkelsen on 5/29/18.
//  Copyright (c) 2018 SecondBook. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit
import MapKit
import MessageKit

protocol ChatDisplayLogic: class
{
    func displaySomething(viewModel: Chat.Something.ViewModel)
}

class ChatViewController: MessagesViewController, ChatDisplayLogic
{
    var interactor: ChatBusinessLogic?
    var router: (NSObjectProtocol & ChatRoutingLogic & ChatDataPassing)?

    var messageList = [ChatMessage]()

    // ChatRoom related
    var roomID: String!
    var currentUserID: String!
    var otherUserID: String!

    // MARK: Object lifecycle

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?)
    {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }

    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        setup()
    }

    // MARK: Setup

    private func setup()
    {
        let viewController = self
        let interactor = ChatInteractor()
        let presenter = ChatPresenter()
        let router = ChatRouter()
        viewController.interactor = interactor
        viewController.router = router
        interactor.presenter = presenter
        presenter.viewController = viewController
        router.viewController = viewController
        router.dataStore = interactor
    }

    // MARK: Routing

    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if let scene = segue.identifier {
            let selector = NSSelectorFromString("routeTo\(scene)WithSegue:")
            if let router = router, router.responds(to: selector) {
                router.perform(selector, with: segue)
            }
        }
    }

    override func loadView() {

        // Remember - don't call anything UI related, as it has not been setup yet.

        // Load the messages for this ChatRoomID - Background thread!

    }

    // MARK: View lifecycle

    override func viewDidLoad()
    {
        super.viewDidLoad()

        // Fetch Messages
        self.fetchMessages()

        // MessagesViewController Delegate + DataSource
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self
        messageInputBar.delegate = self

        // Setup the UI
        self.setupUI()
    }

    fileprivate func setupUI() {

        messagesCollectionView.backgroundColor = .white
        scrollsToBottomOnKeybordBeginsEditing = true // default false
        maintainPositionOnKeyboardFrameChanged = true // default false

        // MessageInputBar
        messageInputBar.delegate = self
        messageInputBar.isTranslucent = false
        messageInputBar.backgroundView.backgroundColor = UIColor(red: 245/255, green: 245/255, blue: 245/255, alpha: 1)

        messageInputBar.separatorLine.isHidden = true
        messageInputBar.inputTextView.layer.cornerRadius = 7.5
        messageInputBar.inputTextView.layer.masksToBounds = true

        // InputTextView
        messageInputBar.inputTextView.layer.borderWidth = 0
        messageInputBar.inputTextView.backgroundColor = .white
        messageInputBar.inputTextView.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        messageInputBar.inputTextView.placeholderTextColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 0.75)
        // - LayoutMargin
        messageInputBar.inputTextView.placeholderLabelInsets.left = 10

        // Send Button
        messageInputBar.sendButton.configure {
            $0.title = "Send"
            $0.setSize(CGSize(width: 55, height: 30), animated: true)
            $0.backgroundColor = DesignUtils.shared.mainColor()
            $0.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .regular)
            $0.setTitleColor(.white, for: .normal)
            $0.setTitleColor(.white, for: .highlighted)
            $0.setTitleColor(UIColor(white: 0.9, alpha: 10), for: .disabled)
            $0.layer.cornerRadius = 10.5
            $0.layer.masksToBounds = true
            }.onSelected {
                $0.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
            }.onDeselected {
                $0.transform = CGAffineTransform.identity
            }.onTextViewDidChange { (button, textView) in
                button.messageInputBar?.setRightStackViewWidthConstant(to: textView.text.isEmpty ? 0:50, animated: true)
        }
        messageInputBar.setRightStackViewWidthConstant(to: 0, animated: false)

        /* Later version with sending image working
             let items = [
             InputBarButtonItem().configure {
             $0.image = UIImage(named: "ic_camera")?.withRenderingMode(.alwaysTemplate)
             $0.setSize(CGSize(width: 30, height: 30), animated: true)
             $0.tintColor = DesignUtils.shared.mainColor()
             }.onSelected {
             $0.tintColor = DesignUtils.shared.mainColorDark()
             }.onDeselected {
             $0.tintColor = DesignUtils.shared.mainColor()
             }.onTouchUpInside { _ in
             print("Item Tapped")
             }.onTextViewDidChange({ (button, textView) in
             button.messageInputBar?.setLeftStackViewWidthConstant(to: textView.text.isEmpty ? 25:0, animated: true)
             button.messageInputBar?.textViewPadding.left = textView.text.isEmpty ? 10:0
             })
             ]
             messageInputBar.setStackViewItems(items, forStack: .left, animated: false)
             messageInputBar.setLeftStackViewWidthConstant(to: 30, animated: false)
         */

        reloadInputViews()

    }

    // MARK: - Helpers


    // MARK: Do something

    //@IBOutlet weak var nameTextField: UITextField!

    func fetchMessages()
    {

        // Fetch messages on background thread
        DispatchQueue.global(qos: .userInitiated).async {

            let messages = [ChatMessage(text: "This is message 1", sender: Sender(id: "1", displayName: "Jakob"), messageId: "random", date: Date())]

            // Display to UI on main thread
            DispatchQueue.main.async {

                self.messageList = messages
                self.messagesCollectionView.reloadData()
                self.messagesCollectionView.scrollToBottom()
            }

        }

        let request = Chat.Something.Request()
        interactor?.doSomething(request: request)
    }

    func displaySomething(viewModel: Chat.Something.ViewModel)
    {
        //nameTextField.text = viewModel.name
    }

}

// MARK: - MessagesDataSource

extension ChatViewController: MessagesDataSource {

    func currentSender() -> Sender {
        return Sender(id: "1", displayName: "Jakob")
    }

    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messageList.count
    }

    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messageList[indexPath.section]
    }

    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if indexPath.section % 3 == 0 {
            return NSAttributedString(string: MessageKitDateFormatter.shared.string(from: message.sentDate), attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 10), NSAttributedStringKey.foregroundColor: UIColor.darkGray])
        }
        return nil
    }

    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let name = message.sender.displayName
        return NSAttributedString(string: name, attributes: [NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: .caption1)])
    }

    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        let dateString = formatter.string(from: message.sentDate)
        return NSAttributedString(string: dateString, attributes: [NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: .caption2)])
    }

}

// MARK: - MessagesDisplayDelegate

extension ChatViewController: MessagesDisplayDelegate {

    // MARK: - Text Messages

    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .white : .darkText
    }

    func detectorAttributes(for detector: DetectorType, and message: MessageType, at indexPath: IndexPath) -> [NSAttributedStringKey: Any] {
        return MessageLabel.defaultAttributes
    }

    func enabledDetectors(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> [DetectorType] {
        return [.url, .address, .phoneNumber, .date]
    }

    // MARK: - All Messages

    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? UIColor(red: 69/255, green: 193/255, blue: 89/255, alpha: 1) : UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
    }

    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(corner, .curved)
        //        let configurationClosure = { (view: MessageContainerView) in}
        //        return .custom(configurationClosure)
    }

    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        //let avatar = SampleData.shared.getAvatarFor(sender: message.sender)
        //avatarView.set(avatar: avatar)
    }

}

// MARK: - MessagesLayoutDelegate

extension ChatViewController: MessagesLayoutDelegate {

    func heightForLocation(message: MessageType, at indexPath: IndexPath, with maxWidth: CGFloat, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 50
    }

    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        if indexPath.section % 3 == 0 {
            return 10
        }
        return 0
    }

    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 16
    }

    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 16
    }

}

// MARK: - MessageCellDelegate

extension ChatViewController: MessageCellDelegate {

    func didTapAvatar(in cell: MessageCollectionViewCell) {
        print("Avatar tapped")
    }

    func didTapMessage(in cell: MessageCollectionViewCell) {
        print("Message tapped")
    }

    func didTapCellTopLabel(in cell: MessageCollectionViewCell) {
        print("Top cell label tapped")
    }

    func didTapMessageTopLabel(in cell: MessageCollectionViewCell) {
        print("Top message label tapped")
    }

    func didTapMessageBottomLabel(in cell: MessageCollectionViewCell) {
        print("Bottom label tapped")
    }

}

// MARK: - MessageLabelDelegate

extension ChatViewController: MessageLabelDelegate {

    func didSelectAddress(_ addressComponents: [String: String]) {
        print("Address Selected: \(addressComponents)")
    }

    func didSelectDate(_ date: Date) {
        print("Date Selected: \(date)")
    }

    func didSelectPhoneNumber(_ phoneNumber: String) {
        print("Phone Number Selected: \(phoneNumber)")
    }

    func didSelectURL(_ url: URL) {
        print("URL Selected: \(url)")
    }

    func didSelectTransitInformation(_ transitInformation: [String: String]) {
        print("TransitInformation Selected: \(transitInformation)")
    }

}

// MARK: - MessageInputBarDelegate

extension ChatViewController: MessageInputBarDelegate {

    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {

        // Each NSTextAttachment that contains an image will count as one empty character in the text: String

        for component in inputBar.inputTextView.components {

            if let image = component as? UIImage {

                let imageMessage = ChatMessage(image: image, sender: currentSender(), messageId: UUID().uuidString, date: Date())
                messageList.append(imageMessage)
                messagesCollectionView.insertSections([messageList.count - 1])

            } else if let text = component as? String {

                let attributedText = NSAttributedString(string: text, attributes: [.font: UIFont.systemFont(ofSize: 15), .foregroundColor: UIColor.blue])

                let message = ChatMessage(attributedText: attributedText, sender: currentSender(), messageId: UUID().uuidString, date: Date())
                messageList.append(message)
                messagesCollectionView.insertSections([messageList.count - 1])
            }

        }

        inputBar.inputTextView.text = String()
        messagesCollectionView.scrollToBottom()
    }

}
