//
//  PageViewExtension.swift
//  城市碰碰球-CityPonPon
//
//  Created by Vince Lee on 2017/10/7.
//  Copyright © 2017年 吳得人. All rights reserved.
//

import Foundation
import UIKit

extension TutorialTableViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let currentIndex = pages.index(of: viewController)!
        if currentIndex == 0 {
            return nil
        }
        let previousIndex = abs((currentIndex - 1) % pages.count)
        return pages[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let currentIndex = pages.index(of: viewController)!
        if currentIndex == pages.count-1 {
            return nil
        }
        let nextIndex = abs((currentIndex + 1) % pages.count)
        return pages[nextIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        pendingIndex = pages.index(of: pendingViewControllers.first!)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            currentIndex = pendingIndex
            if let index = currentIndex {
                pageControl.currentPage = index
            }
        }
    }
    
    func setupPages() {
        // Setup the pages
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let page1: UIViewController! = storyboard.instantiateViewController(withIdentifier: "Page1")
        let page2: UIViewController! = storyboard.instantiateViewController(withIdentifier: "Page2")
        let page3: UIViewController! = storyboard.instantiateViewController(withIdentifier: "Page3")
        let page4: UIViewController! = storyboard.instantiateViewController(withIdentifier: "Page4")
        pages.append(page1)
        pages.append(page2)
        pages.append(page3)
        pages.append(page4)

        
        // Create the page container
        pageContainer = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pageContainer.delegate = self
        pageContainer.dataSource = self
        pageContainer.setViewControllers([page1], direction: UIPageViewControllerNavigationDirection.forward, animated: false, completion: nil)
       
        
        // Add it to the view
        
        firstCellView.addSubview(pageContainer.view)
        
        
        pageContainer.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint(item: pageContainer.view, attribute: .bottom, relatedBy: .equal, toItem: firstCellView, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: pageContainer.view, attribute: .top, relatedBy: .equal, toItem: firstCellView, attribute: .top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: pageContainer.view, attribute: .leading, relatedBy: .equal, toItem: firstCellView, attribute: .leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: pageContainer.view, attribute: .trailing, relatedBy: .equal, toItem: firstCellView, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
        // Configure our custom pageControl
        
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
    }
    
}


