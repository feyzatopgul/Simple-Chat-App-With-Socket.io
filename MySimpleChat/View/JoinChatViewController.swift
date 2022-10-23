//
//  JoinChatViewController.swift
//  MySimpleChat
//
//  Created by fyz on 9/9/22.
//

import UIKit

class JoinChatViewController: UIViewController {
    
    private var joinButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configureButton()
        
    }
    func configureButton() {
        joinButton.setTitle("Join Chat", for: .normal)
        joinButton.setTitleColor(.white, for: .normal)
        joinButton.frame = CGRect(x: 0, y: 0, width: 200, height: 50)
        joinButton.backgroundColor = .orange
        view.addSubview(joinButton)
        joinButton.center = view.center
        joinButton.addTarget(self, action: #selector(joinRoom), for: .touchUpInside)
    }
    
    @objc func joinRoom(){
        
        let alertVc = UIAlertController(title: "", message: "Please enter a name:", preferredStyle: .alert)
        alertVc.addTextField(configurationHandler: nil)
        alertVc.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alertVc.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
            guard let textFields = alertVc.textFields else {
                return
            }
            let textField = textFields[0]
            
            if textField.text?.count != 0 {
                guard let nickname = textField.text else {
                    return
                }
                SocketHelper.shared.joinChat(nickname: nickname) { [weak self] in
                    let chatListVc = ChatListViewController()
                    chatListVc.nickname = nickname
                    self?.navigationController?.pushViewController(chatListVc, animated: true)
                }
            }
        }))
        present(alertVc, animated: true)
    }
}


