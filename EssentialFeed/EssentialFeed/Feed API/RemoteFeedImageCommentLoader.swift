//
//  RemoteFeedImageCommentLoader.swift
//  EssentialFeed
//
//  Created by Mario Alberto Barragán Espinosa on 05/02/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public class RemoteFeedImageCommentLoader: FeedImageCommentLoader {
	private let client: HTTPClient
	
	public init(client: HTTPClient) {
		self.client = client
	}
	
	public enum Error: Swift.Error {
		case connectivity
		case invalidData
	}
	
	public func loadImageCommentData(from url: URL, completion: @escaping (FeedImageCommentLoader.Result) -> Void) {
		client.get(from: url) { result in
			switch result {
			case let .success((data, _)):
				if let _ = try? JSONSerialization.jsonObject(with: data) {
					completion(.success([]))
				} else {
					completion(.failure(Error.invalidData))
				}
				
			case .failure:
				completion(.failure(Error.connectivity))
			}
		}
	}
}
