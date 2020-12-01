//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

class FeedLocalizationTests: XCTestCase, XCTestLocalization {
	func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
		assertThatLocalizedStringsHaveKeysAndValuesForAllSupportedLocalizations(in: "Feed", for: FeedPresenter.self)
	}
}
