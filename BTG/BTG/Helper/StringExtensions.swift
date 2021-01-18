//
//  StringExtensions.swift
//  BTG
//
//  Created by Guilherme Kauffmann on 17/01/21.
//

import UIKit

extension String {
    func removeAccent() -> String {
        return self.folding(options: .diacriticInsensitive, locale: .current)
    }
}
