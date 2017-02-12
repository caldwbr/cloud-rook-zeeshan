//
//  InviteCell.swift
//  CloudRook
//
//  Created by Zeeshan Khan on 10/02/2017.
//  Copyright © 2017 Caldwell Contracting LLC. All rights reserved.
//

import UIKit

class InviteCell: UITableViewCell {

    @IBOutlet weak var inviteOwner: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configureCell(owner:String){
        self.inviteOwner.text = owner
        self.inviteOwner.text = self.inviteOwner.text?.capitalized
        
    }
    
}
