//
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import EssentialFeed
import XCTest

final class ImageCommentsLocalizationTests: XCTestCase, XCTestLocalization {
    func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
        assertThatLocalizedStringsHaveKeysAndValuesForAllSupportedLocalizations(in: "ImageComments", for: ImageCommentsPresenter.self)
    }
}
