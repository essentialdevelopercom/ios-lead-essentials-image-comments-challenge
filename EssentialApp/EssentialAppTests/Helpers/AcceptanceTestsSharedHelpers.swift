//
//  AcceptanceTestsSharedHelpers.swift
//  EssentialAppTests
//
//  Created by Ángel Vázquez on 28/03/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import UIKit
import XCTest

protocol AcceptanceTest: XCTestCase {}

extension AcceptanceTest {
	func response(for url: URL) -> (Data, HTTPURLResponse) {
		let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
		return (makeData(for: url), response)
	}

	func makeData(for url: URL) -> Data {
		switch url.absoluteString {
		case "http://image.com":
			return makeImageData()
		case "https://ile-api.essentialdeveloper.com/essential-feed/v1/image/1F4A3B22-9E6E-46FC-BB6C-48B33269951B/comments":
			return makeImageCommentsData()
		default:
			return makeFeedData()
		}
	}

	func makeImageData() -> Data {
		return UIImage.make(withColor: .red).pngData()!
	}

	private func makeFeedData() -> Data {
		return try! JSONSerialization.data(withJSONObject: ["items": [
			["id": "1F4A3B22-9E6E-46FC-BB6C-48B33269951B", "image": "http://image.com"],
			["id": "11E123D5-1272-4F17-9B91-F3D0FFEC895A", "image": "http://image.com"]
		]])
	}

	private func makeImageCommentsData() -> Data {
		return try! JSONSerialization.data(withJSONObject: [
			"items": [
				[
					"id": UUID().uuidString,
					"message": "a message",
					"created_at": "2020-05-20T11:24:59+0000",
					"author": ["username": "an author"]
				],
				[
					"id": UUID().uuidString,
					"message": "another message",
					"created_at": "2020-05-19T14:23:53+0000",
					"author": ["username": "another author"]
				]
			]
		])
	}
}
