//
//  SearchResultModel.swift
//  DemoPhotoSearch
//
//  Created by Kinlive on 2020/7/12.
//  Copyright © 2020 Kinlive. All rights reserved.
//

import Foundation

struct SearchResultModel: Codable {
  let stat: String
  let photos: PhotoList
}

struct PhotoList: Codable {
  let perpage: Int
  let pages: Int
  let photo: [Photo]
  let total: String
  let page: Int
}

struct Photo: Codable {
  let owner: String
  let secret: String
  let server: String
  let id: String
  let farm: Int
  let title: String
  let isfriend: Int
  let isfamily: Int
  let ispublic: Int
}
