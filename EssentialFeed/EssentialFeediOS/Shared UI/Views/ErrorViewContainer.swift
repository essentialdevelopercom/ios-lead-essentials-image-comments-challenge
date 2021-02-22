//
//  ErrorViewContainer.swift
//  EssentialFeediOS
//
//  Created by Raphael Silva on 22/02/2021.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import UIKit

public protocol ErrorViewContainer {
	var errorView: ErrorView { get }
}

extension ErrorViewContainer where Self: UITableViewController {
	func configureErrorView() {
		let container = UIView()
		container.backgroundColor = .clear
		container.addSubview(errorView)
		
		errorView.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			errorView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
			container.trailingAnchor.constraint(equalTo: errorView.trailingAnchor),
			errorView.topAnchor.constraint(equalTo: container.topAnchor),
			container.bottomAnchor.constraint(equalTo: errorView.bottomAnchor),
		])
		
		tableView.tableHeaderView = container
		
		errorView.onHide = { [weak self] in
			self?.tableView.beginUpdates()
			self?.tableView.sizeTableHeaderToFit()
			self?.tableView.endUpdates()
		}
	}
}
