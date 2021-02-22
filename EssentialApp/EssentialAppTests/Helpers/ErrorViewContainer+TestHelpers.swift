//
//  ErrorViewContainer+TestHelpers.swift
//  EssentialAppTests
//
//  Created by Raphael Silva on 22/02/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import EssentialFeediOS
import UIKit

extension ErrorViewContainer where Self: UITableViewController {
	func simulateErrorViewTap() {
		errorView.simulateTap()
	}
}
