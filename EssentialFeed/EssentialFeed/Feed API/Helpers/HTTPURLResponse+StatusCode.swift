//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import Foundation

extension HTTPURLResponse {
	private static var OK_200: Int { return 200 }
	private static var OK_CODES: ClosedRange<Int> { 200...299 }

	
	var isOK: Bool {
		return statusCode == HTTPURLResponse.OK_200
	}
	
	var is200x: Bool {
		HTTPURLResponse.OK_CODES ~= statusCode
	}
	
}
