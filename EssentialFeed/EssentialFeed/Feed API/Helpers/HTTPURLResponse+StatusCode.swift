//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import Foundation

extension HTTPURLResponse {
	private static var OK_200: Int { return 200 }
	private static var successStatusCodesRange: Range<Int> { 200..<300 }
	
	var isOK: Bool {
		return statusCode == HTTPURLResponse.OK_200
	}
	
	var isWithinSuccessStatusCodes: Bool {
		HTTPURLResponse.successStatusCodesRange.contains(statusCode)
	}
}
