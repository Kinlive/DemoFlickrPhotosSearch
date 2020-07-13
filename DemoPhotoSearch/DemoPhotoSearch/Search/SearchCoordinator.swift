//
//  SearchCoordinator.swift
//  DemoPhotoSearch
//
//  Created by Kinlive on 2020/7/11.
//  Copyright © 2020 Kinlive. All rights reserved.
//

import UIKit
import RxSwift

class SearchCoordinator: BaseCoordinator<Void> {

  private let presenter: UINavigationController
  let viewController: SearchViewController
  let viewModel: SearchViewModel

  init(presenter: UINavigationController) {
    self.presenter = presenter

    viewModel = SearchViewModel()
    self.viewController = SearchViewController(viewModel: viewModel)

  }

  override func start() -> Observable<Void> {
    presenter.pushViewController(viewController, animated: true)



    let subCoordinator = TabbarCoordinator(presenter: presenter)

    viewController.sendButton.rx.tap
      .flatMap { subCoordinator.start() }
      .subscribe()
      .disposed(by: disposeBag)

    return Observable.never()
  }
  
}
