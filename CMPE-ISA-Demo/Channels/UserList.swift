//
//  UserList.swift
//  CMPE-ISA-Demo
//
//  Created by Ankit Thanekar on 07/03/20.
//  Copyright © 2020 Ankit Thanekar. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore
import GoogleSignIn

class UserList: UIViewController {
    
    @IBOutlet private weak var tableView : UITableView!
    private let db = Firestore.firestore()
    
    private var channelReference: CollectionReference {
        return db.collection("channels")
    }
    private let dataController = ChatDataController.shared
    
    private var channels = [Channel]()
    private var channelListener: ListenerRegistration?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance()?.presentingViewController = self
        dataController.delegate = self
        //        GIDSignIn.sharedInstance()?.signIn()
        listenForChannels()
    }
    
    func listenForChannels()  {
        channelListener = channelReference.addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                print("Error listening for channel updates: \(error?.localizedDescription ?? "No error")")
                return
            }
            
            snapshot.documentChanges.forEach {[weak self] change in
                self?.dataController.handleChannelUpdate(change: change)
            }
            self.channelsDidUpdate()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    
    func createChannel(_ name : String)  {
        let jsonChannel = ["channelName" : name]
        channelReference.addDocument(data: jsonChannel) { error in
            if let e = error {
                print("Error saving channel: \(e.localizedDescription)")
            }
        }
    }
    
    @IBAction func alertForChannel()  {
        let ac = UIAlertController(title: "Create a new Channel", message: nil, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        ac.addTextField { field in
            field.enablesReturnKeyAutomatically = true
            field.autocapitalizationType = .words
            field.clearButtonMode = .whileEditing
            field.placeholder = "Channel name"
            field.returnKeyType = .done
        }
        
        let createAction = UIAlertAction(title: "Create", style: .default, handler: { _ in
            if let textPresent = ac.textFields?.first?.text {
                self.createChannel(textPresent)
            }
        })
        createAction.isEnabled = true
        ac.addAction(createAction)
        ac.preferredAction = createAction
        
        present(ac, animated: true) {
            ac.textFields?.first?.becomeFirstResponder()
        }
    }
    
    //Later
    func logout(){
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
    func deleteChannelAt(index : Int) {
        let id = channels[index].channelID!
        channelReference.document(id).getDocument { (document, error) in
            if error != nil {
                print(error as Any)
            } else {
                document?.reference.delete()
            }
        }
    }
}

extension UserList : ObserveChannels {
    func channelsDidUpdate() {
        channels = dataController.masterChannelList
        tableView.reloadData()
    }
}

extension UserList : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return channels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChannelCell",
                                                 for: indexPath)
        cell.textLabel?.text = channels[indexPath.row].channelName
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
}

extension UserList : UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .destructive, title: "Delete",
          handler: { (action, view, completionHandler) in
            self.deleteChannelAt(index: indexPath.row)
            completionHandler(true)
        })
        let configuration = UISwipeActionsConfiguration(actions: [action])
        return configuration
    }
}

