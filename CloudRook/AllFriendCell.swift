//
//  AllFriendCell.swift
//  CloudRook
//
//  Created by Zeeshan Khan on 03/01/2017.
//  Copyright © 2017 Caldwell Contracting LLC. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class AllFriendCell: UITableViewCell {
    
        @IBOutlet weak var inviteButton: UIButton!
        @IBOutlet weak var userImage: UIImageView!
        @IBOutlet weak var userName: UILabel!
        @IBOutlet weak var onlineIcon: UIView!
        var inviteCallback : (()->())!
    
        override func awakeFromNib() {
            super.awakeFromNib()
            // Initialization code
        }
        
        override func setSelected(_ selected: Bool, animated: Bool) {
            super.setSelected(selected, animated: animated)
             self.onlineIcon.backgroundColor = self.onlineIcon.backgroundColor
        }
        
    @IBAction func inviteButtonTapped(_ sender: UIButton) {
                    self.inviteCallback()
    }
    
    
    func configureCell(user:User){
            self.userName.text = user.name
            if(!DataService.ds.getOnlineUsers.contains(user.id!)){
               print("User is Not Online")
               self.onlineIcon.backgroundColor = UIColor.white
            }else{
                
                self.onlineIcon.backgroundColor = UIColor.green
            }
            if let url = user.picUrl{
                let stringUrl = String(describing: url)
                Alamofire.request(stringUrl).responseImage { response in
                    if let image = response.result.value {
                        self.userImage.image = image
                    }
                    else{
                        self.userImage.image = UIImage(named: "Black1")
                    }
                }
            }
            else{
                self.userImage.image = UIImage(named: "Black1")
            }

    }
    

    
}
