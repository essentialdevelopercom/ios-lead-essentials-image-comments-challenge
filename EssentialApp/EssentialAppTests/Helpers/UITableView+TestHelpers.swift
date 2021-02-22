//
//  UITableView+TestHelpers.swift
//  EssentialAppTests
//
//  Created by Raphael Silva on 23/02/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import EssentialFeediOS
import UIKit

extension UITableView {
	func simulateTapOnErrorView() {
		tableHeaderView?.subviews.forEach {
			($0 as? ErrorView)?.simulateTap()
		}
	}
}
