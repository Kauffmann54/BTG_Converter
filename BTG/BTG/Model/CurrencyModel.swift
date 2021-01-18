//
//  CurrencyModel.swift
//  BTG
//
//  Created by Guilherme Kauffmann on 16/01/21.
//

import Foundation

protocol CurrencyModelProtocol {
    var currencyValue: String { get set }
    var currencyName: String { get set }
    var currencyCode: String { get set }
    var currencyFlag: String { get set }
}

struct CurrencyModel: CurrencyModelProtocol {
    var currencyValue: String
    var currencyName: String
    var currencyCode: String
    var currencyFlag: String
    
}
