//
//  ChatListViewController.swift
//  MySimpleChat
//
//  Created by fyz on 9/9/22.
//

import UIKit

class ChatListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var nickname:String = ""
    var users:[User] = []
    var currentUser: User?
    
    private var chatListTableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Welcome \(nickname)"
        configureTableView()
        createExitButton()
        
        navigationItem.hidesBackButton = true
        
        SocketHelper.shared.getUserList { [weak self] userList in
            guard let userList = userList else {
                return
            }
            var otherUsers = userList
            if let index = otherUsers.firstIndex(where: {$0.nickname == self?.nickname}) {
                self?.currentUser = otherUsers.remove(at: index)
            }
            self?.users = otherUsers
            DispatchQueue.main.async {
                self?.chatListTableView.reloadData()
            }
        }
    }
    func configureTableView() {
        
        chatListTableView.delegate = self
        chatListTableView.dataSource = self
        
        view.addSubview(chatListTableView)
        chatListTableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            chatListTableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            chatListTableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            chatListTableView.topAnchor.constraint(equalTo: view.topAnchor),
            chatListTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        
        chatListTableView.register(ChatListCell.self, forCellReuseIdentifier: "ChatListCell")
        
    }
    func createExitButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Exit",
            style: .done,
            target: self,
            action: #selector(exitRoom))
    }
    
    @objc func exitRoom() {
        SocketHelper.shared.leaveChat(nickname: nickname) {
            navigationController?.popViewController(animated: true)
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ChatListCell", for: indexPath) as? ChatListCell else {
            return UITableViewCell() }
        
        cell.selectionStyle = .none
        cell.accessoryType = .disclosureIndicator
        cell.nameLabel.text  = users[indexPath.row].nickname
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let chatVc = ChatViewController()
        chatVc.user = currentUser
        chatVc.friend = users[indexPath.row]
        navigationController?.pushViewController(chatVc, animated: true)
    }
        
   

}

