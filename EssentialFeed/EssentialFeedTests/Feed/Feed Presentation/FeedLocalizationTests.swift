//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

final class FeedLocalizationTests: XCTestCase, XCTestLocalization {
    func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
        assertThatLocalizedStringsHaveKeysAndValuesForAllSupportedLocalizations(in: "Feed", for: FeedPresenter.self)
	}
}
