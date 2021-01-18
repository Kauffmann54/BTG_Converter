//
//  Money.swift
//  BTG
//
//  Created by Guilherme Kauffmann on 16/01/21.
//

import Foundation

class Money {
    
    /// Formats the currency with the local currency code standard
    ///
    /// - Parameter value: Value to be formatted
    public static func currencyFormatter(value: Double) -> String {
        let currencyFormatter = NumberFormatter()
        currencyFormatter.usesGroupingSeparator = true
        currencyFormatter.numberStyle = .currency
        currencyFormatter.currencySymbol = ""

        if value < 0.1 {
            currencyFormatter.maximumFractionDigits = 6
        }

        return currencyFormatter.string(from: NSNumber(value: value))!
    }
    
    public static func converterToDouble(value: String) -> Double {
        let formatter = NumberFormatter()
        if value != "" && value != "nan" {
            var auxString = value.trimmingCharacters(in: .whitespaces)
            if auxString.contains(",") && auxString.contains(".") {
                for word in auxString {
                    if (word == ",") {
                        auxString = auxString.replacingOccurrences(of: ",", with: "")
                        formatter.numberStyle = .none
                        return Double(auxString)!
                    } else if (word == ".") {
                        auxString = auxString.replacingOccurrences(of: ".", with: "")
                        auxString = auxString.replacingOccurrences(of: ",", with: ".")
                        formatter.numberStyle = .none
                        auxString = auxString.trimmingCharacters(in: .whitespaces)
                        return Double(auxString)!
                    }
                }
            } else {
                auxString = auxString.replacingOccurrences(of: ",", with: ".")
                formatter.numberStyle = .none
                auxString = auxString.trimmingCharacters(in: .whitespaces)
                return Double(auxString)!
            }
        }
        
        return 0
    }
    
    /// Retrieves the flag from the currency code
    ///
    /// - Parameter country: Currency code
    public static func flag(country:String) -> String {
        let base : UInt32 = 127397
        var s = ""
        for v in country.unicodeScalars {
            s.unicodeScalars.append(UnicodeScalar(base + v.value)!)
        }
        return String(s.first!)
    }
}
