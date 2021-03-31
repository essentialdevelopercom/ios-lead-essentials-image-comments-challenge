//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import Foundation

func anyNSError() -> NSError {
	return NSError(domain: "any error", code: 0)
}

func anyURL() -> URL {
	return URL(string: "http://any-url.com")!
}

func anyData() -> Data {
	return Data("any data".utf8)
}

extension Date {
	func minusFeedCacheMaxAge() -> Date {
		adding(days: -feedCacheMaxAgeInDays)
	}
	
	var feedCacheMaxAgeInDays: Int {
		7
	}
	
	func adding(days: Int) -> Date {
		Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
	}
	
	func adding(seconds: TimeInterval) -> Date {
		return self + seconds
	}
}
