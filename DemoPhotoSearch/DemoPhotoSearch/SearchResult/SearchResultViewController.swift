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
import RxDataSources

class SearchResultViewController: UIViewController {

  // MARK: - Subviews
  lazy var resultCollectionView: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionFlowLayout())
    collectionView.translatesAutoresizingMaskIntoConstraints = false
    collectionView.delegate = self
    collectionView.dataSource = nil
    collectionView.backgroundColor = .lightGray
    collectionView.register(SearchResultCell.self, forCellWithReuseIdentifier: String(describing: SearchResultCell.self))

    return collectionView
  }()

  lazy var refreshControl = UIRefreshControl()

  // MARK: - Private properties.
  private let viewModel: SearchResultViewModel
  private let constraints = Constraints()
  private let disposeBag = DisposeBag()
  private var currentPage: Int = 0
  private var previousTriggerTime = Date().timeIntervalSince1970

  // MARK: - Initialize.
  init(viewModel: SearchResultViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Life cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
    addSubviews()
    binds()
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    layoutConstraints()
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    viewModel.startRequest.onNext(nil)
  }

  // MARK: - Private methods
  private func binds() {
    // define collectionView's dataSource
    let dataSources = RxCollectionViewSectionedReloadDataSource<SectionModel<String, SearchResultCellViewModel>>(configureCell: { (dataSource, collectionView, indexPath, sectionModel) -> SearchResultCell in
         let cell: SearchResultCell = collectionView.dequeueReusableCell(for: indexPath)
         cell.viewModel.onNext(sectionModel)
         return cell
    })

    // when receive new cellViewModel bind to collectionView's item with dataSource.
    viewModel.cellViewModel
      .map { [SectionModel<String, SearchResultCellViewModel>(model: "", items: $0)] }
      .bind(to: resultCollectionView.rx.items(dataSource: dataSources))
      .disposed(by: disposeBag)

    // when search info passed by search page then set on current's title.
    viewModel.searchInfo
      .map { "搜尋結果 \($0.text)" }
      .bind(onNext: { title in self.tabBarController?.title = title })
      .disposed(by: disposeBag)

    viewModel.searchInfo
      .compactMap { Int($0.perPage) }
      .subscribe(onNext: { [unowned self] in self.currentPage += $0 })
      .disposed(by: disposeBag)

    // when refresh's value changed start reload data.
    refreshControl.rx.controlEvent(.valueChanged).asObservable()
      .map { nil }
      .bind(to: viewModel.refreshActive)
      .disposed(by: disposeBag)

    // when receive new element of cellViewModel that means
    // request finished, stop the refreshControl.
    viewModel.cellViewModel.asObserver()
      .map { _ in false }
      .bind(to: refreshControl.rx.isRefreshing)
      .disposed(by: disposeBag)

  }

  private func addSubviews() {
    view.addSubview(resultCollectionView)
    resultCollectionView.refreshControl = refreshControl
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

// MARK: - Extension of Constraints define.
extension SearchResultViewController {
  struct Constraints {
    let collection = NSLayoutConstraintSet()

    private var all: [NSLayoutConstraintSet] { return [collection] }
    func activate() { all.forEach { $0.activate() }}
    func deactivate() { all.forEach { $0.deactivate() }}
  }
}

// MARK: - UIScrollView delegate.
extension SearchResultViewController: UICollectionViewDelegateFlowLayout {

  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    let threshold: CGFloat = 100

    let contentOffset = scrollView.contentOffset.y
    let contentHeight = scrollView.contentSize.height

    let diffHeight = contentHeight - contentOffset

    let frameHeight = scrollView.bounds.size.height

    let triggerThreshold = min((diffHeight - frameHeight) / threshold, 0)

    let pullRatio = min(abs(triggerThreshold), 1)

    let now = Date().timeIntervalSince1970
    let timeDiff = now - previousTriggerTime

    // use pull distance and time difference between now and previous time
    // to avoid continue request in short time.
    if pullRatio >= 1, timeDiff > 5 {
      viewModel.startRequest.onNext(currentPage)
      let pages = currentPage
      currentPage += pages
      previousTriggerTime = now
    }
  }
}
