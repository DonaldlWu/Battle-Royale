//
//  FanPageWebViewController.swift
//  城市碰碰球-CityPonPon
//
//  Created by Vince Lee on 2017/10/12.
//  Copyright © 2017年 吳得人. All rights reserved.
//

import UIKit
import WebKit

class FanPageWebViewController: UIViewController {

    @IBOutlet weak var fabPageWebView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        goToFanPage()
        
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func goToFanPage() {
        let url = URL(string: "https://www.facebook.com/CityPonPon/")
        let urlRequest = URLRequest(url: url!)
        fabPageWebView.load(urlRequest)
        
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
