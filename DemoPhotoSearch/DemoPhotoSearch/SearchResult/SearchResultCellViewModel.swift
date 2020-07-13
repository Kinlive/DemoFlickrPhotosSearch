//
//  SearchResultCellViewModel.swift
//  DemoPhotoSearch
//
//  Created by Kinlive on 2020/7/12.
//  Copyright © 2020 Kinlive. All rights reserved.
//

import UIKit
import RxSwift

class SearchResultCellViewModel {
  let disposeBag = DisposeBag()

  // Output
  let title: String
  let imageDownloaded: Observable<UIImage?>

  init(model: Photo) {

    title = model.title

    let imageUrlString = "https://farm\(model.farm).staticflickr.com/\(model.server)/\(model.id)_\(model.secret).jpg"

    imageDownloaded = Observable<UIImage?>.create({ (observer) -> Disposable in
        if let image = CacheManager.shared.photoCache.value(forKey: imageUrlString) {
          observer.onNext(image)
          observer.onCompleted()
        } else {
          DispatchQueue.global().async {
            do {
              if let url = URL(string: imageUrlString) {
                 let data = try Data(contentsOf: url)
                let image = UIImage(data: data)
                CacheManager.shared.photoCache.insert(image, forKey: imageUrlString)
                observer.onNext(image)
                observer.onCompleted()
              }
            } catch let error {
              observer.onError(error)
            }
          }
        }
      return Disposables.create {}
      })
      .observeOn(MainScheduler.instance)
      .asDriver(onErrorJustReturn: UIImage(named: "placeholder"))
      .asObservable()

  }

}
