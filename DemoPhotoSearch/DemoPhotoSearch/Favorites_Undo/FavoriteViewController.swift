//
//  FavoriteViewController.swift
//  DemoPhotoSearch
//
//  Created by Kinlive on 2020/7/12.
//  Copyright © 2020 Kinlive. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class FavoriteViewController: UIViewController {

  lazy var demoLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.textColor = .black
    label.text = "Demo BBBBBB"
    return label
  }()

  private let viewModel: FavoriteViewModel
  private let constraints = Constraints()

  init(viewModel: FavoriteViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    addSubviews()
    view.backgroundColor = .white
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    layoutConstraints()
  }

  private func binds() {

  }

  private func addSubviews() {
    view.addSubview(demoLabel)
  }

  private func layoutConstraints() {
    constraints.demoLabel.centerX = demoLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
    constraints.demoLabel.centerY = demoLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)

    constraints.activate()
  }
}

extension FavoriteViewController {
  struct Constraints {
    let demoLabel = NSLayoutConstraintSet()

    private var all: [NSLayoutConstraintSet] { return [demoLabel] }
    func activate() { all.forEach { $0.activate() }}
    func deactivate() { all.forEach { $0.deactivate() }}
  }
}
