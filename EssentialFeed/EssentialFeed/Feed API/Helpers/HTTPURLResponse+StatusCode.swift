//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import Foundation

extension HTTPURLResponse {
	private static var OK_200: Int { return 200 }
    private static var OK_RANGE: ClosedRange<Int> { return 200 ... 299 }

	var isOK: Bool {
		return statusCode == HTTPURLResponse.OK_200
	}
    
    var isInSuccessRange: Bool {
        return HTTPURLResponse.OK_RANGE ~= statusCode
    }
}
