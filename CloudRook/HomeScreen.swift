//
//  ViewController.swift
//  CloudRook
//
//  Created by Brad Caldwell on 12/13/16.
//  Copyright © 2016 Caldwell Contracting LLC. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
import FirebaseAuthUI
import FirebaseDatabaseUI
import FirebaseGoogleAuthUI
import FirebaseFacebookAuthUI
import Bolts
import FBSDKCoreKit
import FBSDKLoginKit
import SwiftyJSON

class HomeScreen: UIViewController, FUIAuthDelegate ,  AcceptInviteDelegate {
    
    var googleStuff = ["https://www.googleapis.com/auth/plus.login", "https://www.googleapis.com/auth/plus.me", "https://www.googleapis.com/auth/userinfo.email", "https://www.googleapis.com/auth/userinfo.profile"]
    
    var ref: FIRDatabaseReference!
    var users = [User]()
    var authUI: FUIAuth?

    let ds = DataService.ds
    
    let gameUserOnlineNotification  =   Notification.Name("gameUserOnlineNotification")
    let gameInvitationReceived  =   Notification.Name("gameInvitationReceived")
    let gameStatusNotification  = Notification.Name("gameStatusNotification")
    let gameCanceledNotification  = Notification.Name("gameCanceledNotification")
    let gameInvitationNotification  =   Notification.Name("gameInvitationNotification")

    
    var selectInvite = false
    var imageDownloaded = false
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var player1Card: UIImageView!
    @IBOutlet weak var player2Card: UIImageView!
    @IBOutlet weak var player3Card: UIImageView!
    @IBOutlet weak var player4Card: UIImageView!
    @IBOutlet weak var player1ProfilePic: UIImageView!
    @IBOutlet weak var player2ProfilePic: UIImageView!
    @IBOutlet weak var player3ProfilePic: UIImageView!
    @IBOutlet weak var player4ProfilePic: UIImageView!
    @IBOutlet weak var cardTable: UIImageView!
    @IBOutlet weak var leaveGame: UIButton!
    @IBOutlet weak var notification: UIBarButtonItem!
    
    
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    
    
    @IBOutlet weak var statusOne: UILabel!
    @IBOutlet weak var statusTwo: UILabel!
    @IBOutlet weak var statusThree: UILabel!
    @IBOutlet weak var statusFour: UILabel!

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.ds.ref = FIRDatabase.database().reference()

        checkLoggedIn()
        if(FIRAuth.auth()?.currentUser != nil){
            print("Download Friends")
            self.downloadFriendsList()
            self.ds.loadAllLists()
            self.ds.checkIfConnected()
            self.ds.createGameUser()
            self.ds.setDeviceToken()
            print("Check Inviations")
            self.ds.checkInvitations()
            
            NotificationCenter.default.addObserver(self, selector: #selector(HomeScreen.gameInvitationReceivedReceived), name: gameInvitationReceived, object: nil)
            
            NotificationCenter.default.addObserver(self, selector: #selector(HomeScreen.gameNonAvailability), name: gameCanceledNotification, object: nil)
            
            NotificationCenter.default.addObserver(self, selector: #selector(HomeScreen.notificationIcon), name: gameInvitationNotification, object: nil)
            
            
            if(appDelegate.notificationAvailable == true){
                 self.gameInvitationReceivedReceived()
            }

        }
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
    
    func notificationIcon(){
        
        print("Notification Icon")
        if(self.ds.getGameInvitations.count > 0){
            self.notification.tintColor = UIColor.red
        }else{
            self.notification.tintColor = UIColor.lightGray
        }
    }
    
    
    func gameInvitationReceivedReceived(){
        
        let senderName = self.appDelegate.notificationData?["senderName"]!
        let alert = UIAlertController(title: "Game Invitation", message: "\(senderName!) has sent you a game request. Do you want to accept it?", preferredStyle:UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: {
            _ in
            self.ds.gameIsOn = true
            self.invitationAccepted(notification : self.appDelegate.notificationData!)
            self.notification.tintColor = UIColor.lightGray
        }))
        
        alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.default, handler: {
            _ in
            self.ds.rejectGameInvitation(gameId: (self.appDelegate.notificationData?["gameId"]!)!)
            self.notification.tintColor = UIColor.lightGray
            
        }))
        
        self.present(alert, animated: true, completion: nil)
        print(appDelegate.notificationData!)
        
    }
    
    
    func gameNonAvailability(){
        let alert = UIAlertController(title: "Game", message: "The game you are trying to play is not available anymore. The game owner left the game", preferredStyle:UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {
            _ in
            self.ds.leaveGame(){
                response in
                self.leaveGame.setTitle("",for: .normal)
                self.leaveGame.isEnabled = false
                self.imageDownloaded = false
                self.checkGame()
            }
        }))

        self.present(alert, animated: true, completion: nil)
    }
    
    
    
    func invitationAccepted(game : GameInvite){
        var usersId = [String]()
        usersId.append((game.owner?.id!)!)
        usersId.append((game.playerOne?.id!)!)
        usersId.append((game.playerTwo?.id!)!)
        usersId.append((game.playerThree?.id!)!)
        
        
        
        self.ds.watchGameAvailability(gameId: game.id!){
            response in
            if(response == true){
                self.ds.acceptGameInvitation(usersId:usersId , game:game){
                    response in
                    self.checkGame()
                    self.selectInvite = false
                }
            }
        }
    }
    
    
    func invitationAccepted(notification:[String:String]){
        
        var usersId = [String]()
        usersId.append(notification["playerOne"]!)
        usersId.append(notification["playerTwo"]!)
        usersId.append(notification["playerThree"]!)
        usersId.append(notification["playerFour"]!)
        print("\nUser ID")
        print(usersId)
        
        let gameId = notification["gameId"]!
        
        self.ds.watchGameAvailability(gameId: gameId){
            response in
            if(response == true){
                self.ds.getUsersData(usersId: usersId){ response in
                    self.ds.acceptGameInvitation(usersId:usersId , gameId:gameId){
                        response in
                        self.checkGame()
                        self.selectInvite = false
                    }
                }
            }
        }
        

        
    }
    
    
    @IBAction func leaveGame(_ sender: UIButton) {
        self.ds.leaveGame(){
            response in
            self.leaveGame.setTitle("",for: .normal)
            self.leaveGame.isEnabled = false
            self.imageDownloaded = false
            self.checkGame()
        }

    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: gameUserOnlineNotification, object: nil);
        NotificationCenter.default.removeObserver(self, name: gameStatusNotification, object: nil);
        self.notification.tintColor = UIColor.lightGray
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        if(FIRAuth.auth()?.currentUser != nil){
            self.ds.createGameUser()
        }
        self.checkGame()
        self.gameStatus()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        NotificationCenter.default.addObserver(self, selector: #selector(HomeScreen.gameStatus), name: gameStatusNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(HomeScreen.checkGame), name: gameUserOnlineNotification, object: nil)
        
        if(self.ds.gameIsOn == true){
            self.leaveGame.isEnabled = true
            self.leaveGame.setTitle("Leave Game",for: .normal)
        }
        else{
            self.leaveGame.isEnabled = false
            self.leaveGame.setTitle("",for: .normal)

        }
        
        
    }
    
    
    
    func gameStatus(){
    
        let gas = self.ds.getGameAcceptStatus
        var acceptCheck = 0
        var leftCheck = 0
        var rejectCheck = 0
        
        
        if(self.ds.gameIsOn == true && self.ds.getCurrentGameUser.count != 0){
           
            for (index, x) in gas.enumerated(){
                
                if(x as? Bool == false){
                    if(index == 0){
                        self.statusOne.text = "Waiting"
                        self.statusOne.textColor = UIColor.black
                    }
                    if(index == 1){
                        self.statusTwo.text = "Waiting"
                        self.statusTwo.textColor = UIColor.black
                    }
                    if(index == 2){
                        self.statusThree.text = "Waiting"
                        self.statusThree.textColor = UIColor.black
                    }
                    if(index == 3){
                        self.statusFour.text = "Waiting"
                        self.statusFour.textColor = UIColor.black
                    }
                }
                
                
                if(x as? Bool == true){
                    acceptCheck += 1
                    if(index == 0){
                        self.statusOne.text = "In Game"
                        self.statusOne.textColor = UIColor.blue
                    }
                    if(index == 1){
                        self.statusTwo.text = "In Game"
                        self.statusTwo.textColor = UIColor.blue
                    }
                    if(index == 2){
                        self.statusThree.text = "In Game"
                        self.statusThree.textColor = UIColor.blue
                    }
                    if(index == 3){
                        self.statusFour.text = "In Game"
                        self.statusFour.textColor = UIColor.blue
                    }
                }
                
                if(String(describing: x) == "reject"){
                    rejectCheck += 1
                    if(index == 0){
                        self.statusOne.text = "Rejected"
                        self.statusOne.textColor = UIColor.brown
                    }
                    if(index == 1){
                        self.statusTwo.text = "Rejected"
                        self.statusTwo.textColor = UIColor.brown
                    }
                    if(index == 2){
                        self.statusThree.text = "Rejected"
                        self.statusThree.textColor = UIColor.brown
                    }
                    if(index == 3){
                        self.statusFour.text = "Rejected"
                        self.statusFour.textColor = UIColor.brown
                    }
                }
                
                if(String(describing: x) == "left"){
                    leftCheck += 1
                    if(index == 0){
                        self.statusOne.text = "Left Game"
                        self.statusOne.textColor = UIColor.red
                    }
                    if(index == 1){
                        self.statusTwo.text = "Left Game"
                        self.statusTwo.textColor = UIColor.red
                    }
                    if(index == 2){
                        self.statusThree.text = "Left Game"
                        self.statusThree.textColor = UIColor.red
                    }
                    if(index == 3){
                        self.statusFour.text = "Left Game"
                        self.statusFour.textColor = UIColor.red
                    }
                }
                
            }
            
            if(acceptCheck == 4){
                print("Play Game")
            }else if(rejectCheck > 0 || leftCheck > 0){
                 print("Player Rejected or Left the Game")
            }
            
            
            acceptCheck = 0
            rejectCheck = 0
            leftCheck = 0
            
        
        }else{
            self.statusOne.text = ""
            self.statusOne.textColor = UIColor.black
            self.statusTwo.text = ""
            self.statusTwo.textColor = UIColor.black
            self.statusThree.text = ""
            self.statusThree.textColor = UIColor.black
            self.statusFour.text = ""
            self.statusFour.textColor = UIColor.black
        }
    }
    
    
    
    
    func onlineChecker(){
      if(self.ds.getCurrentGameUser.count != 0){
        let userOne   = self.ds.getCurrentGameUser[0].id
        let userTwo   = self.ds.getCurrentGameUser[1].id
        let userThree = self.ds.getCurrentGameUser[2].id
        let userFour  = self.ds.getCurrentGameUser[3].id
        
        if(self.ds.getOnlineUsers.contains(userOne!)){
            self.player1ProfilePic.layer.borderWidth = 2
            self.player1ProfilePic.layer.borderColor = UIColor.green.cgColor
        }else{
            self.player1ProfilePic.layer.borderWidth = 0
            self.player1ProfilePic.layer.borderColor = UIColor.clear.cgColor
        }
        
        
        if(self.ds.getOnlineUsers.contains(userTwo!)){
            self.player2ProfilePic.layer.borderWidth = 2
            self.player2ProfilePic.layer.borderColor = UIColor.green.cgColor
        }else{
            self.player2ProfilePic.layer.borderWidth = 0
            self.player2ProfilePic.layer.borderColor = UIColor.clear.cgColor

        }
        
        
        if(self.ds.getOnlineUsers.contains(userThree!)){
            self.player3ProfilePic.layer.borderWidth = 2
            self.player3ProfilePic.layer.borderColor = UIColor.green.cgColor
        }else{
            self.player3ProfilePic.layer.borderWidth = 0
            self.player3ProfilePic.layer.borderColor = UIColor.clear.cgColor
        }
        
        
        if(self.ds.getOnlineUsers.contains(userFour!)){
            self.player4ProfilePic.layer.borderWidth = 2
            self.player4ProfilePic.layer.borderColor = UIColor.green.cgColor
        }else{
            self.player4ProfilePic.layer.borderWidth = 0
            self.player4ProfilePic.layer.borderColor = UIColor.clear.cgColor
        }
        
      }
      else{
            self.player1ProfilePic.layer.borderWidth = 0
            self.player1ProfilePic.layer.borderColor = UIColor.clear.cgColor
            self.player2ProfilePic.layer.borderWidth = 0
            self.player2ProfilePic.layer.borderColor = UIColor.clear.cgColor
            self.player3ProfilePic.layer.borderWidth = 0
            self.player3ProfilePic.layer.borderColor = UIColor.clear.cgColor
            self.player4ProfilePic.layer.borderWidth = 0
            self.player4ProfilePic.layer.borderColor = UIColor.clear.cgColor
        }
    }
    
    func checkGame(){

        print("Check Game")
        print(self.ds.getCurrentGameUser.count)

        if(self.ds.gameIsOn == true && self.ds.getCurrentGameUser.count != 0){
            self.player1ProfilePic.image = UIImage(named: "inviteAPlayer")
            self.player2ProfilePic.image = UIImage(named: "inviteAPlayer")
            self.player3ProfilePic.image = UIImage(named: "inviteAPlayer")
            self.player4ProfilePic.image = UIImage(named: "inviteAPlayer")
            self.onlineChecker()
            
            if let url = self.ds.getCurrentGameUser[0].picUrl{
            self.ds.imageDownload(url: url){
                response in
                self.player1ProfilePic.image =  response
              }
            }
            
            if let url = self.ds.getCurrentGameUser[1].picUrl{
                self.ds.imageDownload(url: url){
                    response in
                    self.player2ProfilePic.image =  response
                }
            }
            
            if let url = self.ds.getCurrentGameUser[2].picUrl{
                self.ds.imageDownload(url: url){
                    response in
                    self.player3ProfilePic.image =  response
                }
            }
            
            
            
            if let url = self.ds.getCurrentGameUser[3].picUrl{
                self.ds.imageDownload(url: url){
                    response in
                    self.player4ProfilePic.image =  response
                }
            }
            
        }
        else{
            self.onlineChecker()
            if(FIRAuth.auth()?.currentUser != nil && self.imageDownloaded == false){
                let user = FIRAuth.auth()?.currentUser
                if let url = user?.photoURL{
                    print("Reset Images")
                    print(url)
                    self.ds.imageDownload(url: url as NSURL){
                        response in
                        self.player1ProfilePic.image =  response
                        self.imageDownloaded = true
                    }
                }
                self.player2ProfilePic.image = UIImage(named: "inviteAPlayer")
                self.player3ProfilePic.image = UIImage(named: "inviteAPlayer")
                self.player4ProfilePic.image = UIImage(named: "inviteAPlayer")
            
            }
            

        }
    }
    
    
    
    func checkLoggedIn() {
        authUI = FUIAuth.defaultAuthUI()
        FIRAuth.auth()?.addStateDidChangeListener { auth, user in
            if user != nil {

                self.ref = FIRDatabase.database().reference()
                if user?.photoURL == nil {
                    self.profilePic.image = UIImage(named: "CloudRookSignIn")
                }else{
                        DispatchQueue.global(qos: .default).async(execute: {
                            let imageUrl = NSData(contentsOf: (user?.photoURL)!)
                            if let data = imageUrl {
                                DispatchQueue.main.async {
                                    self.profilePic.image = UIImage(data: data as Data)
                                    self.player1ProfilePic.image = UIImage(data: data as Data)
                                    self.player2ProfilePic.image = UIImage(named: "inviteAPlayer")
                                    self.player3ProfilePic.image = UIImage(named: "inviteAPlayer")
                                    self.player4ProfilePic.image = UIImage(named: "inviteAPlayer")
                                    self.player1Card.image = UIImage(named: "Yellow1")
                                    self.player2Card.image = UIImage(named: "TheRook")
                                    self.cardTable.image = UIImage(named: "cardTable")
                                }
                            }
                        })
                    
                    
                }
            } else {
                // No user is signed in.
                self.login()
            }
        }
    }
    
    
    
    func login() {

        if let authUI = authUI {
        authUI.delegate = self
        let providers: [FUIAuthProvider] = [
        FUIGoogleAuth(),
        FUIFacebookAuth(),
        ]
        authUI.providers = providers
        let authViewController = CloudRookAuthViewController(authUI: authUI)
        let navc = UINavigationController(rootViewController: authViewController)
        self.present(navc, animated: true, completion: nil)
        }
    }
    
    func authPickerViewController(forAuthUI authUI: FUIAuth) -> FUIAuthPickerViewController {
        return CloudRookAuthViewController(authUI: authUI)
    }
    
    func authUI(_ authUI: FUIAuth, didSignInWith user: FIRUser?, error: Error?) {
        if error != nil {
            login()
        }else {
            self.downloadFriendsList()
            self.ds.loadAllLists()
            print("Check Inviations - 2")
            self.ds.checkInvitations()
            if let unwrappedUrl = user?.photoURL {
                self.ref.child("users").child((user?.uid)!).updateChildValues(["username": (user?.displayName!)!, "pic": String(describing: unwrappedUrl) as Any, "email": (user?.email!)!]){
                    response in
                    self.ds.checkIfConnected()
                    self.ds.setDeviceToken()
                }
            }else {
                self.ref.child("users").child((user?.uid)!).updateChildValues(["username": (user?.displayName!)!, "pic": "nil", "email": (user?.email!)!]){
                    response in
                    self.ds.checkIfConnected()
                    self.ds.setDeviceToken()
                }
            }
            
        }
    }

    @IBAction func masAmigosPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "userList", sender: self)
    }
    
    
    
    @IBAction func gameInvitationPressed(_ sender: UIBarButtonItem) {
                self.selectInvite = true
                self.performSegue(withIdentifier: "inviteList", sender: self)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "inviteList"
        {
            let gameInvitationVC = segue.destination  as! GameInviteList
            gameInvitationVC.delegate = self
        }
        
        
        if segue.identifier == "userList"{
            let userList = segue.destination as! AllUserList
            userList.users = self.ds.users.filter{$0.id != self.ds.getGameUser.id}
        }
    }
    
    @IBAction func logOutPressed(_ sender: UIButton) {
        let user = FIRAuth.auth()?.currentUser?.uid
        
        self.ds.gameIsOn = false
        self.ds.removeCurrentGameUser()
        self.ds.setGamekey()
        self.ds.users.removeAll()
        
        
        self.ref.child("users").child(user! + "/connected").setValue(false){
            response in
            do {
                try self.authUI?.signOut()
            } catch let signOutError as NSError {
                print("Error signing out: %@", signOutError)
            }
        }

        
    }
    

    
    func downloadFriendsList(){
        let ref = FIRDatabase.database().reference()
        let userId = FIRAuth.auth()?.currentUser?.uid
        ref.child("users").observeSingleEvent(of: .value, with: { (snapshot) in
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]{
                for snap in snapshots
                {
                    let user = User(userObject: JSON(snap.value!) , id:snap.key)
                   // if(user.id != userId){
                        self.ds.users.append(user)
                   // }
                    
                }
            }

        }) { (error) in
            print(error.localizedDescription)
        }
    }

    
    
    
    

}

