//
//  SearchViewController.swift
//  DemoPhotoSearch
//
//  Created by Kinlive on 2020/7/11.
//  Copyright © 2020 Kinlive. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SearchViewController: UIViewController {

  // MARK: - UIs
  lazy var inputTextField: UITextField = {
    let textField = UITextField()
    textField.borderStyle = .roundedRect
    textField.placeholder = "欲搜尋內容"
    textField.translatesAutoresizingMaskIntoConstraints = false
    return textField
  }()

  lazy var perPagesTextField: UITextField = {
    let textField = UITextField()
    textField.borderStyle = .roundedRect
    textField.placeholder = "每頁呈現數量"
    textField.translatesAutoresizingMaskIntoConstraints = false
    textField.keyboardType = .numberPad
    return textField
  }()

  lazy var sendButton: UIButton = {
    let button = UIButton()
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setTitle("送出", for: .normal)
    button.setTitle("請輸入搜尋條件", for: .disabled)
    button.setTitleColor(.blue, for: .normal)
    button.setTitleColor(.gray, for: .disabled)
    button.isEnabled = false
    button.backgroundColor = .lightGray
    return button
  }()

  // MARK: - Properties.
  private let viewModel: SearchViewModel
  private let constraints = Constraints()
  private let disposeBag = DisposeBag()

  // MARK: - Initialize
  init(viewModel: SearchViewModel = SearchViewModel()) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
    binds()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Life cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    addSubviews()
    configureUIs()
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    layoutConstriants()
  }

  // MARK: - Private methods
  private func binds() {
    // bind search text to viewModel
    inputTextField.rx.text.orEmpty
      .bind(to: viewModel.searchText)
      .disposed(by: disposeBag)

    // bind perPage to viewModel
    perPagesTextField.rx.text.orEmpty
      .bind(to: viewModel.perPage)
      .disposed(by: disposeBag)

    // subscribe event when button tapped to show search result
    sendButton.rx.tap
      .map { [unowned self] _ in (self.inputTextField.text ?? "", self.perPagesTextField.text ?? "") }
      .map { SearchViewModel.SearchInfo(text: $0, perPage: $1)}
      .subscribe(onNext: { [unowned self] info in self.showSearchResult(searchInfo: info) })
      .disposed(by: disposeBag)

    // enable the sendButton when textField all typed.
    viewModel.isSendButtonEnable
      .bind(to: sendButton.rx.isEnabled)
      .disposed(by: disposeBag)
  }

  private func addSubviews() {
    view.addSubview(inputTextField)
    view.addSubview(perPagesTextField)
    view.addSubview(sendButton)
  }

  private func configureUIs() {
    view.backgroundColor = .white
  }

  private func layoutConstriants() {
    // constraint of inputTextField
    constraints.inputText.top = inputTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30)
    constraints.inputText.centerX = inputTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor)
    constraints.inputText.width = inputTextField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.6)
    constraints.inputText.height = inputTextField.heightAnchor.constraint(equalToConstant: 50)

    // constraint of perPageTextField
    constraints.perPagesText.top = perPagesTextField.topAnchor.constraint(equalTo: inputTextField.bottomAnchor, constant: 20)
    constraints.perPagesText.centerX = perPagesTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor)
    constraints.perPagesText.width = perPagesTextField.widthAnchor.constraint(equalTo: inputTextField.widthAnchor)
    constraints.perPagesText.height = perPagesTextField.heightAnchor.constraint(equalTo: inputTextField.heightAnchor)

    // constraints of send button
    constraints.sendButton.top = sendButton.topAnchor.constraint(equalTo: perPagesTextField.bottomAnchor, constant: 20)
    constraints.sendButton.centerX = sendButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
    constraints.sendButton.width = sendButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5)
    constraints.sendButton.height = sendButton.heightAnchor.constraint(equalToConstant: 40)

    // active all constraints
    constraints.activate()
  }

  private func showSearchResult(searchInfo: SearchViewModel.SearchInfo) {
    let tabBarController = UITabBarController()

    var viewControllers: [UIViewController] = []
    // append for search result
    let resultVM = SearchResultViewModel(searchInfo: searchInfo)
    let searchVC = SearchResultViewController(viewModel: resultVM)
    searchVC.tabBarItem = UITabBarItem(tabBarSystemItem: .featured, tag: 0)

    viewControllers.append(searchVC)

    // append for favorite
    let favoriteVM = FavoriteViewModel()
    let favoriteVC = FavoriteViewController(viewModel: favoriteVM)
    favoriteVC.tabBarItem = UITabBarItem(tabBarSystemItem: .favorites, tag: 1)
    viewControllers.append(favoriteVC)

    // add viewControllers to tabBar
    tabBarController.viewControllers = viewControllers
    tabBarController.tabBar.isTranslucent = false

    // push tabbar
    navigationController?.pushViewController(tabBarController, animated: true)
  }
}

// MARK: - SearchViewController constraints
extension SearchViewController {
  struct Constraints {
    let inputText = NSLayoutConstraintSet()
    let perPagesText = NSLayoutConstraintSet()
    let sendButton = NSLayoutConstraintSet()

    private var all: [NSLayoutConstraintSet] { return [inputText, perPagesText, sendButton] }

    func activate() { all.forEach { $0.activate() }}
    func deactivate() { all.forEach { $0.deactivate() }}
  }

}
