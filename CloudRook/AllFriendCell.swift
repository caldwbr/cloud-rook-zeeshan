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
    
        @IBOutlet weak var userImage: UIImageView!
        @IBOutlet weak var userName: UILabel!
        
        override func awakeFromNib() {
            super.awakeFromNib()
            // Initialization code
        }
        
        override func setSelected(_ selected: Bool, animated: Bool) {
            super.setSelected(selected, animated: animated)
            
            // Configure the view for the selected state
        }
        
        func configureCell(user:User){
            self.userName.text = user.name
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
