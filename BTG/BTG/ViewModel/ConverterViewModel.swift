//
//  ConverterViewModel.swift
//  BTG
//
//  Created by Guilherme Kauffmann on 16/01/21.
//

import Foundation

class ConverterViewModel : NSObject {
    // MARK: - Properties

    private var apiService : APIService!
    public var currencyModelSource: CurrencyModel?
    public var currencyModelDestiny: CurrencyModel?
    private(set) var currencyValueModel: CurrencyValueModel? {
        didSet {
            self.bindCurrencyViewModelToController()
        }
    }
    
    private var currencyValor1: String?
    private var currencyValor2: String?
    private var currencyCode1: String?
    private var currencyCode2: String?
    private var currencyFlag1: String?
    private var currencyFlag2: String?
    private var dateUpdate: String?
    private var valueCurrency: String?
    
    var bindCurrencyViewModelToController: (() -> ()) = {}
        
    public var currencyValor1Text: String {
        return formatterMoney(value: currencyModelSource!.currencyValue)
    }
    
    public var currencyValor2Text: String {
        return formatterMoney(value: currencyModelDestiny!.currencyValue)
    }
    
    public var currencyCode1Text: String {
        return currencyModelSource!.currencyCode
    }
    
    public var currencyCode2Text: String {
        return currencyModelDestiny!.currencyCode
    }
    
    public var currencyFlag1Text: String {
        return currencyModelSource!.currencyFlag
    }

    public var currencyFlag2Text: String {
        return currencyModelDestiny!.currencyFlag
    }
    
    
    public var dateUpdateText: String {
        if currencyValueModel == nil || currencyValueModel!.timestamp == 0 {
            return ""
        }
        let date = Date(timeIntervalSince1970: TimeInterval(currencyValueModel!.timestamp ?? 0))
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm"
        return dateFormatter.string(from: date)
    }
    
    public var valueCurrencyText: String {
        if currencyValueModel != nil && currencyValueModel?.quotes != nil {
            var currencySourceValue: Double = 0
            var currencyDestinyValue: Double = 0
            for currency in currencyValueModel!.quotes! {
                if currency.key == currencyValueModel!.source! + currencyModelSource!.currencyCode {
                    currencySourceValue = currency.value
                }
                if currency.key == currencyValueModel!.source! + currencyModelDestiny!.currencyCode {
                    currencyDestinyValue = currency.value
                }
            }
            
            return "1 \(currencyModelSource?.currencyCode ?? "") = \(Money.currencyFormatter(value: currencyDestinyValue/currencySourceValue)) \(currencyModelDestiny?.currencyCode ?? "")"
        }
        
        return ""
    }
    
    /// Initializes API, retrieves the source and destination currency locally, fetches the current quote
    override init() {
        super.init()
        self.apiService = APIService()
        self.getCurrencySelected()
        self.getCurrencyLiveCoreData()
    }
    
    // MARK: - Funtions
    
    /// Format keyboard text input
    ///
    /// - Parameter value: keyboard text input
    func formatterTextMoney(value: String) -> String {
        let money = Int(Money.converterToDouble(value: value.replacingOccurrences(of: ".", with: "").replacingOccurrences(of: ",", with: "").replacingOccurrences(of: " ", with: "")))
        let value = (Double(String(money)) ?? 0)/100
        return Money.currencyFormatter(value: value)
    }
    
    /// Format the currency value
    ///
    /// - Parameter value: keyboard text input
    func formatterMoney(value: String) -> String {
        let money = Money.converterToDouble(value: value)
        return Money.currencyFormatter(value: money)
    }
    
    /// Updates source currency ownership and saves locally
    ///
    /// - Parameter value: keyboard text input
    func updateCurrencyValueSource(value: String, completion: @escaping () -> ()) {
        if Money.converterToDouble(value: value) <= 999999999999.99 {
            currencyModelSource = CurrencyModel(currencyValue: formatterTextMoney(value: value), currencyName: currencyModelSource!.currencyName
                                                , currencyCode: currencyModelSource!.currencyCode, currencyFlag: currencyModelSource!.currencyFlag)
            CurrencyCoreData.saveCurrencySource(currencyModel: currencyModelSource!)
        }
        completion()
    }
    
    /// Updates target currency ownership and saves locally
    func updateCurrencyValueDestiny(completion: @escaping () -> ()) {
        calculateCurrencyValue(value: Money.converterToDouble(value: (currencyModelSource!.currencyValue)), completion: {
            CurrencyCoreData.saveCurrencyDestiny(currencyModel: self.currencyModelDestiny!)
            completion()
        })
    }
    
    /// Replaces the source currency with the target currency
    func changeCurrency(completion: @escaping () -> ()) {
        let currencyModelSourceAux = currencyModelSource
        currencyModelSource = CurrencyModel(currencyValue: currencyModelSourceAux!.currencyValue, currencyName: currencyModelDestiny!.currencyName, currencyCode: currencyModelDestiny!.currencyCode, currencyFlag: currencyModelDestiny!.currencyFlag)
        currencyModelDestiny = CurrencyModel(currencyValue: "0", currencyName: currencyModelSourceAux!.currencyName, currencyCode: currencyModelSourceAux!.currencyCode, currencyFlag: currencyModelSourceAux!.currencyFlag)
        calculateCurrencyValue(value: Money.converterToDouble(value: (currencyModelSourceAux!.currencyValue))) {
            
        }
        CurrencyCoreData.saveCurrencySource(currencyModel: currencyModelSource!)
        CurrencyCoreData.saveCurrencyDestiny(currencyModel: currencyModelDestiny!)
        completion()
    }
    
    /// Checks if you have the current quote and if it has not been updated in less than 1 hour, otherwise request a new one through the API
    func getCurrencyLiveCoreData() {
        CurrencyCoreData.retriveLive { (currencyValueObject) in
            if currencyValueObject != nil {
                let success = currencyValueObject!.value(forKey: "success") as? Bool
                let terms = currencyValueObject!.value(forKey: "terms") as? String
                let privacy = currencyValueObject!.value(forKey: "privacy") as? String
                let source = currencyValueObject!.value(forKey: "source") as? String
                let quotes = currencyValueObject!.value(forKey: "quotes") as? Dictionary<String, Double>
                let timestamp = currencyValueObject!.value(forKey: "timestamp") as? Int
                
                
                let dateAtual = Date()
                let dateCoreData = dateAtual - Date(timeIntervalSince1970: TimeInterval(timestamp ?? 0))
                if dateCoreData.hour! >= 1 { // Checks if it has past 1 hour to update the quote
                    self.getCurrencyLive { (retrieve) in
                        if retrieve == false {
                            self.currencyValueModel = CurrencyValueModel(success: success ?? false, terms: terms ?? "", privacy: privacy ?? "", timestamp: timestamp ?? 0, source: source ?? "", quotes: quotes ?? nil, error: nil)
                        }
                    }
                } else {
                    self.currencyValueModel = CurrencyValueModel(success: success ?? false, terms: terms ?? "", privacy: privacy ?? "", timestamp: timestamp ?? 0, source: source ?? "", quotes: quotes ?? nil, error: nil)
                }
            } else {
                if CheckInternet.Connection() == false {
                    Alert.showErrorAlert(message: "Você está sem internet")
                    self.currencyValueModel = nil
                    return
                }
                self.getCurrencyLive { (retrieve) in
                    
                }
            }
        }
    }
    
    /// Retrieves the current quote on the API
    func getCurrencyLive(completion: @escaping (Bool) -> Void) {
        self.apiService.getCurrencyLive { (result) in
            switch result {
                case .success(let list):
                    let currencyValueModel = (list as! CurrencyValueModel)
                    if currencyValueModel.success! == true {
                        CurrencyCoreData.saveLive(currencyValueModel: currencyValueModel)
                        self.currencyValueModel = currencyValueModel
                    } else {
                        self.apiService.showError(errorCode: currencyValueModel.error?.code ?? 0)
                        completion(false)
                    }
                    break
                case .failure(let error):
                    completion(false)
                    print(error.localizedDescription)
                    Alert.showErrorAlert(message: "Não foi possível recuperar a cotação atual")
                    break
            }
        }
    }
    
    /// Retrieves the selected source and target currency
    func getCurrencySelected() {
        CurrencyCoreData.retriveCurrencySource { (currencySource) in
            if currencySource != nil {
                let currencyCode = currencySource!.value(forKey: "currencyCode") as? String
                let currencyFlag = currencySource!.value(forKey: "currencyFlag") as? String
                let currencyName = currencySource!.value(forKey: "currencyName") as? String
                let currencyValue = currencySource!.value(forKey: "currencyValue") as? String
                
                self.currencyModelSource = CurrencyModel(currencyValue: currencyValue ?? "", currencyName: currencyName ?? "", currencyCode: currencyCode ?? "", currencyFlag: currencyFlag ?? "")
                
                CurrencyCoreData.retriveCurrencyDestiny { (currencyDestiny) in
                    if currencyDestiny != nil {
                        let currencyDestinyCode = currencyDestiny!.value(forKey: "currencyCode") as? String
                        let currencyDestinyFlag = currencyDestiny!.value(forKey: "currencyFlag") as? String
                        let currencyDestinyName = currencyDestiny!.value(forKey: "currencyName") as? String
                        let currencyDestinyValue = currencyDestiny!.value(forKey: "currencyValue") as? String
                        
                        self.currencyModelDestiny = CurrencyModel(currencyValue: currencyDestinyValue ?? "", currencyName: currencyDestinyName ?? "", currencyCode: currencyDestinyCode ?? "", currencyFlag: currencyDestinyFlag ?? "")
                    }
                }
            } else {
                self.currencyModelSource = CurrencyModel(currencyValue: "0", currencyName: "Brazilian Real", currencyCode: "BRL", currencyFlag: "🇧🇷")
                CurrencyCoreData.saveCurrencySource(currencyModel: self.currencyModelSource!)
                self.currencyModelDestiny = CurrencyModel(currencyValue: "0", currencyName: "United States Dollar", currencyCode: "USD", currencyFlag: "🇺🇸")
                CurrencyCoreData.saveCurrencyDestiny(currencyModel: self.currencyModelDestiny!)
            }
        }
    }
    
    /// Calculate the value of the converted currency
    ///
    /// - Parameter value: keyboard text input
    func calculateCurrencyValue(value: Double, completion: @escaping () -> ()) {
        if currencyValueModel != nil && currencyValueModel?.quotes != nil {
            var currencySourceValue: Double = 0
            var currencyDestinyValue: Double = 0
            for currency in currencyValueModel!.quotes! {
                if currency.key == currencyValueModel!.source!  + currencyModelSource!.currencyCode {
                    currencySourceValue = currency.value
                }
                
                if currency.key == currencyValueModel!.source! + currencyModelDestiny!.currencyCode {
                    currencyDestinyValue = currency.value
                }
            }
            
            let valueCalculeted = (currencyDestinyValue/currencySourceValue) * value
            let valueCalculetedText = Money.currencyFormatter(value: valueCalculeted)
            currencyModelDestiny?.currencyValue = valueCalculetedText
            completion()
        }
        
    }
    
    
    
}
