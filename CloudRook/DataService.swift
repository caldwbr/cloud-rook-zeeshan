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
import OneSignal



class DataService :NSObject {
    
    static let ds = DataService()
    var ref: FIRDatabaseReference!

    var gameUser = User()
    
    var users = [User]()
    private var allFriends = [User]()       // Friends of current user
    private var pendingFriends = [User]()   // Pending friends sent by current user
    private var friendRequests = [User]()   // Friend request received by current user
    private var onlineUsers = [String]()    // All online users in the Database
    
    private var gameKey = String()          // Acurrent game id in the process
    var invitedUserIds = [String]()         // Invited users ids that will be invited
    var gameIsOn = false                    // Check for if a game is in process or not

    private var invitedUser = [User]() // All users for game invitation. Removed once the invite is sent
    
    private var currentGameUser = [User]()  // Current game users
    private var gameInvitations = [GameInvite]() // Game invites sent to you
    private var gameAcceptStatus = [Any]()


    
    
    // Game user is the current user of the application
    func createGameUser(){
        let user = FIRAuth.auth()?.currentUser
        self.gameUser.id = user?.uid
        self.gameUser.email = user?.email!
        self.gameUser.picUrl = user?.photoURL as NSURL?
        self.gameUser.name = user?.displayName
    }
    
    // Return all friends
    var getFriends:[User]{return allFriends }
    
    // Return all pending requests sent by user
    var getPendingFriends:[User]{return pendingFriends}
    
    // Return all friend requests received by user
    var getFriendRequests:[User]{return friendRequests}
    
    // Return all online users
    var getOnlineUsers:[String]{return onlineUsers}


    //------------------------------------------------------------------------
    // Return all the users invited to a game
    var getInvitedUser:[User]{return invitedUser}
    
    // Return the game user which is "self" or current user of the app.
    var getGameUser:User{return self.gameUser}
    
    // Return all the game invitations received by a user
    var getGameInvitations:[GameInvite]{return self.gameInvitations}
    
    // Return all the game users that are playing a game. 4 Users in total
    var getCurrentGameUser:[User]{return currentGameUser}
    
    // Return the game accept status of all the game users
    var getGameAcceptStatus:[Any]{return gameAcceptStatus}
    //------------------------------------------------------------------------
    
    // Remove all the invited users once the invitation has been sent
    func removeInvitedUser(){self.invitedUser.removeAll() }
    
    // Add a user to Invite later when the invitation will be sent
    func addInvitedUser(user:User){self.invitedUser.append(user)}
    
    // Remove a user from invitation list before the invitation is sent.
    func removeInvitedUser(userId:String){
        self.invitedUser = self.invitedUser.filter{$0.id != userId}
    }
    
    // Return all the users playing in current game.
    func removeCurrentGameUser(){
        self.currentGameUser.removeAll()
    }
    

    func setGamekey(){
        self.gameKey = ""
    }
    
    //------------------------------------------------------------------------
    //------------------------------------------------------------------------
    //------------------------------------------------------------------------
    
    // Check if the current user is connected or not.
    func checkIfConnected(){
        let connectedRef = FIRDatabase.database().reference(withPath: ".info/connected")
        let user = FIRAuth.auth()?.currentUser?.uid
        
        connectedRef.observe(.value, with: { snapshot in
            if let connected = snapshot.value as? Bool, connected {
                self.ref.child("users").child(user! + "/connected").setValue(true)
                self.ref.child("users").child(user! + "/connected").onDisconnectSetValue(false)
            }
            else {
                self.ref.child("users").child(user! + "/connected").onDisconnectSetValue(false)
            }
        })
    }
    
    // Add a friend
    func addFriend(userId:String , friend:User , completion:@escaping (Bool) -> Void){
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
    
    
    // Remove a Friend From Pending List
    func removeFriendFromPendingList(userId:String , friend:User , completion:@escaping (Bool) -> Void){
        ref.child("users").child(userId+"/friends/"+friend.id!).observeSingleEvent(of: .value, with: { (snapshot) in
            //print(snapshot.value as! Bool)
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
    
    // Remove a Friend From Friend List
    func removeFriendFromFriendList(userId:String , friend:User , completion:@escaping (Bool) -> Void){
        ref.child("users").child(userId+"/friends/"+friend.id!).observeSingleEvent(of: .value, with: { (snapshot) in
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
    
    
    // Load all friends array and check which are in pending, approved etc at the start of the app.
    func loadAllLists(){
        
        let userId = FIRAuth.auth()?.currentUser?.uid
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

                                }
                                else{
                                    self.pendingFriends.append(user)
                                }
                            }
                            else if(snap.value as! String == "request"){
                                self.friendRequests.append(user)
                            }
                            
                            if(snapshots.count == self.allFriends.count +  self.friendRequests.count +  self.pendingFriends.count){
                                self.reloadScreensNotification()
                                self.greenDotForConnectedUers(loadAll:true)
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
    
    
    // Confirm or accept a friend request sent by another user
    func confirmFriend(userId:String , friend:User , completion:@escaping (Bool) -> Void){
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
        let pendingNotification =           Notification.Name("pendingNotification")
        let requestNotification =           Notification.Name("requestNotification")
        let friendNotification  =           Notification.Name("friendNotification")
        let gameUserOnlineNotification  =   Notification.Name("gameUserOnlineNotification")
        
        NotificationCenter.default.post(name: pendingNotification, object: nil)
        NotificationCenter.default.post(name: requestNotification, object: nil)
        NotificationCenter.default.post(name: friendNotification, object: nil)
        NotificationCenter.default.post(name: gameUserOnlineNotification, object: nil)

        
    }
    

    //------------------------------------------------------------------------
    //------------------------------------------------------------------------
    //------------------------------------------------------------------------
    
    func greenDotForConnectedUers(loadAll:Bool){
        let users = self.users

        self.onlineUsers.removeAll()
        var loadAll = loadAll
        var counter = 0
        for user in users{
            ref.child("users").child(user.id!+"/connected").observe(FIRDataEventType.value, with: { (snapshot) in
                let snapshot = snapshot.value as? Bool
                counter += 1
                if(snapshot == true){
                    
                    if(self.onlineUsers.contains(user.id!)){
                    }
                    else{
                        self.onlineUsers.append(user.id!)
                    }
                    
                }else{
                    if(self.onlineUsers.contains(user.id!)){
                        self.onlineUsers =  self.onlineUsers.filter{$0 != user.id!}
                    }
                }
                
                if(loadAll == false){
                   self.reloadScreensNotification()
                }
                if(counter == users.count && loadAll == true){
                    loadAll = false
                    counter = 0
                    self.reloadScreensNotification()
                }
                
                
            }) { (error) in
                print(error.localizedDescription)
            }
        }
    
    }
    
    
    //------------------------------------------------------------------------
    //------------------------------------------------------------------------
    //------------------------------------------------------------------------
    
    
    func sendGameInvitation(completion:@escaping (Bool) -> Void){
        
        let user = FIRAuth.auth()?.currentUser?.uid
        let usersId = self.invitedUserIds

        if(gameKey != ""){
            self.ref.child("games").child(gameKey).removeValue()
            self.ref.child("users").child("\(self.currentGameUser[1].id!)/games/\(gameKey)").removeValue()
            self.ref.child("users").child("\(self.currentGameUser[2].id!)/games/\(gameKey)").removeValue()
            self.ref.child("users").child("\(self.currentGameUser[3].id!)/games/\(gameKey)").removeValue()
            self.currentGameUser.removeAll()
            self.gameIsOn = false
        }
        
        
        self.gameKey = ref.child("games").childByAutoId().key
        let game = ["\(user!)": ["accept":true , "number":1],
                    "\(usersId[0])": ["accept":false , "number":2],
                    "\(usersId[1])": ["accept":false , "number":3],
                    "\(usersId[2])": ["accept":false , "number":4],
                    "owner":"\(user!)"] as [String : Any]
        
        let childUpdates = ["/games/\(gameKey)": game]
        ref.updateChildValues(childUpdates){
            response in
            if((response.0) != nil){
                completion(false)
            }else{
                self.gameIsOn = true
                

                self.invitedUserIds.removeAll()
                self.currentGameUser = self.invitedUser
                self.currentGameUser.insert(self.gameUser, at: 0)
                
                self.sendPushNotification(usersId: usersId,  completion:{ _ in})
                
                print("Current Game Users : \(self.currentGameUser.count)")
                print(self.gameUser.email!)
                for x in 0...3{
                    print("Player Name\(self.currentGameUser[x].name!)")
                }
                
                //self.ref.child("games").child(self.gameKey).onDisconnectRemoveValue()
                
                self.ref.child("users").child("\(self.currentGameUser[1].id!)/games").child(self.gameKey).setValue(true)
                self.ref.child("users").child("\(self.currentGameUser[2].id!)/games").child(self.gameKey).setValue(true)
                self.ref.child("users").child("\(self.currentGameUser[3].id!)/games").child(self.gameKey).setValue(true)
                
                 //self.ref.child("users").child("\(self.currentGameUser[1].id!)/games").child(self.gameKey).onDisconnectRemoveValue()
                //self.ref.child("users").child("\(self.currentGameUser[2].id!)/games").child(self.gameKey).onDisconnectRemoveValue()
                //self.ref.child("users").child("\(self.currentGameUser[3].id!)/games").child(self.gameKey).onDisconnectRemoveValue()
                
                completion(true)
            }
        }
        
        var addNewId = usersId
        addNewId.insert(user!, at: 0)
        self.gameAcceptUserCheck(usersId:addNewId)
  
    }
    
    
    func gameAcceptUserCheck(usersId:[String]){
        
        gameAcceptStatus = [true , false ,false,false]

        var counter = 0
        
        for id in usersId{
            self.ref.child("games").child(gameKey).child("\(id)/accept").observe(FIRDataEventType.value, with: { (snapshot) in
                                let snapshot = snapshot.value
                if(counter < 4){
                    counter += 1
                }
                if(snapshot as? Bool == true){
                    let indexOf = usersId.index(of: id)
                    self.gameAcceptStatus[indexOf!] = true
                }
                
                if let text = snapshot as? String{
                    if(text == "reject"){
                        let indexOf = usersId.index(of: id)
                        self.gameAcceptStatus[indexOf!] = "reject"
                        
                    }
                    
                    if(text == "left"){
                        let indexOf = usersId.index(of: id)
                        self.gameAcceptStatus[indexOf!] = "left"
                        
                    }
                }

                print(self.gameAcceptStatus)
                print(counter)
                if(counter == 4){
                    print("Check Game Status")
                    let gameStatusNotification  = Notification.Name("gameStatusNotification")
                    NotificationCenter.default.post(name: gameStatusNotification, object: nil)

                }
                
                
            }) { (error) in
                print(error.localizedDescription)
            }
        }
    }
    

    //------------------------------------------------------------------------
    //------------------------------------------------------------------------
    //------------------------------------------------------------------------
    
    
    func checkInvitations(){
        let user = FIRAuth.auth()?.currentUser?.uid
        var invitedGameUser = [User]()
        invitedGameUser = [self.gameUser ,self.gameUser ,self.gameUser , self.gameUser]
        
        
        print("Check Invitation Observer")
        
        
            ref.child("users").child("\(user!)/games").observe(.value, with: { (snapshot) in
                self.gameInvitations.removeAll()
                if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]{

                     for snap in snapshots{
                        if(snap.value as! Bool == true){
                        self.ref.child("games").child(snap.key).observeSingleEvent(of: .value, with: { (snapshot) in
                             let snapshot = JSON(snapshot.value!)
                             var keys = [String]()
                            
                            
                             for id in snapshot{
                                keys.append(id.0)
                                if(id.0 != "owner"){
                                    if(id.1["number"] == 1){
                                        if let user =  self.users.filter({$0.id! == id.0}).first{
                                            invitedGameUser[0] = user
                                        }else if(id.0 == self.gameUser.id){
                                            
                                            invitedGameUser[0] = self.gameUser
                                        }
                                    }
                                    
                                    
                                    if(id.1["number"] == 2){
                                        if let user =  self.users.filter({$0.id! == id.0}).first{
                                            invitedGameUser[1] = user
                                        }
                                        else if(id.0 == self.gameUser.id){
                                            invitedGameUser[1] = self.gameUser
                                        }
                                    }
                                    if(id.1["number"] == 3){
                                        if let user =  self.users.filter({$0.id! == id.0}).first{
                                            invitedGameUser[2] = user
                                        }
                                        else if(id.0 == self.gameUser.id){
                                            invitedGameUser[2] = self.gameUser
                                        }
                                    }
                                    if (id.1["number"] == 4){
                                        if let user =  self.users.filter({$0.id! == id.0}).first{
                                            invitedGameUser[3] = user
                                        }
                                        else if(id.0 == self.gameUser.id){
                                            invitedGameUser[3] = self.gameUser
                                        }
                                    }
                                }
  
                             }

                            let checkInviteInArray = self.gameInvitations.contains{ $0.id == snap.key}
                            if(checkInviteInArray == false){
                                let ownerName = invitedGameUser[0].name
                                let id = snap.key
                                let game = GameInvite(ownerName: ownerName!, id: id, gamers: invitedGameUser)
                                self.gameInvitations.append(game)
                               // print("game Invitations \(self.gameInvitations.count)")
                                let gameInvitationNotification  = Notification.Name("gameInvitationNotification")
                                NotificationCenter.default.post(name: gameInvitationNotification, object: nil)
                            }
                        })
                        }else{
                            
                        }
                }
            }
            })
            { (error) in
                print(error.localizedDescription)
            }
    }
    
    
    //------------------------------------------------------------------------
    //------------------------------------------------------------------------
    //------------------------------------------------------------------------
    
    
    func acceptGameInvitation(usersId:[String] , game:GameInvite , completion:(Bool) -> Void){
        print("Accept Game Invitation-1")
        print(game.id!)
        print(self.gameUser.id!)
        self.ref.child("games").child("\(game.id!)/\(self.gameUser.id!)").child("accept").setValue(true)
        self.ref.child("users").child("\(self.gameUser.id!)/games/\(game.id!)/").setValue(false)

        self.gameKey = game.id!
        self.gameAcceptUserCheck(usersId: usersId)
        print(usersId)
        self.currentGameUser.removeAll()
        self.currentGameUser.append(game.owner!)
        self.currentGameUser.append(game.playerOne!)
        self.currentGameUser.append(game.playerTwo!)
        self.currentGameUser.append(game.playerThree!)
        completion(true)
    }
    
    
    
    func acceptGameInvitation(usersId:[String] , gameId:String , completion:(Bool) -> Void){
        print("Accept Game Invitation-2")
        print(gameId)
        print(self.gameUser.id!)
        self.ref.child("games").child("\(gameId)/\(self.gameUser.id!)").child("accept").setValue(true)
        self.ref.child("users").child("\(self.gameUser.id!)/games/\(gameId)/").setValue(false)
        self.gameKey = gameId
        self.gameAcceptUserCheck(usersId: usersId)
        print(usersId)
        completion(true)
    }
    
    
    func rejectGameInvitation(gameId:String){
        self.ref.child("games").child("\(gameId)/\(self.gameUser.id!)").child("accept").setValue("reject")
        self.ref.child("users").child("\(self.gameUser.id!)/games/\(gameId)/").removeValue()
    }
    
    
    
    
    func getUsersData(usersId:[String] ,  completion:@escaping (Bool) -> Void){
        
        var gameUsers = [User]()
        gameUsers = [self.gameUser ,self.gameUser ,self.gameUser , self.gameUser]
        var usersCount = 0
        
        for id in usersId{
             self.ref.child("users").child(id).observeSingleEvent(of: .value, with: {
                (snapshot) in
                let user = User(userObject: JSON(snapshot.value!) , id:snapshot.key)
                let indexOf = usersId.index(of: id)
                gameUsers[indexOf!] = user
                usersCount += 1
                if(usersCount == 4){
                    self.currentGameUser = gameUsers
                    completion(true)
                }
             
             })
        }
    }
    
    
    
    //------------------------------------------------------------------------
    //------------------------------------------------------------------------
    //------------------------------------------------------------------------
    
    func leaveGame(completion:(Bool)->Void){

        if(self.currentGameUser.count != 0){
            if(self.gameUser.id == self.currentGameUser[0].id!){
                print("Leave Game - 1")
                self.ref.child("games").child(gameKey).removeValue()
                self.ref.child("users").child("\(self.currentGameUser[1].id!)/games/\(gameKey)").removeValue()
                self.ref.child("users").child("\(self.currentGameUser[2].id!)/games/\(gameKey)").removeValue()
                self.ref.child("users").child("\(self.currentGameUser[3].id!)/games/\(gameKey)").removeValue()
            }else{
                print("Leave Game - 2")
                self.ref.child("games").child(gameKey).removeAllObservers()
                
                self.ref.child("games").child(gameKey).child("\(self.gameUser.id!)/accept").setValue("left")
                self.ref.child("games").child(gameKey).child("\(self.currentGameUser[0].id!)/accept").removeAllObservers()
                self.ref.child("games").child(gameKey).child("\(self.currentGameUser[1].id!)/accept").removeAllObservers()
                self.ref.child("games").child(gameKey).child("\(self.currentGameUser[2].id!)/accept").removeAllObservers()
                self.ref.child("games").child(gameKey).child("\(self.currentGameUser[3].id!)/accept").removeAllObservers()
            }
        }
        
        self.gameIsOn = false
        self.currentGameUser.removeAll()
        self.gameKey = ""
        completion(true)
    }
    
    
    
    
    func watchGameAvailability(gameId:String , completion:@escaping (Bool) -> Void){

        ref.child("games").child(gameId).observe(FIRDataEventType.value, with: { (snapshot) in
          
            if(snapshot.exists()){
                print("Game Exist")
                completion(true)
            }else{
                print("No Game Exist")
                completion(false)
                //self.ref.child("games").child(gameId).removeAllObservers()
                let gameCanceledNotification  = Notification.Name("gameCanceledNotification")
                NotificationCenter.default.post(name: gameCanceledNotification, object: nil,userInfo: nil)
            }
            
        }){ (error) in
            print(error.localizedDescription)
        }
    
    }
    
    
    func imageDownload(url:NSURL , completion:@escaping (UIImage) -> Void){
            let stringUrl = String(describing: url)
            Alamofire.request(stringUrl).responseImage { response in
                if let image = response.result.value {
                    completion(image)
                }
                else{
                    completion(UIImage(named: "inviteAPlayer")!)
                }
            }
        
    }
    
    
    
    func setDeviceToken(){
        let user = FIRAuth.auth()?.currentUser?.uid
        OneSignal.idsAvailable({(_ userId, _ pushToken) in
            print("UserId:\(userId)")
            if pushToken != nil {
                print("pushToken:\(pushToken)")
                self.ref.child("users").child(user!).child("deviceToken").setValue(userId)
            }
        })

    }


    
    
    func sendPushNotification(usersId:[String] ,completion: @escaping (Bool)->Void){
        print("Send Push Notification")
        print(usersId.count)
        print(usersId)

        var counter = 3
        var deviceToken = [String]()
        for id in usersId{
            self.ref.child("users").child(id).child("deviceToken").observeSingleEvent(of: .value, with: { (snapshot) in
                counter -= 1
                let token = snapshot.value
                print("Push Ids")
                if(snapshot.exists()){
                    print(snapshot.value!)
                    deviceToken.append(token! as! String)
                }
                
                if(counter == 0){
                    print("Sending to OneSignal")
                    print(deviceToken)
                    self.sendOneSignalNotification(deviceToken: deviceToken ,  currentGameUser: self.currentGameUser)
                    completion(true)

                }
                
            })
        }
    }
    
    
    func sendOneSignalNotification(deviceToken:[String] , currentGameUser:[User]){
        
        print("Send to OneSignal")
        print(deviceToken)
        let parameters: Parameters = [
            "app_id": "bd3a791f-1577-4449-86c4-096a0317f00b",
            "content_available":1,
            "include_player_ids": ["8cd420c9-2be9-4200-8860-3e484a371e63"],
            "data": [
                     "gameId" : self.gameKey,
                     "playerOne"    : self.currentGameUser[0].id,
                     "playerTwo"    : self.currentGameUser[1].id,
                     "playerThree"  : self.currentGameUser[2].id,
                     "playerFour"   : self.currentGameUser[3].id,
                     "senderName"   : self.currentGameUser[0].name

            ],
            "contents": ["en": self.currentGameUser[0].name! + " has sent you a game invite"]
        ]
        Alamofire.request("https://onesignal.com/api/v1/notifications", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
            
            if let JSON = response.result.value {
                print("JSON: \(JSON)")
            }
        }
    
    }
    
    
    
    
}
