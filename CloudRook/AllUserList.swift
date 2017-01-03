//
//  friendListTableViewController.swift
//  CloudRook
//
//  Created by Brad Caldwell on 1/1/17.
//  Copyright © 2017 Caldwell Contracting LLC. All rights reserved.
//

import UIKit
import Firebase
import SwiftyJSON

class AllUserList: UITableViewController {

    var users = [User]()
    let ds = DataService.ds
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Total Users")
        print(self.users.count)
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        self.tabBarController?.tabBar.isHidden = false;
//        self.navigationController?.hidesBottomBarWhenPushed = false
//        self.navigationController?.navigationBar.isHidden = false
//        self.navigationController?.navigationBar.isTranslucent = false;
        
        
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        self.tabBarController?.navigationItem.title = "All Users"
        
        
        
        //navigationController?.navigationItem.title = "All1"
        //navigationController?.navigationBar.topItem?.title = "All2"
//       navigationItem.title = "YourTitle"
//       navigationController?.title = "All4"
        
        

//        let yourBackImage = UIImage(named: "Green9")
//        self.navigationController?.navigationBar.backIndicatorImage = yourBackImage
//        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = yourBackImage
        
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
       // self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    
    @IBAction func backTapped(_ sender: Any) {
        navigationController?.popViewController(animated:true)
        //self.dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.users.count
    }

    
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "allUserCell", for: indexPath) as! AllUserCell
        cell.configureCell(user: self.users[indexPath.row])
        return cell
    }
 
    
    

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let userId = FIRAuth.auth()?.currentUser?.uid
        let friend = self.users[indexPath.row]
        let message = "A friend request has been sent"
        let alert   = "Already sent a friend request"
        
        self.ds.addFriend(userId: userId!, friend: friend, completion:{
            response in
            if(response ==  true){
                self.showAlert(message: message)
            }else{
                self.showAlert(message: alert)
            }
        })

    }

    
    
    
    func showAlert(message:String){
        let alert = UIAlertController(title: "Friend Request", message: message, preferredStyle:UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
}
