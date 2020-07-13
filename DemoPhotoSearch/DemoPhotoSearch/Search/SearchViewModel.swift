//
//  SearchViewModel.swift
//  DemoPhotoSearch
//
//  Created by Kinlive on 2020/7/11.
//  Copyright © 2020 Kinlive. All rights reserved.
//

import UIKit
import RxSwift

class SearchViewModel {

  struct SearchInfo {
    let text: String
    let perPage: String
  }

  // Input
  let searchText: AnyObserver<String>
  let perPage: AnyObserver<String>

  // Output
  let isSendButtonEnable: Observable<Bool>

  init() {

    let _searchText = PublishSubject<String>()
    searchText = _searchText.asObserver()

    let _perPage = PublishSubject<String>()
    perPage = _perPage.asObserver()

    isSendButtonEnable = Observable.combineLatest(_searchText, _perPage)
      .map { !$0.isEmpty && !$1.isEmpty }

  }
}
