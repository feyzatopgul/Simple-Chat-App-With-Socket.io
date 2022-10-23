//
//  SocketHelper.swift
//  MySimpleChat
//
//  Created by fyz on 9/9/22.
//

import Foundation
import SocketIO

class SocketHelper: NSObject {
    
    static let shared = SocketHelper()
    
    private var manager: SocketManager?
    
    let host = "http://IP:Port"
    let connectUser = "connectUser"
    let userList = "userList"
    let exitUser = "exitUser"
    
    override init() {
        super.init()
        configureSocketClient()
    }
    
    private func configureSocketClient() {
        guard let url = URL(string: host) else {
            return
        }
        manager = SocketManager(socketURL: url, config: [.log(true), .compress])
    }
    func establishConnection() {
        guard let socket = manager?.defaultSocket else {
            return
        }
        socket.connect()
    }
    func closeConnection() {
        guard let socket = manager?.defaultSocket else {
            return
        }
        socket.disconnect()
    }
    func joinChat(nickname: String, completion: ()-> Void) {
        guard let socket = manager?.defaultSocket else {
            return
        }
        socket.emit(connectUser, nickname)
        completion()
    }
    func leaveChat(nickname: String, completion: ()-> Void) {
        guard let socket = manager?.defaultSocket else {
            return
        }
        socket.emit(exitUser, nickname)
        completion()
    }
    func getUserList(completion: @escaping (_ users:[User]?) -> Void){
        guard let socket = manager?.defaultSocket else {
            return
        }
        socket.on(userList) { (result, ack) -> Void in
            guard let data = result[0] as? [[String: Any]] else {
                return
            }
            
            if let users: [User] = try? SocketParser.convert(data: data) {
                completion(users)
            }
        }
    }
    func sendMessage(message: String, nickname: String) {
        guard let socket = manager?.defaultSocket else {
            return
        }
        socket.emit("chatMessage", nickname, message)
    }
    func getMessage(completion: @escaping (_ message: Message? ) -> Void){
        guard let socket = manager?.defaultSocket else {
            return
        }
        socket.on("newChatMessage") { (result, ack) -> Void in
            var messageInfo = [String: Any]()
            
            guard let nickname = result[0] as? String,
                  let message = result[1] as? String,
                  let date = result[2] as? String else {
                return
            }
            messageInfo["nickname"] = nickname
            messageInfo["message"] = message
            messageInfo["date"] = date
            
            if let message: Message = try? SocketParser.convert(data: messageInfo) {
                completion(message)
            }
        }
    }
}
