//
//  SearchResultViewController.swift
//  DemoPhotoSearch
//
//  Created by Kinlive on 2020/7/12.
//  Copyright © 2020 Kinlive. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SearchResultViewController: UIViewController {

  lazy var resultCollectionView: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionFlowLayout())
    collectionView.translatesAutoresizingMaskIntoConstraints = false
    collectionView.delegate = nil
    collectionView.dataSource = nil
    collectionView.backgroundColor = .lightGray
    collectionView.register(SearchResultCell.self, forCellWithReuseIdentifier: String(describing: SearchResultCell.self))
    return collectionView
  }()

  private let viewModel: SearchResultViewModel
  private let constraints = Constraints()
  private let disposeBag = DisposeBag()

  init(viewModel: SearchResultViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white

    addSubviews()
    binds()
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    viewModel.startRequest.onNext(())
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    layoutConstraints()
  }

  private func binds() {
    viewModel.cellViewModel
      .bind(to: resultCollectionView.rx.items(cellIdentifier: String(describing: SearchResultCell.self), cellType: SearchResultCell.self)) { (indexPath, cellViewModel, cell: SearchResultCell) in
          cell.viewModel.onNext(cellViewModel)
        }
      .disposed(by: disposeBag)

    viewModel.searchInfo
      .map { "搜尋結果 \($0.text)" }
      .bind(onNext: { title in self.tabBarController?.title = title })
      .disposed(by: disposeBag)

  }

  private func addSubviews() {
    view.addSubview(resultCollectionView)
  }

  // setup constraint of subviews
  private func layoutConstraints() {

    constraints.collection.top = resultCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
    constraints.collection.left = resultCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
    constraints.collection.right = resultCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
    constraints.collection.bottom = resultCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)

    constraints.activate()
  }

  // configure collectionView flow layout
  private func collectionFlowLayout() -> UICollectionViewFlowLayout {
    let layout = UICollectionViewFlowLayout()
    let horizontalSpacing: CGFloat = 10
    let itemWidth = view.frame.width * 0.5 - horizontalSpacing
    layout.itemSize = CGSize(width: itemWidth, height: itemWidth)

    return layout
  }
}

extension SearchResultViewController {
  struct Constraints {
    let collection = NSLayoutConstraintSet()

    private var all: [NSLayoutConstraintSet] { return [collection] }
    func activate() { all.forEach { $0.activate() }}
    func deactivate() { all.forEach { $0.deactivate() }}
  }
}

