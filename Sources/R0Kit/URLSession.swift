// Copyright (c) 1868 Charles Babbage
// Found amongst his effects by r0ml

import Foundation
import Combine

public enum HTTPError : LocalizedError {
  case statusCode(Int)
}

/**
 returns a Publisher for a URL that emits the returned JSON as [String:Any]
  Ideally, I should use decode and return an object, but for many endpoints, the JSON does not map well onto an Object
 */
extension URLSession {
  public func jsonPublisher(for u : URL) -> AnyPublisher<[String:Any], Error> {
    return URLSession.shared.dataTaskPublisher(for: u)
      .tryMap { output -> Data in
        if let response = output.response as? HTTPURLResponse {
          if response.statusCode == 200 {
            return output.data
          } else {
            throw HTTPError.statusCode(response.statusCode)
          }
        } else {
          throw HTTPError.statusCode(901)
        }
      }
      .tryMap { data -> Any in
        return try JSONSerialization.jsonObject(with: data)
      }
      .compactMap { json in
        return json as? [String:Any]
      }.eraseToAnyPublisher()
  }
}
