//
//  FeedImageCommentsUIIntegrationTests+Localization.swift
//  EssentialAppTests
//
//  Created by Ivan Ornes on 27/3/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation
import XCTest
import EssentialFeed

extension FeedImageCommentsUIIntegrationTests {
	func localized(_ key: String, file: StaticString = #filePath, line: UInt = #line) -> String {
		let table = "Feed"
		let bundle = Bundle(for: FeedPresenter.self)
		let value = bundle.localizedString(forKey: key, value: nil, table: table)
		if value == key {
			XCTFail("Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
		}
		return value
	}
}
