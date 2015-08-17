//
//  FeedItem.swift
//  ExchangeAGram
//
//  Created by Dan Bender on 17/08/15.
//  Copyright (c) 2015 Dan Bender. All rights reserved.
//

import Foundation
import CoreData

@objc (FeedItem)
class FeedItem: NSManagedObject {

    @NSManaged var caption: String
    @NSManaged var image: NSData

}
