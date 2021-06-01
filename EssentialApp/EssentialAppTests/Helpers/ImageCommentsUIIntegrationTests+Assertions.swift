//
// Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed
import EssentialFeediOS

extension ImageCommentsUIIntegrationTests {
	func assertThat(_ sut: ListViewController, isRendering comments: [ImageComment], currentDate: Date,
	                file: StaticString = #filePath, line: UInt = #line) {
		sut.view.enforceLayoutCycle()
		XCTAssertEqual(sut.numberOfRenderedComments(), comments.count, "comments count", file: file, line: line)

		let viewModel = ImageCommentsPresenter.map(comments, currentDate: currentDate)

		viewModel.comments.enumerated().forEach { index, comment in
			XCTAssertEqual(sut.commentMessage(at: index), comment.message, "message at \(index)", file: file, line: line)
			XCTAssertEqual(sut.commentCreatedAt(at: index), comment.createdAt, "createdAt at \(index)", file: file, line: line)
			XCTAssertEqual(sut.commentUsername(at: index), comment.username, "username at \(index)", file: file, line: line)
		}
	}
}
