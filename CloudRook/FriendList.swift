//
//  FriendList.swift
//  CloudRook
//
//  Created by Zeeshan Khan on 03/01/2017.
//  Copyright © 2017 Caldwell Contracting LLC. All rights reserved.
//

import UIKit
import Firebase
import Firebase
import SwiftyJSON


class FriendList: UITableViewController {
    
    let ds = DataService.ds
    var friends = [User]()
    
    @IBOutlet weak var totalInvited: UIBarButtonItem!
    
    let notificationName = Notification.Name("friendNotification")

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
     NotificationCenter.default.addObserver(self, selector: #selector(FriendList.friendNotification), name: notificationName, object: nil)
        self.tabBarController?.navigationItem.title = "Friends"
        self.loadData()
    }
    
    
    func friendNotification(notification:Notification){
        self.loadData()
    }

    
    
    @IBAction func totalInvitedAction(_ sender: UIBarButtonItem) {
        
        if(self.ds.getInvitedUser.count < 3){
            let message = "You must add 3 Users to Invite"
            self.showInvitationAlert(message:message)
        }
        else{
            self.ds.sendGameInvitation(){response in
                if(response == true){
                    self.ds.removeInvitedUser()
                    let message = "We have sent game invitations. Please go to Main screen to play"
                    self.showInvitationAlert(message:message)
                }else{
                    let message = "An Error occured. Please try again"
                    self.showInvitationAlert(message:message)
                }

            }
        }
    }
    

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: notificationName, object: nil);
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadData(){
        self.friends.removeAll()
        self.friends = self.ds.getFriends
        self.tableView.reloadData()
        if(self.ds.getInvitedUser.count > 0){
            self.totalInvited.title = "Send"
            //self.cancelInvite.title = "Cancel"
        }else{
            self.totalInvited.title = ""
            //self.cancelInvite.title = ""
        }
        
    }
    
    
    //    @IBAction func backTapped(_ sender: Any) {
    //        navigationController?.popViewController(animated:true)
    //        //self.dismiss(animated: true, completion: nil)
    //    }
    //
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.friends.count
    }
    
    
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "allFriendCell", for: indexPath) as! AllFriendCell
        let user = self.friends[indexPath.row]
        cell.configureCell(user: user)
        cell.inviteCallback = { response in
            if(self.ds.getInvitedUser.count < 3){
                if(self.ds.invitedUserIds.contains(user.id!)){
                    self.ds.removeInvitedUser(userId: user.id!)
                    self.ds.invitedUserIds = self.ds.invitedUserIds.filter{$0 != user.id!}
                    
                    if(self.ds.getInvitedUser.count > 0){
                        self.totalInvited.title = "Send"
                        //self.cancelInvite.title = "Cancel"
                    }else{
                        self.totalInvited.title = ""
                        //self.cancelInvite.title = ""
                    }
                    cell.inviteButton.layer.borderWidth = 0
                    cell.inviteButton.layer.borderColor = UIColor.clear.cgColor
                    print("Two : \(self.ds.getInvitedUser.count )")

                }else{
                    
                    self.ds.addInvitedUser(user: user)
                    self.ds.invitedUserIds.append(user.id!)
                    
                    self.totalInvited.title = "Send"
                    //self.cancelInvite.title = "Cancel"
                    
                    cell.inviteButton.layer.borderWidth = 2
                    cell.inviteButton.layer.borderColor = UIColor.orange.cgColor
                    print("One : \(self.ds.getInvitedUser.count )")

                }

            }
            else if(self.ds.getInvitedUser.count ==  3 && self.ds.invitedUserIds.contains(user.id!)){
                self.ds.removeInvitedUser(userId: user.id!)
                self.ds.invitedUserIds = self.ds.invitedUserIds.filter{$0 != user.id!}
                
                if(self.ds.getInvitedUser.count > 0){
                    self.totalInvited.title = "Send"
                    //self.cancelInvite.title = "Cancel"
                }else{
                    self.totalInvited.title = ""
                    //self.cancelInvite.title = ""
                }
                cell.inviteButton.layer.borderWidth = 0
                cell.inviteButton.layer.borderColor = UIColor.clear.cgColor
                print("Three : \(self.ds.getInvitedUser.count )")
            }
            else{
                let message = "You have already added 3 Users to Invite . To Invite other this user, please uncheck other user ."
                self.showInvitationAlert(message:message)
            }
        }
        
        if(DataService.ds.getInvitedUser.count == 0){
            self.totalInvited.title = ""
            cell.inviteButton.layer.borderWidth = 0
            cell.inviteButton.layer.borderColor = UIColor.clear.cgColor
        }
        return cell
    }
    

    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let userId = FIRAuth.auth()?.currentUser?.uid
        let friend = self.friends[indexPath.row]
        let message = "Do you want to delete the friend from list"
        self.showAlert(userId: userId! ,friend:friend , message:message)

    }
    
    
    func showAlert(userId:String , friend:User , message:String){
        let alert = UIAlertController(title: "Friend", message: message, preferredStyle:UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: {
            response in self.removeFriend(userId: userId ,friend:friend)
        }))
        
        alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
    func showInvitationAlert(message:String){
        let alert = UIAlertController(title: "Invite", message: message, preferredStyle:UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {
            response in
            self.tableView.reloadData()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
    
    
    func removeFriend(userId:String , friend:User){
        self.ds.removeFriendFromFriendList(userId: userId, friend: friend, completion:{
            response in
            if(response ==  true){
                self.loadData()
            }else{
            }
        })
    }
    
    

    
}
