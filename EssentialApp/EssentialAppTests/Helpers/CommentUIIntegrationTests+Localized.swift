//
//  CommentUIIntegrationTests+Localized.swift
//  EssentialAppTests
//
//  Created by Khoi Nguyen on 7/1/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//
import EssentialFeed
import Foundation
import XCTest

extension CommentUIIntegrationTests {
	func localized(_ key: String, file: StaticString = #filePath, line: UInt = #line) -> String {
		let table = "Comment"
		let bundle = Bundle(for: CommentPresenter.self)
		let value = bundle.localizedString(forKey: key, value: nil, table: table)
		if value == key {
			XCTFail("Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
		}
		return value
	}
}
