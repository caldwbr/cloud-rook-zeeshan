//
//  FriendRequestList.swift
//  CloudRook
//
//  Created by Zeeshan Khan on 03/01/2017.
//  Copyright © 2017 Caldwell Contracting LLC. All rights reserved.
//

import UIKit
import Firebase
import Firebase
import SwiftyJSON


class FriendRequestList: UITableViewController {
    
    let ds = DataService.ds
    var friendRequest = [User]()
    let notificationName = Notification.Name("requestNotification")

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(FriendRequestList.requestNotification), name: notificationName, object: nil)
        self.loadData()
        
    }
    
    
    func requestNotification(notification:Notification){
        self.loadData()
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
        self.friendRequest.removeAll()
        self.friendRequest = self.ds.getFriendRequests
        self.tableView.reloadData()
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
        return self.friendRequest.count
    }
    
    
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "friendRequestCell", for: indexPath) as! FriendRequestCell
        cell.configureCell(user: self.friendRequest[indexPath.row])
        return cell
    }
    
    
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let userId = FIRAuth.auth()?.currentUser?.uid
        let friend = self.friendRequest[indexPath.row]
        let message = "Do you want to add the friend?"
        self.showAlert(userId: userId! ,friend:friend , message:message)
        
    }
    
    
    func showAlert(userId:String , friend:User , message:String){
        let alert = UIAlertController(title: "Friend", message: message, preferredStyle:UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: {
            response in self.confirmFriend(userId: userId ,friend:friend)
        }))
        
        alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    func confirmFriend(userId:String , friend:User){
        self.ds.confirmFriend(userId: userId, friend: friend, completion:{
            response in
            if(response ==  true){
                self.loadData()
            }else{
            }
        })
    }
}
