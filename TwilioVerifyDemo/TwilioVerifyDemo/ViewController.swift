//
//  ViewController.swift
//  TwilioVerifyDemo
//
//  Created by Santiago Avila on 5/15/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import UIKit
import TwilioVerify

class ViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    let asd = RequestHelper.init()
    asd.userAgentHeader()
  }


}

