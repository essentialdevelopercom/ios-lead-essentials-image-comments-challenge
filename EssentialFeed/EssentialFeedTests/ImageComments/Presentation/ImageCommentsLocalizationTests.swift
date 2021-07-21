//
// Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

class ImageCommentsLocalizationTests: XCTestCase {
	func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
		let table = "Comments"
		let bundle = Bundle(for: ImageCommentsPresenter.self)

		assertLocalizedKeyAndValuesExist(in: bundle, table)
	}
}
