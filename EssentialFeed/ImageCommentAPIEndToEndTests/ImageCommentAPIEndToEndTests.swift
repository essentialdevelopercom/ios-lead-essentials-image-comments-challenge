//
//  ImageCommentAPIEndToEndTests.swift
//  ImageCommentAPIEndToEndTests
//
//  Created by Alok Subedi on 02/02/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

class ImageCommentAPIEndToEndTests: XCTestCase {
	
	func test_endToEndServerGETImageCommentResult_matchesServerData() {
		let imageId = "31768993-1A2E-4B65-BD2A-D8AF06416730"
		
		let serverUrl = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed/v1/image/\(imageId)/comments")!
		let serverClient = URLSessionHTTPClient(session: .shared)
		let loader = RemoteImageCommentsLoader(client: serverClient, url: serverUrl)
		
		let exp = expectation(description: "Wait for load to complete")
		
		loader.load { result in
			switch result {
			case let .success(recievedComments):
				XCTAssertEqual(recievedComments.count, 3, "Expected 3 images in the test account image feed")
				
				recievedComments.enumerated().forEach { index, comment in
					XCTAssertEqual(comment, self.expectedComment(at: index))
				}
			case let .failure(error):
				XCTFail("Expected successful Image Comments, got \(error) instead")
			}
			exp.fulfill()
		}
		
		wait(for: [exp], timeout: 5.0)
	}
	
	//MARK: Helpers
	
	private func expectedComment(at index: Int) -> ImageComment {
		return ImageComment(id: id(at: index), message: message(at: index), createdDate: createdDate(at: index), author: author(at: index))
	}
	
	private func id(at index: Int) -> UUID {
		return UUID(uuidString: [
			"3ED3E961-55CB-4BEF-92FC-32AE53E56D03",
			"89D86E9E-BFBD-4D76-B0A0-367581E6407E",
			"71C9EDDB-8EE9-4B61-9F87-322437570B39",
		][index])!
	}
	
	private func message(at index: Int) -> String {
		return [
			"Opened to the public on 14 May 1896.",
			"In 1971, the pier closed on safety grounds, with ownership being passed to Arfon Borough Council in 1974.",
			"It was announced in August 2017 that major restoration work would take place at a cost of £1million, as the Pier has not received any major maintenance works for many years and is now in need of a refurbishment. The last restoration and renovation programme was in 1980s. The work will be funded by Bangor City Council and is likely to take up to three years to complete. Initially, the pier remained fully open to the public during the restoration works. However, following a structural report which found the pier head to be in a dangerous condition, it was closed to the public on a temporary basis in June 2018."
		][index]
	}
	
	private func createdDate(at index: Int) -> Date {
		return[
			Date(timeIntervalSince1970: 1601551431),
			Date(timeIntervalSince1970: 1600682510),
			Date(timeIntervalSince1970: 1596182400)
		][index]
	}
	
	private func author(at index: Int) -> CommentAuthor {
		return[
			CommentAuthor(username: "Marvin"),
			CommentAuthor(username: "Tyler"),
			CommentAuthor(username: "Mary")
		][index]
	}
}
