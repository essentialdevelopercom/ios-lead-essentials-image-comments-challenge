//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import Foundation
import XCTest
import EssentialFeed

extension FeedUIIntegrationTests {
	func localized(_ key: String, file: StaticString = #filePath, line: UInt = #line) -> String {
		return EssentialAppTests.localized(key, in: "Feed", from: Bundle(for: FeedPresenter.self))
	}
}
