//
//  SearchResultCell.swift
//  DemoPhotoSearch
//
//  Created by Kinlive on 2020/7/12.
//  Copyright © 2020 Kinlive. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SearchResultCell: UICollectionViewCell {

  lazy var title: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()

  lazy var imageView: UIImageView = {
    let view = UIImageView()
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()

  private let subviewsConstraints = Constraints()
  private let disposeBag = DisposeBag()

  let viewModel = PublishSubject<SearchResultCellViewModel>()

  override init(frame: CGRect) {
    super.init(frame: frame)

    contentView.addSubview(title)
    contentView.addSubview(imageView)

    viewModel
      .map { $0.imageDownloaded }
      .flatMap { $0 }
      .bind(to: imageView.rx.image)
      .disposed(by: disposeBag)

    viewModel
      .map { $0.title }
      .bind(to: title.rx.text)
      .disposed(by: disposeBag)

  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    layoutConstraints()
  }

  private func layoutConstraints() {
    // imageView
    subviewsConstraints.image.top = imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10)
    subviewsConstraints.image.centerX = imageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
    let width = contentView.frame.width * 0.7
    subviewsConstraints.image.width = imageView.widthAnchor.constraint(equalToConstant: width)
    subviewsConstraints.image.height = imageView.heightAnchor.constraint(equalToConstant: width)

    // title
    subviewsConstraints.title.top = title.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 5)
    subviewsConstraints.title.left = title.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10)
    subviewsConstraints.title.right = title.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10)
    subviewsConstraints.title.bottom = title.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)

    subviewsConstraints.activate()
  }

}

extension SearchResultCell {
  struct Constraints {
    let title = NSLayoutConstraintSet()
    let image = NSLayoutConstraintSet()

    private var all: [NSLayoutConstraintSet] { return [title, image] }

    func activate() { all.forEach { $0.activate() }}
    func deactivate() { all.forEach { $0.deactivate() }}
  }
}
