//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import UIKit

public final class ErrorView: UIView {
	public private(set) lazy var button = UIButton()
	private lazy var label: UILabel = UILabel()
	
	public var message: String? {
		get { return isVisible ? label.text : nil }
		set { setMessageAnimated(newValue) }
	}
	
	public override init(frame: CGRect) {
			super.init(frame: frame)
			configure()
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}
	
	private func configure() {
		backgroundColor = .errorBackgroundColor
		configureLabe()
		configureButton()
		setInitialState()
	}
	
	private var isVisible: Bool {
		return alpha > 0
	}
	
	private func configureLabe(){
		addSubview(label)
		label.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			label.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor, constant: 0),
			label.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor, constant: 0),
			label.topAnchor.constraint(equalTo: self.topAnchor, constant: 8),
			label.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8)
		])
		
		label.textAlignment = .center
		label.numberOfLines = 0
		label.adjustsFontForContentSizeCategory = true
		label.font = .preferredFont(forTextStyle: .body)
		label.textColor = .white
		label.backgroundColor = .clear
	}
	
	private func configureButton(){
		addSubview(button)
		button.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			button.leadingAnchor.constraint(equalTo: self.leadingAnchor),
			button.trailingAnchor.constraint(equalTo: self.trailingAnchor),
			button.topAnchor.constraint(equalTo: self.topAnchor),
			button.bottomAnchor.constraint(equalTo: self.bottomAnchor)
		])
		
		button.setTitle(nil, for: .normal)
		button.addTarget(self, action: #selector(hideMessageAnimated), for: .touchUpInside)
	}
	
	private func setInitialState(){
		onMessageHidden()
	}
	
	private func setMessageAnimated(_ message: String?) {
		if let message = message {
			showAnimated(message)
		} else {
			hideMessageAnimated()
		}
	}
	
	private func showAnimated(_ message: String) {
		label.text = message
		button.contentEdgeInsets = .zero
		
		UIView.animate(withDuration: 0.25) {
			self.alpha = 1
		}
	}
	
	@IBAction private func hideMessageAnimated() {
		UIView.animate(
			withDuration: 0.25,
			animations: { self.alpha = 0 },
			completion: { [weak self] completed in
				if completed { self?.onMessageHidden() }
			})
	}
	
	private func onMessageHidden(){
		self.label.text = nil
		alpha = 0
		button.contentEdgeInsets = .init(top: -4.0, left: 0, bottom: -4.0, right: 0)
	}
}


extension UIColor {
	static var errorBackgroundColor: UIColor {
		UIColor(red: 0.99951404330000004, green: 0.41759261489999999, blue: 0.4154433012, alpha: 1)
	}
}

