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
  func getFactors()
  func numberOfItems() -> Int
  func factor(at index: Int) -> Factor
}

class FactorListPresenter {
  
  private weak var view: FactorListView?
  private let twilioVerify: TwilioVerify
  private var factors: [Factor]
  
  init(withView view: FactorListView,
       twilioVerify: TwilioVerify = TwilioVerifyAdapter()) {
    self.view = view
    self.twilioVerify = twilioVerify
    self.factors = [Factor]()
  }
}

extension FactorListPresenter: FactorListPresentable {
  func getFactors() {
    twilioVerify.getAllFactors(success: { [weak self] factorList in
      guard let strongSelf = self else { return }
      strongSelf.factors = factorList
      strongSelf.view?.reloadData()
    }) { error in
      print(error.localizedDescription)
    }
  }
  
  func numberOfItems() -> Int {
    factors.count
  }
  
  func factor(at index: Int) -> Factor {
    factors[index]
  }
}
