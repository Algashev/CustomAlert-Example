//
//  AlertWindow.swift
//  CustomAlert-Example
//
//  Created by William Boles on 26/10/2019.
//  Copyright © 2019 William Boles. All rights reserved.
//

import UIKit

class AlertWindow: UIWindow {
    var viewController: UIViewController {
        return holdingViewController.containerViewController.childViewController
    }
    
    private let holdingViewController: HoldingViewController
    
    // MARK: - Init
    
    init(withViewController viewController: UIViewController) {
        holdingViewController = HoldingViewController(withViewController: viewController)
        super.init(frame: UIScreen.main.bounds)
        
        rootViewController = holdingViewController
        
        windowLevel = .alert
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("Unavailable")
    }
    
    // MARK: - Present
    
    func present() {
        makeKeyAndVisible()
    }
    
    // MARK: - Dismiss
    
    func dismiss(completion: @escaping (() -> Void)) {
        holdingViewController.dismissAlert { [weak self] in
            self?.resignKeyAndHide()
            completion()
        }
    }
    
    // MARK: - Resign
    
    private func resignKeyAndHide() {
        resignKey()
        isHidden = true
    }
}

fileprivate class HoldingViewController: UIViewController {
    let containerViewController: AlertContainerViewController
    
    // MARK: - Init
    
    init(withViewController viewController: UIViewController) {
        containerViewController = AlertContainerViewController(withChildViewController: viewController)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - ViewLifecycle
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        present(containerViewController, animated: true, completion: nil)
    }
    
    // MARK: - Dismiss
    
    func dismissAlert(completion: @escaping (() -> Void)) {
        containerViewController.dismiss(animated: true, completion: {
            completion()
        })
    }
    
    
}

fileprivate class AlertContainerViewController: UIViewController {
    let childViewController: UIViewController
    
    // MARK: - Init
    
    init(withChildViewController childViewController: UIViewController) {
        self.childViewController = childViewController
        super.init(nibName: nil, bundle: nil)
        
        self.modalPresentationStyle = .custom
        self.transitioningDelegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - ViewLifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .darkGray.withAlphaComponent(0.75)
        
        addChild(childViewController)
        view.addSubview(childViewController.view)
        childViewController.didMove(toParent: self)
        
        childViewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            childViewController.view.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            childViewController.view.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            childViewController.view.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor, multiplier: 1),
            childViewController.view.heightAnchor.constraint(lessThanOrEqualTo: view.heightAnchor, multiplier: 1),
        ])
    }
}

// MARK: UIViewControllerTransitioningDelegate

extension AlertContainerViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return CustomAlertPresentAnimationController()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return CustomAlertDismissAnimationController()
    }
}

fileprivate class CustomAlertPresentAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    
    // MARK: - UIViewControllerAnimatedTransitioning
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.2
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toViewController = transitionContext.viewController(forKey: .to),
            let snapshot = toViewController.view.snapshotView(afterScreenUpdates: true)
            else {
                return
        }
        
        let containerView = transitionContext.containerView
        let finalFrame = transitionContext.finalFrame(for: toViewController)
        
        snapshot.frame = finalFrame
        snapshot.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        snapshot.alpha = 0.0
        
        containerView.addSubview(toViewController.view)
        containerView.addSubview(snapshot)
        toViewController.view.isHidden = true
        
        let duration = transitionDuration(using: transitionContext)
        
        UIView.animate(withDuration: duration, animations: {
            snapshot.alpha = 1.0
            snapshot.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        }) { _ in
            toViewController.view.isHidden = false
            snapshot.removeFromSuperview()
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}

fileprivate class CustomAlertDismissAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    
    // MARK: - UIViewControllerAnimatedTransitioning
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.2
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromViewController = transitionContext.viewController(forKey: .from),
            let snapshot = fromViewController.view.snapshotView(afterScreenUpdates: true)
            else {
                return
        }
        
        let containerView = transitionContext.containerView
        let finalFrame = transitionContext.finalFrame(for: fromViewController)
        
        snapshot.frame = finalFrame
        
        containerView.addSubview(snapshot)
        fromViewController.view.isHidden = true
        
        let duration = transitionDuration(using: transitionContext)
        
        UIView.animate(withDuration: duration, animations: {
            snapshot.alpha = 0.0
        }) { _ in
            snapshot.removeFromSuperview()
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}
