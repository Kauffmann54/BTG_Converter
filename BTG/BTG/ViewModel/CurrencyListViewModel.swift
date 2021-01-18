//
//  CurrencyListViewModel.swift
//  BTG
//
//  Created by Guilherme Kauffmann on 16/01/21.
//

import Foundation
import CoreData
import UIKit

final class Observer<T> {
    typealias Listener = (T) -> Void
  
    var listener: Listener?
    var value: T {
        didSet {
            listener?(value)
        }
    }

    init(_ value: T) {
        self.value = value
    }

    func bind(listener: Listener?) {
        self.listener = listener
        listener?(value)
    }
}

class CurrencyListViewModel: NSObject {
    // MARK: - Properties
    private var apiService : APIService!
    public var listCurrency = [CurrencyModel]()
    public var listFavoriteCurrency = [CurrencyModel]()
    public var listCurrencyAux = [CurrencyModel]()
    public var listFavoriteCurrencyAux = [CurrencyModel]()
    private(set) var currencyList: [NSManagedObject]? {
        didSet {
            self.bindCurrencyListViewModelToController.value = true
        }
    }
    
    lazy var bindCurrencyListViewModelToController = Observer(false)
    
    /// Initializes API, retrieves the list of currencies locally
    override init() {
        super.init()
        self.apiService = APIService()
        getCurrencyCoreData(newList: false)
    }
    
    /// Retrieves the list of currencies locally and if the list is empty, request to the API
    ///
    /// - Parameter newList: Retrieve a new API list
    func getCurrencyCoreData(newList: Bool) {
        self.listCurrency.removeAll()
        self.listFavoriteCurrency.removeAll()
        CurrencyCoreData.retrive { (list) in
            for currency in list {
                let currencyValue = currency.value(forKey: "currencyValue") as? String
                let currencyName = currency.value(forKey: "currencyName") as? String
                let currencyCode = currency.value(forKey: "currencyCode") as? String
                let currencyFlag = currency.value(forKey: "currencyFlag") as? String
                let currencyFavorite = currency.value(forKey: "currencyFavorite") as? Bool
                let currencyObject = CurrencyModel(currencyValue: currencyValue ?? "", currencyName: currencyName ?? "", currencyCode: currencyCode ?? "", currencyFlag: currencyFlag ?? "")
                
                if currencyFavorite == true {
                    self.listFavoriteCurrency.append(currencyObject)
                } else {
                    self.listCurrency.append(currencyObject)
                }
            }
            
            if list.count == 0 || newList == true {
                self.getCurrencyList()
            } else {
                self.listFavoriteCurrencyAux = self.listFavoriteCurrency
                self.listCurrencyAux = self.listCurrency
                self.currencyList = list
            }
        }
    }
    
    /// Retrieves the list of API currencies and verifies that none are already saved locally
    func getCurrencyList() {
        self.apiService.getCurrencyList { (result) in
            self.listCurrencyAux.removeAll()
            self.listFavoriteCurrencyAux.removeAll()
            
            switch result {
                case .success(let list):
                    let currencyListModel = (list as! CurrencyListModel)
                    if currencyListModel.success! == true {
                        for moeda in currencyListModel.currencies! {
                            let currency = CurrencyModel(currencyValue: "0", currencyName: moeda.value, currencyCode: moeda.key, currencyFlag: Money.flag(country: moeda.key))
                                                    
                            var findCurrency: Bool = false
                            for currencyFavorite in self.listFavoriteCurrency {
                                if currencyFavorite.currencyCode == moeda.key {
                                    CurrencyCoreData.update(currencyModel: currency, favorite: true)
                                    self.listFavoriteCurrencyAux.append(currency)
                                    findCurrency = true
                                    break
                                }
                            }
                            
                            if findCurrency == false {
                                for currencyLast in self.listCurrency {
                                    if currencyLast.currencyCode == moeda.key {
                                        CurrencyCoreData.update(currencyModel: currency, favorite: false)
                                        self.listCurrencyAux.append(currency)
                                        findCurrency = true
                                        break
                                    }
                                }
                                
                                if findCurrency == false {
                                    self.listCurrencyAux.append(currency)
                                    CurrencyCoreData.save(currencyModel: currency, favorite: false)
                                }
                            }
                        }
                    } else {
                        self.apiService.showError(errorCode: currencyListModel.error?.code ?? 0)
                    }
                    self.listFavoriteCurrency = self.listFavoriteCurrencyAux
                    self.listCurrency = self.listCurrencyAux
                    self.currencyList = nil
                    break
                case .failure(let error):
                    print(error.localizedDescription)
                    self.listCurrency = []
                    self.currencyList = nil
                    Alert.showErrorAlert(message: "Não foi possível recuperar a lista de moedas")
                    break
            }
        }
    }
    
    /// Updates the list of favorite currencies and saves locally
    ///
    /// - Parameter section: To find out if you are on the list of favorite currencies
    /// - Parameter row: Index of the selected currency
    public func updateFavorite(section: Int, row: Int, completion: @escaping () -> ()) {
        if section == 0 {
            self.listCurrency.append(self.listFavoriteCurrencyAux[row])
            self.listCurrencyAux.append(self.listFavoriteCurrencyAux[row])
            CurrencyCoreData.update(currencyModel: self.listFavoriteCurrencyAux[row], favorite: false)
            let favoriteAux = self.listFavoriteCurrencyAux[row]
            var pos = 0
            for favorite in self.listFavoriteCurrency {
                if favorite.currencyCode == favoriteAux.currencyCode {
                    self.listFavoriteCurrency.remove(at: pos)
                    break
                }
                pos += 1
            }
            self.listFavoriteCurrencyAux.remove(at: row)
            completion()
        } else {
            self.listFavoriteCurrency.append(self.listCurrencyAux[row])
            self.listFavoriteCurrencyAux.append(self.listCurrencyAux[row])
            CurrencyCoreData.update(currencyModel: self.listCurrencyAux[row], favorite: true)
            let favoriteAux = self.listCurrencyAux[row]
            var pos = 0
            for favorite in self.listCurrency {
                if favorite.currencyCode == favoriteAux.currencyCode {
                    self.listCurrency.remove(at: pos)
                    break
                }
                pos += 1
            }
            self.listCurrencyAux.remove(at: row)
            completion()
        }
    }
    
    /// Organizes the list according to the user's selection
    ///
    /// - Parameter type: List organization type (1 - Currency Name: A - Z, 2 - Currency Name: Z- A, 3 - Currency Code: A - Z, 4 - Currency Code: Z - A)
    public func organizeList(type: Int, completion: @escaping () -> ()) {
        switch type {
        case 1:
            self.listCurrency = (self.listCurrency.sorted(by: {($1.currencyName) > ($0.currencyName)}))
            self.listFavoriteCurrency = (self.listFavoriteCurrency.sorted(by: {($1.currencyName) > ($0.currencyName)}))
            break
        case 2:
            self.listCurrency = (self.listCurrency.sorted(by: {($0.currencyName) > ($1.currencyName)}))
            self.listFavoriteCurrency = (self.listFavoriteCurrency.sorted(by: {($0.currencyName) > ($1.currencyName)}))
            break
        case 3:
            self.listCurrency = (self.listCurrency.sorted(by: {($1.currencyCode) > ($0.currencyCode)}))
            self.listFavoriteCurrency = (self.listFavoriteCurrency.sorted(by: {($1.currencyCode) > ($0.currencyCode)}))
            break
        case 4:
            self.listCurrency = (self.listCurrency.sorted(by: {($0.currencyCode) > ($1.currencyCode)}))
            self.listFavoriteCurrency = (self.listFavoriteCurrency.sorted(by: {($0.currencyCode) > ($1.currencyCode)}))
            break
        default:
            break
        }
        self.listCurrencyAux = self.listCurrency
        self.listFavoriteCurrencyAux = self.listFavoriteCurrency
        
        completion()
    }
}

// MARK: - UITableViewDelegate
extension CurrencyListViewController: UITableViewDelegate {
    
    /// Checks whether the chosen currency is not repeated
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var currencySelected: CurrencyModel!
        StyleButton.vibrar()
        if indexPath.section == 0 {
            currencySelected = currencyListViewModel?.listFavoriteCurrencyAux[indexPath.row]
        } else {
            currencySelected = currencyListViewModel?.listCurrencyAux[indexPath.row]
        }
        
        if currencyIsSource == true {
            CurrencyCoreData.retriveCurrencyDestiny { (currency) in
                if currency != nil {
                    let currencyCode = currency!.value(forKey: "currencyCode") as? String
                    if currencyCode == currencySelected.currencyCode {
                        Alert.showErrorAlert(message: "A moeda de origem precisa ser diferente da moeda de destino")
                    } else {
                        var currencyValue = "0"
                        CurrencyCoreData.retriveCurrencySource { (currencySource) in
                            if currencySource != nil {
                                currencyValue = currencySource!.value(forKey: "currencyValue") as! String
                            }
                        }
                        
                        currencySelected.currencyValue = currencyValue
                        CurrencyCoreData.saveCurrencySource(currencyModel: currencySelected)
                        self.navigationController?.popViewController(animated: true)
                    }
                } else {
                    CurrencyCoreData.saveCurrencySource(currencyModel: currencySelected)
                    self.navigationController?.popViewController(animated: true)
                }
            }
        } else {
            CurrencyCoreData.retriveCurrencySource { (currency) in
                if currency != nil {
                    let currencyCode = currency!.value(forKey: "currencyCode") as? String
                    if currencyCode == currencySelected.currencyCode {
                        Alert.showErrorAlert(message: "A moeda de destino precisa ser diferente da moeda de origem")
                    } else {
                        CurrencyCoreData.saveCurrencyDestiny(currencyModel: currencySelected)
                        self.navigationController?.popViewController(animated: true)
                    }
                } else {
                    CurrencyCoreData.saveCurrencyDestiny(currencyModel: currencySelected)
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
}

// MARK: - UISearchBarDelegate
extension CurrencyListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let texto = searchText.lowercased().removeAccent()
        
        self.currencyListViewModel?.listCurrencyAux.removeAll()
        self.currencyListViewModel?.listCurrencyAux = self.currencyListViewModel!.listCurrency.filter { (currency: CurrencyModel) -> Bool in
            return currency.currencyCode.removeAccent().lowercased().contains(texto) || currency.currencyName.removeAccent().lowercased().contains(texto)
        }
        
        self.currencyListViewModel?.listFavoriteCurrencyAux.removeAll()
        self.currencyListViewModel?.listFavoriteCurrencyAux = self.currencyListViewModel!.listFavoriteCurrency.filter { (currency: CurrencyModel) -> Bool in
            return currency.currencyCode.removeAccent().lowercased().contains(texto) || currency.currencyName.removeAccent().lowercased().contains(texto)
        }
        
        if searchText.isEmpty {
            self.currencyListViewModel?.listCurrencyAux = self.currencyListViewModel!.listCurrency
            self.currencyListViewModel?.listFavoriteCurrencyAux = self.currencyListViewModel!.listFavoriteCurrency
        }
        
        self.currencyTableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
}

// MARK: - UITableViewDataSource
extension CurrencyListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return (currencyListViewModel?.listFavoriteCurrencyAux.count)!
        } else {
            return (currencyListViewModel?.listCurrencyAux.count)!
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = currencyTableView.dequeueReusableCell(withIdentifier: FavoriteCurrencyTableViewCell.cellIdentifier, for: indexPath) as! FavoriteCurrencyTableViewCell
        if indexPath.section == 0 {
            cell.configure(with: (currencyListViewModel?.listFavoriteCurrencyAux[indexPath.row])!, favorite: true)
        } else {
            cell.configure(with: (currencyListViewModel?.listCurrencyAux[indexPath.row])!, favorite: false)
        }
        
        cell.actionBlock = {
            StyleButton.vibrar()
            self.currencyListViewModel?.updateFavorite(section: indexPath.section, row: indexPath.row, completion: {
                self.currencyTableView.reloadData()
            })
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Favoritos"
        } else {
            return "Todas moedas"
        }
    }
}
