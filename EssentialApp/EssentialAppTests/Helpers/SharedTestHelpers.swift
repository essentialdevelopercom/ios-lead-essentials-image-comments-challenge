//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import Foundation
import EssentialFeed
import XCTest

func anyNSError() -> NSError {
	return NSError(domain: "any error", code: 0)
}

func anyURL() -> URL {
	return URL(string: "http://any-url.com")!
}

func anyData() -> Data {
	return Data("any data".utf8)
}

func uniqueFeed() -> [FeedImage] {
	return [FeedImage(id: UUID(), description: "any", location: "any", url: anyURL())]
}

func localized(_ key: String, in table: String, from bundle: Bundle, file: StaticString = #filePath, line: UInt = #line) -> String {
	let value = bundle.localizedString(forKey: key, value: nil, table: table)
	if value == key {
		XCTFail("Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
	}
	return value
}
