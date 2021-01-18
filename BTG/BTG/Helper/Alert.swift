//
//  Alert.swift
//  BTG
//
//  Created by Guilherme Kauffmann on 17/01/21.
//

import Foundation
import SwiftMessages

class Alert {
    
    /// This function shows an error alert, with a personalized message
    ///
    /// - Parameter message: Message to be shown in the alert
    class func showErrorAlert(message: String) {
        let view = MessageView.viewFromNib(layout: .cardView)
        view.configureDropShadow()
        
        var config = SwiftMessages.defaultConfig
        config.presentationStyle = .center
        config.dimMode = .gray(interactive: true)

        config.duration = .seconds(seconds: 3)
        
        view.configureTheme(.error, iconStyle: .light)
        
        view.configureContent(title: "Ocorreu um erro!", body: message)
        view.button?.isHidden = true
        SwiftMessages.show(config: config, view: view)
    }
}
