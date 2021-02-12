//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import Foundation

extension HTTPURLResponse {
	var isOK: Bool {
		(200...299).contains(statusCode)
	}
}
