//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

final class FeedLocalizationTests: XCTestCase, XCTestCaseWithLocalization {
	
	func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
		assertThatLocalizedStringsHaveKeysAndValuesForAllSupportedLocalizations(table: "Feed", in: Bundle(for: FeedPresenter.self))
	}
}
