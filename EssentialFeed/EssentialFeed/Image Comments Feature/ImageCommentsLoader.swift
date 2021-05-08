import Foundation

public protocol ImageCommentsLoader {
	typealias Result = Swift.Result<[ImageComment], Error>

	func load(completion: @escaping (Result) -> Void)
}
