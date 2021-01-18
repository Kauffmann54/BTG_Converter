//
//  BTGTests.swift
//  BTGTests
//
//  Created by Guilherme Kauffmann on 15/01/21.
//

import XCTest
@testable import BTG

class BTGTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            
        }
    }
    
    /// Test initializing an instance of ConverterViewModel and checking if are retrieving the current quote or save locally
    func testConverterViewModel() {
        let converterViewModel = ConverterViewModel()
        let converterExpectation = expectation(description: "Cotação atual das moedas")
        converterViewModel.bindCurrencyViewModelToController = {
            if converterViewModel.currencyValueModel == nil {
                XCTFail("Falha na recuperação da cotação das moedas")
            } else {
                converterExpectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 10) { (error) in
            XCTAssertNotNil(converterViewModel.currencyValueModel)
        }
    }
   
    /// Test initializing an instance of CurrencyListViewModel and checking if are retrieving list of available currencies or save locally
    func testCurrencyListViewModel() {
        let currencyListViewModel = CurrencyListViewModel()
        let converterExpectation = expectation(description: "Lista de moedas disponíveis")
        currencyListViewModel.bindCurrencyListViewModelToController.bind { (_) in
            if currencyListViewModel.listCurrency.count == 0 {
                XCTFail("Falha na recuperação da lista de moedas")
            } else {
                converterExpectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 10) { (error) in
            XCTAssertNotNil(currencyListViewModel.listCurrency)
        }
    }
    
    /// Check if you are calculating the expected currency conversion value for the current quote
    func testCalculateCurrencyValue() {
        let converterViewModel = ConverterViewModel()
        let converterExpectation = expectation(description: "Calcular cotação atual")
        let valueCalculate: Double = 35.5
        
        converterViewModel.bindCurrencyViewModelToController = {
            if converterViewModel.currencyValueModel == nil {
                XCTFail("Falha na recuperação da cotação das moedas")
            } else {
                let currencySource = converterViewModel.currencyModelSource!
                let currencyDestiny = converterViewModel.currencyModelDestiny!
                
                var currencySourceValue: Double = 0
                var currencyDestinyValue: Double = 0
                for currency in converterViewModel.currencyValueModel!.quotes! {
                    if currency.key == converterViewModel.currencyValueModel!.source!  + currencySource.currencyCode {
                        currencySourceValue = currency.value
                    }
                    
                    if currency.key == converterViewModel.currencyValueModel!.source! + currencyDestiny.currencyCode {
                        currencyDestinyValue = currency.value
                    }
                }
                
                let valueCalculeted = (currencyDestinyValue/currencySourceValue) * valueCalculate
                let valueCalculetedText = Money.currencyFormatter(value: valueCalculeted)
                
                converterViewModel.calculateCurrencyValue(value: valueCalculate) {
                    XCTAssertEqual(converterViewModel.currencyModelDestiny!.currencyValue, valueCalculetedText, "Os valores calculados deram diferentes")
                    converterExpectation.fulfill()
                }
            }
        }
        
        waitForExpectations(timeout: 10) { (error) in
            XCTAssertNotNil(converterViewModel.currencyModelDestiny!.currencyValue)
        }
    }
    
    /// Tests to retrieve the current currency quote using the API
    func testRetrieveCurrencyLive() {
        let apiService = APIService()
        let currencyExpectation = expectation(description: "Recuperar a cotação atual das moedas")
        var currencyValue: CurrencyValueModel!
        apiService.getCurrencyLive { (result) in
            switch result {
                case .success(let list):
                    let currencyValueModel = (list as! CurrencyValueModel)
                    if currencyValueModel.success! == true {
                        currencyValue = currencyValueModel
                        currencyExpectation.fulfill()
                    } else {
                        XCTFail(currencyValueModel.error!.info!)
                    }
                    break
                case .failure(let error):
                    XCTFail("Não foi possível recuperar a cotação atual " + error.localizedDescription)
                    break
            }
        }
                
        waitForExpectations(timeout: 10) { (error) in
            XCTAssertNotNil(currencyValue)
        }
    }
    
    /// Tests to retrieve the list of currencies available through the API
    func testRetrieveCurrencyList() {
        let apiService = APIService()
        let currencyExpectation = expectation(description: "Recuperar a lista de moedas disponíveis")
        var currencyList: CurrencyListModel!
        apiService.getCurrencyList { (result) in
            switch result {
                case .success(let list):
                    let currencyListModel = (list as! CurrencyListModel)
                    if currencyListModel.success! == true {
                        currencyList = currencyListModel
                        currencyExpectation.fulfill()
                    } else {
                        XCTFail(currencyListModel.error!.info!)
                    }
                    break
                case .failure(let error):
                    XCTFail("Não foi possível recuperar a lista de moedas " + error.localizedDescription)
                    break
            }
        }
                
        waitForExpectations(timeout: 10) { (error) in
            XCTAssertNotNil(currencyList)
        }
    }

}
