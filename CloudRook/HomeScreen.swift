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
    let notificationName  =   Notification.Name("gameUserOnlineNotification")
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
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkLoggedIn()
        if(FIRAuth.auth()?.currentUser != nil){
            print("Download Friends")
            self.downloadFriendsList()
            self.ds.loadAllLists()
            self.ds.checkIfConnected()
            self.ds.checkInvitations()
            self.ds.createGameUser()
        }
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func invitationAccepted(game : GameInvite){
        
        var usersId = [String]()
        usersId.append((game.owner?.id!)!)
        usersId.append((game.playerOne?.id!)!)
        usersId.append((game.playerTwo?.id!)!)
        usersId.append((game.playerThree?.id!)!)
        
        self.ds.acceptGameInvitation(usersId:usersId , game:game){
            response in
            self.checkGame()
            self.selectInvite = false
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
    
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: notificationName, object: nil);
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        if(FIRAuth.auth()?.currentUser != nil){
            self.ds.createGameUser()
        }
        self.checkGame()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        NotificationCenter.default.addObserver(self, selector: #selector(HomeScreen.checkGame), name: notificationName, object: nil)
        
        if(self.ds.gameIsOn == true){
            self.leaveGame.isEnabled = true
            self.leaveGame.setTitle("Leave Game",for: .normal)
        }
        else{
            self.leaveGame.isEnabled = false
            self.leaveGame.setTitle("",for: .normal)

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
            self.ds.checkInvitations()
            if let unwrappedUrl = user?.photoURL {
                self.ref.child("users").child((user?.uid)!).updateChildValues(["username": (user?.displayName!)!, "pic": String(describing: unwrappedUrl) as Any, "email": (user?.email!)!]){
                    response in
                    self.ds.checkIfConnected()
                }
            }else {
                self.ref.child("users").child((user?.uid)!).updateChildValues(["username": (user?.displayName!)!, "pic": "nil", "email": (user?.email!)!]){
                    response in
                    self.ds.checkIfConnected()
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
            userList.users = self.ds.users
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
        let ref2 = FIRDatabase.database().reference()
        ref2.child("users").observeSingleEvent(of: .value, with: { (snapshot) in
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]{
                for snap in snapshots
                {
                    let user = User(userObject: JSON(snap.value!) , id:snap.key)
                    self.ds.users.append(user)
                }
            }

        }) { (error) in
            print(error.localizedDescription)
        }
    }


}

