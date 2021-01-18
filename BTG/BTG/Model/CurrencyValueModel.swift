//
//  CurrencyValueModel.swift
//  BTG
//
//  Created by Guilherme Kauffmann on 16/01/21.
//

import Foundation

struct CurrencyValueModel: Decodable {
    let success: Bool?
    let terms: String?
    let privacy: String?
    let timestamp: Int?
    let source: String?
    let quotes: Dictionary<String, Double>?
    let error: ErrorCurrency?
}

