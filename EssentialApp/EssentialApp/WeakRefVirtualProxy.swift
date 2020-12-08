//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import EssentialFeed

final class WeakRefVirtualProxy<T: AnyObject> {
	private(set) weak var object: T?
	
	init(_ object: T) {
		self.object = object
	}
}
