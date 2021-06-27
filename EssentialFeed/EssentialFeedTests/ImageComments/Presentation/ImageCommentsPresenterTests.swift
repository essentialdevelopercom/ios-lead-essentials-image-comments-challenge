
import XCTest
import EssentialFeed

class ImageCommentsPresenterTests: XCTestCase {
	func test_title_isLocalized() {
		XCTAssertEqual(ImageCommentsPresenter.title, localized("IMAGE_COMMENTS_VIEW_TITLE"))
	}

	func test_map_createsViewModel() {
		let currentDate = Date()
		let calendar = Calendar(identifier: .gregorian)
		let locale = Locale(identifier: "en_US_POSIX")

		let date1 = currentDate.adding(seconds: -20)
		let date2 = currentDate.adding(days: -5)

		let comment1 = ImageComment(id: UUID(), message: "a message", createdAt: date1, username: "an username")
		let comment2 = ImageComment(id: UUID(), message: "another message", createdAt: date2, username: "another username")

		let viewModel = ImageCommentsPresenter.map([comment1, comment2], currentDate: currentDate, calendar: calendar, locale: locale)

		let viewModels = [
			ImageCommentViewModel(
				message: "a message",
				date: "20 seconds ago",
				username: "an username"
			),
			ImageCommentViewModel(
				message: "another message",
				date: "5 days ago",
				username: "another username"
			)
		]

		XCTAssertEqual(viewModel.comments, viewModels)
	}

	// MARK: - Helpers

	private func localized(_ key: String, file: StaticString = #filePath, line: UInt = #line) -> String {
		let table = "ImageComments"
		let bundle = Bundle(for: ImageCommentsPresenter.self)
		let value = bundle.localizedString(forKey: key, value: nil, table: table)
		if value == key {
			XCTFail("Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
		}
		return value
	}
}
