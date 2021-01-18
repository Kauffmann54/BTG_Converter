//
//  CurrencyListViewController.swift
//  BTG
//
//  Created by Guilherme Kauffmann on 16/01/21.
//

import UIKit

class CurrencyListViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var currencyTableView: UITableView!
    @IBOutlet weak var organizeView: UIVisualEffectView!
    @IBOutlet weak var loadindIndicator: UIActivityIndicatorView!
    private let refreshControl = UIRefreshControl()
    
    // MARK: - Properties
    var currencyListViewModel: CurrencyListViewModel?
    var currencyIsSource: Bool = false
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        currencyTableView.register(UINib.init(nibName: "FavoriteCurrencyTableViewCell", bundle: nil), forCellReuseIdentifier: FavoriteCurrencyTableViewCell.cellIdentifier)
        currencyTableView.delegate = self
        currencyTableView.dataSource = self
        currencyTableView.refreshControl = refreshControl
        searchBar.delegate = self
        
        refreshControl.addTarget(self, action: #selector(refreshCurrencyList(_:)), for: .valueChanged)
        
        currencyListViewModel = CurrencyListViewModel()
        callToViewModelForUIUpdate()
    }
    
    // MARK: - Buttons
    @IBAction func organizeButton(_ sender: Any) {
        StyleButton.vibrar()
        self.view.endEditing(true)
        organizeView.isHidden = false
    }
    
    @IBAction func closeOrganizeView(_ sender: Any) {
        StyleButton.vibrar()
        organizeView.isHidden = true
    }
       
    
    @IBAction func sortCurrencyNameAZ(_ sender: Any) {
        StyleButton.vibrar()
        self.currencyListViewModel?.organizeList(type: 1, completion: {
            self.currencyTableView.setContentOffset(.zero, animated: true)
            self.currencyTableView.reloadData()
        })
        organizeView.isHidden = true
    }
    
    @IBAction func sortCurrencyNameZA(_ sender: Any) {
        StyleButton.vibrar()
        self.currencyListViewModel?.organizeList(type: 2, completion: {
            self.currencyTableView.setContentOffset(.zero, animated: true)
            self.currencyTableView.reloadData()
        })
        organizeView.isHidden = true
    }
    
    @IBAction func sortCurrencyCodeAZ(_ sender: Any) {
        StyleButton.vibrar()
        self.currencyListViewModel?.organizeList(type: 3, completion: {
            self.currencyTableView.setContentOffset(.zero, animated: true)
            self.currencyTableView.reloadData()
        })
        organizeView.isHidden = true
    }
    
    @IBAction func sortCurrencyCodeZA(_ sender: Any) {
        StyleButton.vibrar()
        self.currencyListViewModel?.organizeList(type: 4, completion: {
            self.currencyTableView.setContentOffset(.zero, animated: true)
            self.currencyTableView.reloadData()
        })
        organizeView.isHidden = true
    }
    
    // MARK: - Funtions
    func callToViewModelForUIUpdate() {
        self.loadindIndicator.isHidden = false
        currencyListViewModel?.bindCurrencyListViewModelToController.bind(listener: { (_) in
            self.refreshControl.endRefreshing()
            self.loadindIndicator.isHidden = true
            self.currencyListViewModel?.organizeList(type: 1, completion: {
                self.currencyTableView.reloadData()
            })
        })
    }
    
    
    @objc func refreshCurrencyList(_ sender: Any) {
        self.currencyListViewModel?.getCurrencyCoreData(newList: true)
        self.currencyTableView.reloadData()
    }
    
}





