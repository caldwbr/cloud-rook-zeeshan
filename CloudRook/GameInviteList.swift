//
//  InviteList.swift
//  CloudRook
//
//  Created by Zeeshan Khan on 10/02/2017.
//  Copyright © 2017 Caldwell Contracting LLC. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

protocol  AcceptInviteDelegate{
    func invitationAccepted(game : GameInvite)
}


class GameInviteList: UITableViewController {
    
    let ds = DataService.ds
    var gameInvites = [GameInvite]()
    let notificationName  =   Notification.Name("gameInvitationNotification")
    var delegate: AcceptInviteDelegate? = nil
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        print("I came on Invite Screen")
        self.loadData()
    }

    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: notificationName, object: nil);
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        NotificationCenter.default.addObserver(self, selector: #selector(GameInviteList.loadData), name: notificationName, object: nil)
        
        if(FIRAuth.auth()?.currentUser != nil){
            self.loadData()
        }
        self.navigationController?.setNavigationBarHidden(false, animated: true)

    }
    
    
    func loadData(){
        self.gameInvites = self.ds.getGameInvitations.reversed()
        print("Game Invites \(self.gameInvites.count)")
        self.tableView.reloadData()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.gameInvites.count
    }

    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        let message = "Do you want to accept the game Invitation?"
        self.showInvitationAlert(message:message , game:self.gameInvites[indexPath.row])
        
    }
    
    
    func showInvitationAlert(message:String , game:GameInvite){
        let alert = UIAlertController(title: "Accept", message: message, preferredStyle:UIAlertControllerStyle.alert)
        
            alert.addAction(UIAlertAction(title: "YES", style: UIAlertActionStyle.default, handler: {
                response in
                
                self.ds.gameIsOn = true
                self.delegate!.invitationAccepted(game : game)
                _ = self.navigationController?.popViewController(animated: true)
                
            }))
            
            alert.addAction(UIAlertAction(title: "NO", style: UIAlertActionStyle.default, handler: {
                response in
                self.ds.rejectGameInvitation(gameId:game.id!)
                self.gameInvites = self.gameInvites.filter{$0.id != game.id!}
                self.tableView.reloadData()
            }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "inviteCell", for: indexPath) as! InviteCell
        print(self.gameInvites[indexPath.row].ownerName!)
        cell.configureCell(owner: self.gameInvites[indexPath.row].ownerName!)
        return cell
    }
 

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
