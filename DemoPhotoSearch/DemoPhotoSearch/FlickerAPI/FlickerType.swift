//
//  FlickerService.swift
//  DemoPhotoSearch
//
//  Created by Kinlive on 2020/7/12.
//  Copyright © 2020 Kinlive. All rights reserved.
//

import Foundation

enum FlickerType {
  case search(parameters: [String : Any])
}

extension FlickerType: RequestBaseType {
  var baseURL: URL {
      return URL(string: "https://www.flickr.com/services/rest/")!
  }

  var path: String {
      switch self {
      case .search:
        return ""
      }
  }

  var method: RequestMethod {
    return .post
  }

  var sampleData: Data {
      return "{}".data(using: .utf8)!
  }

  var task: RequestTasks {
    switch self {
    case .search(let params):
      return .requestParameters(parameters: params)
    }
  }

  var headers: [String : String]? {
      return nil
  }
}
