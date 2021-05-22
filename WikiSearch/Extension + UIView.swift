//
//  Extension + UIView.swift
//  WikiSearch
//
//  Created by saif ahmed on 15/05/21.
//  Copyright © 2021 Saif. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
extension UIView {
    func loadView(for name: String) -> UIView? {
        let bundle = Bundle(for: Self.self)
        let nib = UINib(nibName: name, bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as? UIView
    }
    func addXib(withName name: String? = nil) {
        let selfName = name ?? String(describing: type(of: self))
        guard let view = loadView(for: selfName) else { return }
        
        addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let constraints = [view.topAnchor.constraint(equalTo: topAnchor),
                           view.bottomAnchor.constraint(equalTo: bottomAnchor),
                           view.leadingAnchor.constraint(equalTo: leadingAnchor),
                           view.trailingAnchor.constraint(equalTo: trailingAnchor)]
        
        NSLayoutConstraint.activate(constraints)
    }
}

extension Reactive where Base: UITableView {
    var reload: Binder<Void> {
        return Binder(base) { (tableView, _) in
            tableView.reloadData()
            
        }
    }
}

extension Reactive where Base : UIView {
    var animateHide : Binder<CGFloat> {
        return Binder(base) { (view, alpha) in
            UIView.animate(withDuration: 1.0) {
                view.alpha = alpha
                view.isHidden = alpha == 0
            }
            
        }
    }
}
