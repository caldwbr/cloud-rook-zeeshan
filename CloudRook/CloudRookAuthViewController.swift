
//
//  CloudRookAuthViewController.swift
//  CloudRook
//
//  Created by Brad Caldwell on 12/14/16.
//  Copyright © 2016 Caldwell Contracting LLC. All rights reserved.
//

import UIKit
import FirebaseAuthUI

class CloudRookAuthViewController: FUIAuthPickerViewController {

    init(authUI: FUIAuth){
        super.init(nibName: "FUIAuthPickerViewController", bundle: nil, authUI: authUI)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        let width = UIScreen.main.bounds.size.width
        let height = UIScreen.main.bounds.size.height
        
        let imageViewBackground = UIImageView(frame: CGRect(x: 0, y: 0, width: width, height: height))
        imageViewBackground.image = UIImage(named: "CloudRookSignIn")
        
        // you can change the content mode:
        imageViewBackground.contentMode = UIViewContentMode.scaleAspectFill
        
        view.insertSubview(imageViewBackground, at: 0)
    }
    

}
