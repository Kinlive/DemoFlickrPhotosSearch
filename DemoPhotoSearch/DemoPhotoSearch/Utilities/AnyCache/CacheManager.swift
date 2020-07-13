//
//  CacheManager.swift
//  MessageDemo
//
//  Created by Cheryl Chen on 2020/2/14.
//  Copyright © 2020 Apple. All rights reserved.
//

import UIKit

class CacheManager: NSObject {
    public static let shared: CacheManager = CacheManager()
    public let photoCache = Cache<String, UIImage?>()
}
