
import XCTest
import EssentialFeed

class ImageCommentsPresenterTests: XCTestCase {
	func test_title_isLocalized() {
		XCTAssertEqual(ImageCommentsPresenter.title, localized("IMAGE_COMMENTS_VIEW_TITLE"))
	}

	func test_map_createsViewModel() {
		let (comments, viewModels) = uniqueImageComments()

		let viewModel = ImageCommentsPresenter.map(comments)

		XCTAssertEqual(viewModel.comments, viewModels)
	}

	private func uniqueImageComment() -> ImageComment {
		let currentDate = Date()
		return ImageComment(id: UUID(), message: "a message", createdAt: currentDate, author: Author(username: "an username"))
	}

	private func uniqueImageComments() -> (models: [ImageComment], viewModels: [ImageCommentViewModel]) {
		let models = [uniqueImageComment(), uniqueImageComment()]
		let formatter = RelativeDateTimeFormatter()
		let currentDate = Date()
		let viewModels = models.map {
			ImageCommentViewModel(
				message: $0.message,
				date: formatter.localizedString(for: $0.createdAt, relativeTo: currentDate),
				username: $0.author.username) }
		return (models, viewModels)
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
