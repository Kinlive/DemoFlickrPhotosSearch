//
//  AppCoordinator.swift
//  DemoPhotoSearch
//
//  Created by Kinlive on 2020/7/11.
//  Copyright © 2020 Kinlive. All rights reserved.
//

import UIKit
import RxSwift

class AppCoordinator: BaseCoordinator<Void> {

  private let window: UIWindow
  private let rootViewController: UINavigationController

  init(window: UIWindow) {
    self.window = window
    rootViewController = UINavigationController()
    window.rootViewController = rootViewController
    window.makeKeyAndVisible()

  }

  override func start() -> Observable<Void> {
    let searchCoordinator = SearchCoordinator(presenter: rootViewController)

    return coordinator(to: searchCoordinator)
  }

}

