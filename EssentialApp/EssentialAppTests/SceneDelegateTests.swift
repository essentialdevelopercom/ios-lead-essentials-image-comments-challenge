//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed
import EssentialFeediOS
@testable import EssentialApp

class SceneDelegateTests: XCTestCase {
	
	func test_configureWindow_setsWindowAsKeyAndVisible() {
		let window = UIWindow()
		let sut = SceneDelegate()
		sut.window = window
		
		sut.configureWindow()
		
		XCTAssertTrue(window.isKeyWindow, "Expected window to be the key window")
		XCTAssertFalse(window.isHidden, "Expected window to be visible")
	}
	
	func test_configureWindow_configuresRootViewController() {
		let sut = makeSUT()
		sut.configureWindow()
		
		let root = sut.window?.rootViewController
		let rootNavigation = root as? UINavigationController
		let topController = rootNavigation?.topViewController
		
		XCTAssertNotNil(rootNavigation, "Expected a navigation controller as root, got \(String(describing: root)) instead")
		XCTAssertTrue(topController is FeedViewController, "Expected a feed controller as top view controller, got \(String(describing: topController)) instead")
	}
	
	func test_didSelectFeedImage_navigateToCommentViewController() {
		let sut = makeSUT()
		sut.configureWindow()
		sut.didSelectFeedImage(makeImage())
		RunLoop.current.run(until: Date())
		
		let rootNavigation = sut.window?.rootViewController as? UINavigationController
		let topViewController = rootNavigation?.topViewController
		XCTAssertEqual(rootNavigation?.viewControllers.count, 2)
		XCTAssertTrue(topViewController is CommentViewController, "Expected a comment controller as top view controller, got \(String(describing: topViewController)) instead")
		
	}
	
	// MARK: - Helpers
	private func makeSUT(file: StaticString = #file, line: UInt = #line) -> SceneDelegate {
		let window = UIWindow()
		let sut = SceneDelegate()
		sut.window = window
		
		return sut
	}
	private func makeImage(description: String? = nil, location: String? = nil, url: URL = URL(string: "http://any-url.com")!) -> FeedImage {
		return FeedImage(id: UUID(), description: description, location: location, url: url)
	}
	
}
