//
//  TabBarController.swift
//  DemoPhotoSearch
//
//  Created by Kinlive on 2020/7/11.
//  Copyright © 2020 Kinlive. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {

  init() {
    super.init(nibName: nil, bundle: nil)
    delegate = self
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
      super.viewDidLoad()

      // Do any additional setup after loading the view.
  }

}

extension TabBarController: UITabBarControllerDelegate {
  
}
