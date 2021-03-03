//
//  RemoteFeedImageCommentsLoader.swift
//  EssentialFeed
//
//  Created by Anton Ilinykh on 03.03.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public final class RemoteFeedImageCommentsLoader {
	private let client: HTTPClient
	private let url: URL
	
	public enum Error: Swift.Error {
		case connectivity
		case invalidData
	}
	
	public init(client: HTTPClient, url: URL) {
		self.client = client
		self.url = url
	}
	
	public func load(completion: @escaping (Error) -> Void) {
		client.get(from: url, completion: { result in
			switch result {
			case .success(_):
				completion(.invalidData)
			case .failure(_):
				completion(.connectivity)
			}
		})
	}
}
