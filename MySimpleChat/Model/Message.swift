//
//  Message.swift
//  MySimpleChat
//
//  Created by fyz on 9/9/22.
//

import Foundation
import MessageKit

struct Sender: SenderType {
    var senderId: String
    var displayName: String
}

struct MessageUI: MessageType {
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
}

struct Message: Codable {
    var date: String?
    var message: String?
    var nickname: String?
}
