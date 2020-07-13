//
//  SearchResultCoordinator.swift
//  DemoPhotoSearch
//
//  Created by Kinlive on 2020/7/12.
//  Copyright © 2020 Kinlive. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SearchResultCoordinator: BaseCoordinator<Void> {

  let presenter: UINavigationController
  let viewController: SearchResultViewController

  init(presenter: UINavigationController) {
    self.presenter = presenter
    let viewModel = SearchResultViewModel(searchInfo: .init(text: "", perPage: ""))
    viewController = SearchResultViewController(viewModel: viewModel)
  }

  override func start() -> Observable<Void> {

    return Observable.of(presenter.navigationItem.leftBarButtonItem!.rx.tap).merge().do(onNext: { [weak self] _ in
      self?.presenter.dismiss(animated: true)
    })
  }
}
