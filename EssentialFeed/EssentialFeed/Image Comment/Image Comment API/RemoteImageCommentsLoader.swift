//
//  RemoteImageCommentsLoader.swift
//  EssentialFeed
//
//  Created by Alok Subedi on 02/02/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public class RemoteImageCommentsLoader: ImageCommentsLoader {
	private let client: HTTPClient
	private let url: URL
	
	public init(client: HTTPClient, url: URL) {
		self.client = client
		self.url = url
	}
	
	public enum Error: Swift.Error {
		case connectivity
		case invalidData
	}
	
	public func load(completion: @escaping (ImageCommentsLoader.Result) -> Void) {
		client.get(from: url) { [weak self] result  in
			guard self != nil else { return }
			switch result {
			case let .success((data, response)):
				completion(RemoteImageCommentsLoader.map(data, from: response))
			case .failure:
				completion(.failure(Error.connectivity))
			}
		}
	}
	
	private static func map(_ data: Data, from response: HTTPURLResponse) -> ImageCommentsLoader.Result {
		do {
			let comments = try ImageCommentsMapper.map(data: data, from: response)
			return .success(comments)
		} catch {
			return.failure(error as! RemoteImageCommentsLoader.Error)
		}
	}
}
