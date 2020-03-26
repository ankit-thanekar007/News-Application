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

class UserList: ParentController {
    
    @IBOutlet private weak var tableView : UITableView!
    @IBOutlet private weak var addChannel : UIBarButtonItem!
    @IBOutlet private var backgroundView : NoDataView!
    private var db : Firestore!
    private var channel : Channel!
    
    private var channelReference: CollectionReference {
        return db.collection("channels")
    }
    
    private let dataController = ChatDataController.shared
    
    private var channels = [Channel]()
    private var channelListener: ListenerRegistration?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance()?.restorePreviousSignIn()
        dataController.delegate = self
        handleSignIn()
        listenForChannels()
        ((UIApplication.shared.delegate) as! AppDelegate).signInDelegate = self
    }
    
    func handleSignIn(){
        if (GIDSignIn.sharedInstance()?.currentUser) != nil{
            addChannel.isEnabled = true
            tableView.isHidden = false
        }else {
            addChannel.isEnabled = false
            tableView.isHidden = true
        }
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
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "MoveToMessage" {
            if let dest = segue.destination as? MessageView {
                dest.channel = channel
            }
        }
    }
    
    func createChannel(_ name : String)  {
        var jsonChannel : [String : Any] = ["channelName" : name]
        jsonChannel["channelOwner"] = GIDSignIn.sharedInstance()?.currentUser.userID ?? ""
        jsonChannel["channelCreated"] = Date.init().currentDateString()
        let emptyMessages : [[String : String]] = [[:]]
        jsonChannel["messages"] = emptyMessages
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
        tableView.backgroundView = channels.count > 0 ? nil : backgroundView
        return channels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChannelCell",
                                                 for: indexPath)
        cell.textLabel?.text = channels[indexPath.row].channelName
        cell.detailTextLabel?.text = "Created At \(channels[indexPath.row].channelCreated ?? "")" 
        cell.accessoryType = .disclosureIndicator
        return cell
    }
}

extension UserList : UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        channel = channels[indexPath.row]
        self.performSegue(withIdentifier: "MoveToMessage", sender: self)
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

extension UserList : userSignInUpdate {
    func userDidSignIn() {
        handleSignIn()
    }
}

