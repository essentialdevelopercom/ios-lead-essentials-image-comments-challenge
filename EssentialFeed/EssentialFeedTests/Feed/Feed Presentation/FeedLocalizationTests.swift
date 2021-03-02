//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

final class FeedLocalizationTests: XCTestCase, LocalizationTests{
	
	func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
		let table = "Feed"
		let presentationBundle = Bundle(for: FeedPresenter.self)
		assertLocalization(for: table, in: presentationBundle)
	}
}

final class ImageCommentsLocalizationTests: XCTestCase, LocalizationTests{
	
	func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
		let table = "ImageComments"
		let presentationBundle = Bundle(for: ImageCommentsPresenter.self)
		assertLocalization(for: table, in: presentationBundle)
	}
}
