//
//  FavoriteCurrencyTableViewCell.swift
//  BTG
//
//  Created by Guilherme Kauffmann on 16/01/21.
//

import UIKit

class FavoriteCurrencyTableViewCell: UITableViewCell {
    
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var currencyCodeLabel: UILabel!
    @IBOutlet weak var currencyNameLabel: UILabel!
    @IBOutlet weak var currencyFlagLabel: UILabel!
    
    static let cellIdentifier = "cell"
    
    var actionBlock: (() -> Void)? = nil

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBAction func didTapFavorite(_ sender: Any) {
        actionBlock?()
    }
    
    public func configure(with currencyModel: CurrencyModel, favorite: Bool) {
        currencyCodeLabel.text = currencyModel.currencyCode
        currencyNameLabel.text = currencyModel.currencyName
        currencyFlagLabel.text = currencyModel.currencyFlag
        if favorite == true {
            favoriteButton.setBackgroundImage(UIImage(named: "star.fill"), for: .normal)
        } else {
            favoriteButton.setBackgroundImage(UIImage(named: "star"), for: .normal)
        }
    }
    
    
}
