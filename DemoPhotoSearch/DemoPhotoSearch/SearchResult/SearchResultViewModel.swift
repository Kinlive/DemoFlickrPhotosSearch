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
  private var increaseCellViewModel: [SearchResultCellViewModel] = []
  private let disposeBag = DisposeBag()

  // Input
  let startRequest: AnyObserver<Int?>
  let refreshActive: AnyObserver<Int?>

  // Output
  let onFetchError = PublishSubject<Error>()
  let cellViewModel = PublishSubject<[SearchResultCellViewModel]>()
  let searchInfo: BehaviorSubject<SearchViewModel.SearchInfo>


  init(searchInfo: SearchViewModel.SearchInfo, provider: RequestCommunicator<FlickerType> = RequestCommunicator()) {
    self.provider = provider
    self.searchInfo = BehaviorSubject(value: searchInfo)

    let reload = PublishSubject<Int?>()
    startRequest = reload.asObserver()

    let _refreshActive = PublishSubject<Int?>()
    refreshActive = _refreshActive.asObserver()

    // oberserve when event passed by startRequest and refreshActive
    Observable.from([reload, _refreshActive]).merge()
      .compactMap { $0 == nil ? 0 : $0 }
      .subscribe(onNext: { [unowned self] currentPage in
        let requestType: FlickerType = .search(parameters: [
          "method" : "flickr.photos.search",
          "api_key" : "2d56edc1b27ddecc287336edac52ddba",
          "format"  : "json",
          "nojsoncallback" : "1",
          "text" : searchInfo.text,
          "per_page" : searchInfo.perPage,
          "page" : "\(currentPage)"
        ])

        self.request(type: requestType, currentPage: currentPage)
        self.currentPage += (Int(searchInfo.perPage) ?? 0)
      })
      .disposed(by: disposeBag)

  }

  // request to flicker
  func request(type: FlickerType, currentPage: Int) {
    provider.request(type: type) { [weak self] (result) in
      guard let `self` = self else { return }
      switch result {
      case .success(let response):
        do {
          // decode to SearchResultModel
          let model = try JSONDecoder().decode(SearchResultModel.self, from: response.data)
          // transfer to cellViewModel
          let viewModels = model.photos.photo.map { SearchResultCellViewModel(model: $0) }
          // use current page to switch to show reload or get more pages
          if currentPage == 0 {
            self.increaseCellViewModel = viewModels
          } else {
            self.increaseCellViewModel.append(contentsOf: viewModels)
          }

          // pass cellViewModel
          self.cellViewModel.onNext(self.increaseCellViewModel)

        } catch let error {
          self.onFetchError.onNext(error)
        }

      case .failure(let error):
        self.onFetchError.onNext(error)
      }
    }
  }
}
