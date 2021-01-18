//
//  ConverterViewController.swift
//  BTG
//
//  Created by Guilherme Kauffmann on 16/01/21.
//

import UIKit

class ConverterViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var currencyValor1Label: UILabel!
    @IBOutlet weak var currencyValor2Label: UILabel!
    @IBOutlet weak var currencyCode1Label: UILabel!
    @IBOutlet weak var currencyCode2Label: UILabel!
    @IBOutlet weak var currencyFlag1Label: UILabel!
    @IBOutlet weak var currencyFlag2Label: UILabel!
    @IBOutlet weak var dateUpdateLabel: UILabel!
    @IBOutlet weak var valueCurrencyLabel: UILabel!
    @IBOutlet weak var currencySourceButton: UIButton!
    @IBOutlet weak var currencyDestinyButton: UIButton!
    @IBOutlet weak var loadingView: UIVisualEffectView!
    
    // MARK: - Properties
    private var converterViewModel: ConverterViewModel!
    var currencyIsSource: Bool = false
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        let longSourceGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressSource))
        currencySourceButton.addGestureRecognizer(longSourceGesture)
        let longDestinyGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressDestiny))
        currencyDestinyButton.addGestureRecognizer(longDestinyGesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.converterViewModel = ConverterViewModel()
        callToViewModelForUIUpdate()
    }
     
    // MARK: - Buttons
    @IBAction func clearValue(_ sender: UIButton) {
        StyleButton.vibrar()
        converterViewModel?.updateCurrencyValueSource(value: "0", completion: {
            self.currencyValor1Label.text = self.converterViewModel?.currencyValor1Text
        })
        
        converterViewModel?.updateCurrencyValueDestiny(completion: {
            self.currencyValor2Label.text = self.converterViewModel?.currencyValor2Text
        })
    }
    
    @IBAction func changeCurrency(_ sender: Any) {
        StyleButton.vibrar()
        converterViewModel?.changeCurrency {
            self.updateUI()
        }
    }
    
    @IBAction func calculateCurrency(_ sender: Any) {
        StyleButton.vibrar()
        converterViewModel?.calculateCurrencyValue(value: Money.converterToDouble(value: currencyValor1Label.text!), completion: {
            self.currencyValor2Label.text = self.converterViewModel?.currencyValor2Text
        })
    }
    
    @IBAction func deleteValue(_ sender: Any) {
        StyleButton.vibrar()
        converterViewModel?.updateCurrencyValueSource(value: String(currencyValor1Label.text!.dropLast()), completion: {
            self.currencyValor1Label.text = self.converterViewModel?.currencyValor1Text
        })
        
        converterViewModel?.updateCurrencyValueDestiny(completion: {
            self.currencyValor2Label.text = self.converterViewModel?.currencyValor2Text
        })
    }
    
    @IBAction func numberButton(_ sender: UIButton) {
        StyleButton.vibrar()
        converterViewModel?.updateCurrencyValueSource(value: currencyValor1Label.text! + String(sender.tag), completion: {
            self.currencyValor1Label.text = self.converterViewModel?.currencyValor1Text
        })
        
        converterViewModel?.updateCurrencyValueDestiny(completion: {
            self.currencyValor2Label.text = self.converterViewModel?.currencyValor2Text
        })
    }
    
    @IBAction func chooseCurrencySource(_ sender: Any) {
        StyleButton.vibrar()
        currencyIsSource = true
        performSegue(withIdentifier: "currencyListSegue", sender: self)
    }
    
    @IBAction func chooseCurrencyDestiny(_ sender: Any) {
        StyleButton.vibrar()
        currencyIsSource = false
        performSegue(withIdentifier: "currencyListSegue", sender: self)
    }
    
    @IBAction func reloadCurrency(_ sender: Any) {
        StyleButton.vibrar()
        self.converterViewModel?.getCurrencyLive(completion: { (retrieve) in
            
        })
    }
    
    // MARK: - Funtions
    func callToViewModelForUIUpdate() {
        self.loadingView.isHidden = false
        self.converterViewModel.bindCurrencyValueViewModelToController.bind { (_) in
            self.loadingView.isHidden = true
            self.updateUI()
        }
    }
    
    func updateUI() {
        currencyValor1Label.text = converterViewModel!.currencyValor1Text
        currencyValor2Label.text = converterViewModel!.currencyValor2Text
        currencyCode1Label.text = converterViewModel!.currencyCode1Text
        currencyCode2Label.text = converterViewModel!.currencyCode2Text
        currencyFlag1Label.text = converterViewModel!.currencyFlag1Text
        currencyFlag2Label.text = converterViewModel!.currencyFlag2Text
        dateUpdateLabel.text = converterViewModel!.dateUpdateText
        valueCurrencyLabel.text = converterViewModel!.valueCurrencyText
        self.converterViewModel.calculateCurrencyValue(value: Money.converterToDouble(value: self.converterViewModel.currencyValor1Text)) {
            self.currencyValor2Label.text = self.converterViewModel!.currencyValor2Text
        }
    }
    
    @objc func longPressSource() {
        showActionSheetAlert(text: converterViewModel.currencyValor1Text)
    }
    
    @objc func longPressDestiny() {
        showActionSheetAlert(text: converterViewModel.currencyValor2Text)
    }
    
    func showActionSheetAlert(text: String) {
          let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

          let defaultAction = UIAlertAction(title: "Copiar", style: .default, handler: { (alert: UIAlertAction!) -> Void in
            UIPasteboard.general.string = text
          })

        let deleteAction = UIAlertAction(title: "Compartilhar", style: .default, handler: { [self] (alert: UIAlertAction!) -> Void in
            let textToShare = [ "\(converterViewModel.currencyValor1Text) \(converterViewModel.currencyCode1Text) \(converterViewModel.currencyFlag1Text) = \(converterViewModel.currencyValor2Text) \(converterViewModel.currencyCode2Text) \(converterViewModel.currencyFlag2Text)" ]
            let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view

            self.present(activityViewController, animated: true, completion: nil)
          })

          let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: { (alert: UIAlertAction!) -> Void in
            
          })

          alertController.addAction(defaultAction)
          alertController.addAction(deleteAction)
          alertController.addAction(cancelAction)

          self.present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "currencyListSegue" {
            let currencyListViewController = segue.destination as! CurrencyListViewController
            currencyListViewController.currencyIsSource = currencyIsSource
        }
    }
    

}
