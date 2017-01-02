//
//  DataService.swift
//  CloudRook
//
//  Created by Zeeshan Khan on 02/01/2017.
//  Copyright © 2017 Caldwell Contracting LLC. All rights reserved.
//


import Foundation
import Firebase
import FirebaseAuth
import Alamofire
import SwiftyJSON



class DataService :NSObject {
    static let ds = DataService()
    var ref: FIRDatabaseReference!

    private var allFriends = [User]()
    private var pendingFriends = [User]()
    private var friendRequests = [User]()

 
    
    var getPendingFriends:[User]{
        return pendingFriends
    }
    
    var getFriends:[User]{
        return allFriends
    }
    
    
    var getFriendRequests:[User]{
        return friendRequests
    }
    
    
    //------------------------------------------------------------------------
    //------------------------------------------------------------------------
    //------------------------------------------------------------------------
    
    func addFriend(userId:String , friend:User , completion:@escaping (Bool) -> Void){
        ref = FIRDatabase.database().reference()
        ref.child("users").child(userId+"/friends/"+friend.id!).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if !snapshot.exists(){
                self.ref.child("users/\(userId)/friends/\(friend.id!)").setValue(false)
                self.ref.child("users/\(friend.id!)/friends/\(userId)").setValue("request")
                completion(true)
                
            }else{
                completion(false)
                
            }
            
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    //------------------------------------------------------------------------
    //------------------------------------------------------------------------
    //------------------------------------------------------------------------
    
    
    func removeFriendFromPendingList(userId:String , friend:User , completion:@escaping (Bool) -> Void){
        ref = FIRDatabase.database().reference()
        ref.child("users").child(userId+"/friends/"+friend.id!).observeSingleEvent(of: .value, with: { (snapshot) in
            print(snapshot.value as! Bool)
            if (snapshot.exists() && snapshot.value as! Bool == false){
                self.ref.child("users/\(userId)/friends/\(friend.id!)").removeValue()
                self.ref.child("users/\(friend.id!)/friends/\(userId)").removeValue()
                self.pendingFriends = self.pendingFriends.filter{$0.id != friend.id!}
                completion(true)
                
            }else{
                self.pendingFriends = self.pendingFriends.filter{$0.id != friend.id!}
                completion(true)
            }
            
        }) { (error) in
            print(error.localizedDescription)
            completion(false)
        }
 
    }
    
    
    //------------------------------------------------------------------------
    //------------------------------------------------------------------------
    //------------------------------------------------------------------------
    

    func removeFriendFromFriendList(userId:String , friend:User , completion:@escaping (Bool) -> Void){
        ref = FIRDatabase.database().reference()
        ref.child("users").child(userId+"/friends/"+friend.id!).observeSingleEvent(of: .value, with: { (snapshot) in
            print(snapshot.value as! Bool)
            if (snapshot.exists() && snapshot.value as! Bool == true){
                self.ref.child("users/\(userId)/friends/\(friend.id!)").removeValue()
                self.ref.child("users/\(friend.id!)/friends/\(userId)").removeValue()
                self.allFriends = self.allFriends.filter{$0.id != friend.id!}
                completion(true)
                
            }else{
                self.allFriends = self.allFriends.filter{$0.id != friend.id!}
                completion(true)
            }
            
        }) { (error) in
            print(error.localizedDescription)
            completion(false)
        }
        
    }
    


    
    //------------------------------------------------------------------------
    //------------------------------------------------------------------------
    //------------------------------------------------------------------------
    
    
    func loadAllLists(){
        let userId = FIRAuth.auth()?.currentUser?.uid
        ref = FIRDatabase.database().reference()
        var counter = 0
        ref.child("users").child(userId!+"/friends").observe(FIRDataEventType.value, with: { (snapshot) in
            self.pendingFriends.removeAll()
            self.allFriends.removeAll()
            self.friendRequests.removeAll()
            print("Started Running")
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]{

                for snap in snapshots{
                        counter += 1
                        self.ref.child("users").child(snap.key).observeSingleEvent(of: .value, with: { (snapshot) in
                            let user = User(userObject: JSON(snapshot.value!) , id:snapshot.key)

                            if let pending = snap.value as? Bool{
                                if(pending == true){
                                    self.allFriends.append(user)
                                    if(counter == snapshots.count){
                                        counter = 0
                                        self.reloadScreensNotification()
                                        
                                    }
                                }
                                else{
                                    self.pendingFriends.append(user)
                                    if(counter == snapshots.count){
                                       counter = 0
                                       self.reloadScreensNotification()
                                    }
                                }
                            }
                            else if(snap.value as! String == "request"){
                                print("friendRequests")
                                self.friendRequests.append(user)
                                if(counter == snapshots.count){
                                    counter = 0
                                    self.reloadScreensNotification()
                                }
                            }
                        })
                }
            }
            
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    
    
    //------------------------------------------------------------------------
    //------------------------------------------------------------------------
    //------------------------------------------------------------------------
    
    
    
    func confirmFriend(userId:String , friend:User , completion:@escaping (Bool) -> Void){
        ref = FIRDatabase.database().reference()
        ref.child("users").child(userId+"/friends/"+friend.id!).observeSingleEvent(of: .value, with: { (snapshot) in
            if (snapshot.exists() && snapshot.value as! String == "request"){
                self.ref.child("users/\(userId)/friends/\(friend.id!)").setValue(true)
                self.ref.child("users/\(friend.id!)/friends/\(userId)").setValue(true)
                self.friendRequests = self.friendRequests.filter{$0.id != friend.id!}
                completion(true)
                
            }else{
                self.friendRequests = self.friendRequests.filter{$0.id != friend.id!}
                completion(true)
            }
            
        }) { (error) in
            print(error.localizedDescription)
            completion(false)
        }
        
    }
    
    
    //------------------------------------------------------------------------
    //------------------------------------------------------------------------
    //------------------------------------------------------------------------
    
    private func reloadScreensNotification(){
        print("reloadScreensNotification")
        
        let pendingNotification = Notification.Name("pendingNotification")
        let requestNotification = Notification.Name("requestNotification")
        let friendNotification  = Notification.Name("friendNotification")
        
        NotificationCenter.default.post(name: pendingNotification, object: nil)
        NotificationCenter.default.post(name: requestNotification, object: nil)
        NotificationCenter.default.post(name: friendNotification, object: nil)

    }
    
    
}
