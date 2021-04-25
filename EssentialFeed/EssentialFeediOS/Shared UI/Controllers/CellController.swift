//
//  CellController.swift
//  EssentialFeediOS
//
//  Created by Antonio Mayorga on 4/24/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import UIKit

public struct CellController {
	let dataSource: UITableViewDataSource
	let delegate: UITableViewDelegate?
	let dataSourcePrefetching: UITableViewDataSourcePrefetching?

	public init(_ dataSource: UITableViewDataSource & UITableViewDelegate & UITableViewDataSourcePrefetching) {
		self.dataSource = dataSource
		self.delegate = dataSource
		self.dataSourcePrefetching = dataSource
	}

	public init(_ dataSource: UITableViewDataSource) {
		self.dataSource = dataSource
		self.delegate = nil
		self.dataSourcePrefetching = nil
	}
}
