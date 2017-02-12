//
//  FoodModel.swift
//  Foodicize
//
//  Created by Zeeshan Khan on 20/03/2016.
//  Copyright © 2016 Dropocol. All rights reserved.
//

import Foundation
import SwiftyJSON


class User {
    
//    var name: String?
//    var email: String?
//    var picUrl: NSURL?
    
    var id : String?
    var name: String?
    var email: String?
    var picUrl: NSURL?
    
    /*
    init(id: String,foodName: String,foodPicture: NSURL,rating:Float, deliveryTime:Int,
        price:Int, minOrder:Int, category:String, description:String, sellerId:String,
        reviews:[[String:String]],city : String, areas : [String], availability:Bool)
    {
        self.id = id
        self.foodName = foodName
        self.foodPicture = foodPicture
        self.rating = rating
        self.deliveryTime = deliveryTime
        self.price = price
        self.minOrder = minOrder
        self.category = category
        self.description = description
        self.sellerId = sellerId
        self.reviews = reviews
        self.city = city
        self.areas = areas
        self.availability = availability
        
    }
 */
    init(){
        self.id = ""
        self.name = ""
        self.email = ""
        self.picUrl = NSURL(string:"")
    }
    
    
    
    init(userObject: JSON , id:String)
    {

        self.id = id
        
        if let name = userObject["username"].string{
            self.name = name
        }
        
        if let email = userObject["email"].string{
            self.email = email
        }
        if let picUrl = userObject["pic"].string{
            self.picUrl = NSURL(string:picUrl)!
        }
//                email               =   ""
//                picUrl              =   NSURL(string:"")!
        
//        if let email = userObject["email"].string?{
//            self.email = email!
//        }
//        
//        if let picUrl = userObject["pic"].string?{
//            self.picUrl = NSURL(string:picUrl!)!
//        }
        
//        name                =   userObject["username"].string!
//        email               =   userObject["email"].string!
//        picUrl              =   NSURL(string:userObject["pic"].string!)!

}




}
