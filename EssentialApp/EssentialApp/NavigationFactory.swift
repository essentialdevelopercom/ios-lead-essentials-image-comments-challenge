//
//  NavigationFactory.swift
//  EssentialApp
//
//  Created by Anton Ilinykh on 13.04.2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import UIKit

protocol NavigationFactory {
	func makeControllerWith(rootViewController: UIViewController) -> UINavigationController
}

final class DefaultNavigationFactory: NavigationFactory {
	func makeControllerWith(rootViewController: UIViewController) -> UINavigationController {
		return UINavigationController(rootViewController: rootViewController)
	}
}
