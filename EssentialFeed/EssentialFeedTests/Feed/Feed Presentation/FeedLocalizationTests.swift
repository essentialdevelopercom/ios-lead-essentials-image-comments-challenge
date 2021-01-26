//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

final class FeedLocalizationTests: XCTestCase {
	func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
		let table = "Feed"
		let presentationBundle = Bundle(for: FeedPresenter.self)
		
		checkLocalizedStrings_haveKeysAndValuesForAllSupportedLocalizations(for: table, in: presentationBundle)
	}
}
