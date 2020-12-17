//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import Foundation

extension HTTPURLResponse {
	private static var OK_200: Int { return 200 }
	private static var SUCCESS_RANGE: ClosedRange<Int> { return 200 ... 299 }
	
	var isOK: Bool {
		return statusCode == HTTPURLResponse.OK_200
	}

	public var isInSuccessRange: Bool {
		return HTTPURLResponse.SUCCESS_RANGE ~= statusCode
	}
}
