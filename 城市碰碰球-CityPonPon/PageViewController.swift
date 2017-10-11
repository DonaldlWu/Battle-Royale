//
//  PageViewController.swift
//  Battle Royale
//
//  Created by Vince Lee on 2017/9/23.
//  Copyright © 2017年 吳得人. All rights reserved.
//

import UIKit

class PageViewController: UIPageViewController, UIPageViewControllerDataSource {
    
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        let previousIndex = index - 1
        
        guard previousIndex >= 0 && previousIndex < orderedViewControllers.count else {
            return nil
        }
        return orderedViewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        let nextIndex = index + 1
        guard nextIndex >= 0 && nextIndex < orderedViewControllers.count else {
            return nil
        }
        return orderedViewControllers[nextIndex]
    }
    

    
    lazy var page1ViewController: Page1ViewController = {
        self.storyboard!.instantiateViewController(withIdentifier: "Page1") as! Page1ViewController
    }()
    lazy var page2ViewController: Page2ViewController = {
        self.storyboard!.instantiateViewController(withIdentifier: "Page2") as! Page2ViewController
    }()
    lazy var page3ViewController: Page3ViewController = {
        self.storyboard!.instantiateViewController(withIdentifier: "Page3") as! Page3ViewController
    }()
    
    
    lazy var orderedViewControllers: [UIViewController] = {
        [self.page1ViewController, self.page2ViewController, self.page3ViewController]
    }()
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
        setViewControllers([page1ViewController], direction: .forward, animated: true, completion: nil)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
