//
//  CommentErrorView.swift
//  EssentialFeediOS
//
//  Created by Ángel Vázquez on 22/03/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import UIKit

public class CommentErrorView: UIView {
	private(set) public lazy var button: UIButton = makeButton()
	
	public var message: String? {
		get { return button.title(for: .normal) }
	}
	
	func show(message: String) {
		button.setTitle(message, for: .normal)
	}
	
	@objc func hideMessage() {
		button.setTitle(nil, for: .normal)
	}
	
	private func makeButton() -> UIButton {
		let button = UIButton()
		button.setTitle(nil, for: .normal)
		button.addTarget(self, action: #selector(hideMessage), for: .touchUpInside)
		return button
	}
}
