//
//  CurrencyListModel.swift
//  BTG
//
//  Created by Guilherme Kauffmann on 17/01/21.
//

import Foundation

struct CurrencyListModel: Decodable {
    let success: Bool?
    let terms: String?
    let privacy: String?
    let currencies: Dictionary<String, String>?
    let error: ErrorCurrency?
}

struct ErrorCurrency: Decodable {
    let code: Int?
    let info: String?
}
