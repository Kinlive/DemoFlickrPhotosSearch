//
//  FavoriteCoordinator.swift
//  DemoPhotoSearch
//
//  Created by Kinlive on 2020/7/12.
//  Copyright © 2020 Kinlive. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class FavorivateCoordinator: BaseCoordinator<Void> {

  let presenter: UINavigationController
  let viewController: FavoriteViewController

  init(presenter: UINavigationController) {
    self.presenter = presenter

    let viewModel = FavoriteViewModel()
    viewController = FavoriteViewController(viewModel: viewModel)
  }

  override func start() -> Observable<Void> {

    return Observable.from(optional: presenter.rx.deallocated).merge()
  }
}
