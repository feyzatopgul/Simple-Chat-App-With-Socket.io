//
//  ChatViewController.swift
//  MySimpleChat
//
//  Created by fyz on 9/9/22.
//

import UIKit
import MessageKit
import InputBarAccessoryView

class ChatViewController: MessagesViewController, MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate, InputBarAccessoryViewDelegate {
    
    var user: User?
    var friend: User?
    
    var currentUser = Sender(senderId: "", displayName: "")
    
    var messages = [MessageUI]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
        
        removeMessageAvatars()
        
        guard let user = user,
              let userId = user.id,
              let userName = user.nickname else {
            return
        }
       
        currentUser = Sender(senderId: userId, displayName: userName)
        
        SocketHelper.shared.getMessage {[weak self] message in
            
            guard let name = message?.nickname,
                  let dateStr = message?.date,
                  let text = message?.message,
                  let self = self else {
                return
            }
            if name != userName {
                
                guard let friend = self.friend,
                      let friendId = friend.id else {
                    return
                }

                let chatFriend = Sender(senderId: friendId , displayName: name)
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MM/dd/yyyy, h:mm:ss a"
                guard let date = dateFormatter.date(from: dateStr) else {
                    return
                }
                
                let newMessage = MessageUI(sender: chatFriend, messageId: UUID().uuidString, sentDate: date, kind: .text(text))
                
                self.messages.append(newMessage)
            }
           
            DispatchQueue.main.async {
                self.messagesCollectionView.reloadData()
                self.messagesCollectionView.scrollToLastItem(animated: true)
            }
        }
    }
    
    func currentSender() -> SenderType {
        return currentUser
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        
        messages.append(MessageUI(sender: currentUser, messageId: UUID().uuidString, sentDate: Date(), kind: .text(text)))
        
        guard let user = user,
              let userName = user.nickname else {
            return
        }
        
        SocketHelper.shared.sendMessage(message: text, nickname: userName)
        inputBar.inputTextView.text = ""
    }
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        avatarView.isHidden = true
    }
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        let corner:MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(corner, .curved)
    }
    private func removeMessageAvatars() {
        guard let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout else {
            return }
        
        layout.textMessageSizeCalculator.outgoingAvatarSize = .zero
        layout.textMessageSizeCalculator.incomingAvatarSize = .zero
        layout.setMessageIncomingAvatarSize(.zero)
        layout.setMessageOutgoingAvatarSize(.zero)
        let incomingLabelAlignment = LabelAlignment(
            textAlignment: .left,
            textInsets: UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0))
        layout.setMessageIncomingMessageTopLabelAlignment(incomingLabelAlignment)
        let outgoingLabelAlignment = LabelAlignment(
            textAlignment: .right,
            textInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 15))
        layout.setMessageOutgoingMessageTopLabelAlignment(outgoingLabelAlignment)
    }
}

