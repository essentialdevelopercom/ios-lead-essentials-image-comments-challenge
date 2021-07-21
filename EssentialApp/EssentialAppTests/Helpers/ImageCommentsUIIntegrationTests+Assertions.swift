//
// Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed
import EssentialFeediOS

extension ImageCommentsUIIntegrationTests {
	func assertThat(_ sut: ListViewController, isRendering comments: [ImageComment], file: StaticString = #filePath, line: UInt = #line) {
		sut.view.enforceLayoutCycle()

		guard sut.numberOfRenderedImageCommentsViews() == comments.count else {
			return XCTFail("Expected \(comments.count) images, got \(sut.numberOfRenderedImageCommentsViews()) instead.", file: file, line: line)
		}

		let viewModel = ImageCommentsPresenter.map(comments)

		viewModel.comments.enumerated().forEach { index, viewModel in
			assertThat(sut, hasViewConfiguredFor: viewModel, at: index, file: file, line: line)
		}

		executeRunLoopToCleanUpReferences()
	}

	func assertThat(_ sut: ListViewController, hasViewConfiguredFor viewModel: ImageCommentViewModel, at index: Int, file: StaticString = #filePath, line: UInt = #line) {
		let view = sut.imageCommentView(at: index)

		guard let cell = view as? ImageCommentCell else {
			return XCTFail("Expected \(ImageCommentCell.self) instance, got \(String(describing: view)) instead", file: file, line: line)
		}

		XCTAssertEqual(cell.messageText, viewModel.message, "Expected `messageLabel` to be \(viewModel.message) for image comment view at index (\(index))", file: file, line: line)

		XCTAssertEqual(cell.dateText, viewModel.date, "Expected `dateText` to be \(viewModel.date) for image comment view at index (\(index))", file: file, line: line)

		XCTAssertEqual(cell.usernameText, viewModel.authorUserName, "Expected `usernameText` to be \(viewModel.authorUserName) for image comment view at index (\(index))", file: file, line: line)
	}

	private func executeRunLoopToCleanUpReferences() {
		RunLoop.current.run(until: Date())
	}
}
