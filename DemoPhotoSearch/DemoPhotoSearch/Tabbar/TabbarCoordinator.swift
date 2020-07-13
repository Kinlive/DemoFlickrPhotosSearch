//
//  TabbarCoordinator.swift
//  DemoPhotoSearch
//
//  Created by Kinlive on 2020/7/11.
//  Copyright © 2020 Kinlive. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

enum Tabs {
  case search
  case favorite

  var title: String {
    switch self {
    case .search: return "Search"
    case .favorite: return "Favorite"
    }
  }
}

class TabbarCoordinator: BaseCoordinator<Void> {

  private let presenter: UINavigationController
  private let tabBarController: UITabBarController
  private var tabCoordinators: [Tabs : BaseCoordinator<CoordinatorResult>] = [:]

  init(presenter: UINavigationController) {

    self.presenter = presenter
    self.tabBarController = UITabBarController()

    let backButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: nil, action: nil)
    presenter.navigationItem.leftBarButtonItem = backButton

    tabCoordinators[.search] = SearchResultCoordinator(presenter: presenter)
    tabCoordinators[.favorite] = FavorivateCoordinator(presenter: presenter)

    var viewControllers: [UIViewController] = []
    // append for search result
    let searchVC = (tabCoordinators[.search] as! SearchResultCoordinator).viewController
    searchVC.tabBarItem = UITabBarItem(tabBarSystemItem: .featured, tag: 0)

    viewControllers.append(searchVC)

    // append for favorite
    let favoriteVC = (tabCoordinators[.favorite] as! FavorivateCoordinator).viewController
    favoriteVC.tabBarItem = UITabBarItem(tabBarSystemItem: .favorites, tag: 1)
    viewControllers.append(favoriteVC)

    // add viewControllers to tabBar
    tabBarController.viewControllers = viewControllers
    tabBarController.tabBar.isTranslucent = false

  }

  override func start() -> Observable<Void> {
    presenter.pushViewController(tabBarController, animated: true)

    tabBarController.rx.didSelect
      .subscribe(onNext: { vc in
        switch true {
        case vc is SearchResultViewController:
          print("now select for search result ")
        case vc is FavoriteViewController:
          print("now select for favorite !")
        default: break
        }
      })
      .disposed(by: disposeBag)

    return Observable.of(presenter.navigationItem.leftBarButtonItem!.rx.tap).merge()
      .do(onNext: {[weak self] _ in
        self?.tabBarController.dismiss(animated: true)

      } )
  }

}

