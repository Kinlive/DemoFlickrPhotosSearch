//
//  SearchResultViewModel.swift
//  DemoPhotoSearch
//
//  Created by Kinlive on 2020/7/12.
//  Copyright © 2020 Kinlive. All rights reserved.
//

import Foundation
import RxSwift

class SearchResultViewModel {


  private let provider: RequestCommunicator<FlickerType>
  private var currentPage: Int = 0

  private let disposeBag = DisposeBag()

  // Input
  let startRequest: AnyObserver<Void>
  let refreshActive: AnyObserver<Void>

  // Output
  let onFetchError = PublishSubject<Error>()
  let cellViewModel = PublishSubject<[SearchResultCellViewModel]>()
  let searchInfo: BehaviorSubject<SearchViewModel.SearchInfo>


  init(searchInfo: SearchViewModel.SearchInfo, provider: RequestCommunicator<FlickerType> = RequestCommunicator()) {
    self.provider = provider
    self.searchInfo = BehaviorSubject(value: searchInfo)

    let reload = PublishSubject<Void>()
    startRequest = reload.asObserver()

    let _refreshActive = PublishSubject<Void>()
    refreshActive = _refreshActive.asObserver()

    Observable.from([reload, _refreshActive]).merge()
      .subscribe(onNext: { [unowned self] _ in
        let requestType: FlickerType = .search(parameters: [
          "method" : "flickr.photos.search",
          "api_key" : "2d56edc1b27ddecc287336edac52ddba",
          "format"  : "json",
          "nojsoncallback" : "1",
          "text" : searchInfo.text,
          "per_page" : searchInfo.perPage,
          "page" : "\(self.currentPage)"
        ])

        self.request(type: requestType)
        self.currentPage = (Int(searchInfo.perPage) ?? 0)
      })
      .disposed(by: disposeBag)

  }

  // request to flicker
  func request(type: FlickerType) {
    provider.request(type: type) { [weak self] (result) in
      switch result {
      case .success(let response):
        do {
          // decode to SearchResultModel
          let model = try JSONDecoder().decode(SearchResultModel.self, from: response.data)
          // transfer to cellViewModel
          let viewModels = model.photos.photo.map { SearchResultCellViewModel(model: $0) }
          // pass viewModel to view
          self?.cellViewModel.onNext(viewModels)

        } catch let error {
          self?.onFetchError.onNext(error)
        }

      case .failure(let error):
        self?.onFetchError.onNext(error)
      }
    }
  }
}
