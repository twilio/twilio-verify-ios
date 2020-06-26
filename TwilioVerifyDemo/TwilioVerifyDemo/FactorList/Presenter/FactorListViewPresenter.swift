//
//  FactorListViewPresenter.swift
//  TwilioVerifyDemo
//
//  Created by Santiago Avila on 6/25/20.
//  Copyright © 2020 Twilio. All rights reserved.
//

import Foundation
import TwilioVerify

protocol FactorListPresentable {
  func append(_ factor: Factor)
  func numberOfItems() -> Int
  func factor(at index: Int) -> Factor
}

class FactorListPresenter {
  
  private weak var view: FactorListView?
  private var factors: [Factor]
  
  init(withView view: FactorListView) {
    self.view = view
    self.factors = [Factor]()
  }
}

extension FactorListPresenter: FactorListPresentable {
  func append(_ factor: Factor) {
    factors.append(factor)
    view?.reloadData()
  }
  
  func numberOfItems() -> Int {
    factors.count
  }
  
  func factor(at index: Int) -> Factor {
    factors[index]
  }
}
