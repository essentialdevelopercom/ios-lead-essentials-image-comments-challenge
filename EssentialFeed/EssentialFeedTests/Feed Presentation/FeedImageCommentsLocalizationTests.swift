//
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

final class FeedImageCommentsLocalizationTests: XCTestCase, XCTestLocalization {
    
    func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
        assertThatLocalizedStringsHaveKeysAndValuesForAllSupportedLocalizations(in: "FeedImageComments", for: FeedImageCommentsPresenter.self)
    }
}
