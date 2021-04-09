//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import XCTest
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
		let sut = SceneDelegate()
		sut.window = UIWindow()

		sut.configureWindow()

		let root = sut.window?.rootViewController
		let rootNavigation = root as? UINavigationController
		let topController = rootNavigation?.topViewController

		XCTAssertNotNil(rootNavigation, "Expected a navigation controller as root, got \(String(describing: root)) instead")
		XCTAssertTrue(topController is FeedViewController, "Expected a feed controller as top view controller, got \(String(describing: topController)) instead")
	}

	func test_navigation_canDisplayImageCommentsViewController() {
		let sut = SceneDelegate()
		sut.window = UIWindow()

		sut.configureWindow()

		sut.navigateToDetails(with: "id", animated: false)

		let root = sut.window?.rootViewController
		let rootNavigation = root as? UINavigationController

		let imageCommentsViewController = rootNavigation?.children.first(where: { $0 is ImageCommentsViewController })

		XCTAssertEqual(rootNavigation?.children.count, 2, "Expected two child view controllers, got \(String(describing: rootNavigation?.children.count)) instead")
		XCTAssertNotNil(imageCommentsViewController, "Expected an Image comments as the child view controller")
	}
}
