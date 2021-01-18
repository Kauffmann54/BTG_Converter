//
//  APIService.swift
//  BTG
//
//  Created by Guilherme Kauffmann on 17/01/21.
//

import Alamofire

enum Result {
  case success(Any)
  case failure(Error)
}

class APIService: NSObject {
    let access_key = "ab071fd87234012a8ccc9f190b06b146"
    let apiURL = "http://api.currencylayer.com"
    let live = "live"
    let list = "list"
    
    /// Creates the base API URL
     private lazy var baseURL: URL = {
       guard let url = URL(string: apiURL) else {
         fatalError("Invalid URL")
       }
       return url
     }()
    
    /// Retrieves the current quote
    ///
    /// - Returns: `Result` Returns the result of the request
    func getCurrencyLive(completion: @escaping (Result) -> Void) {
        let url = baseURL.appendingPathComponent(live)
        
        let params: [String: Any] = [
            "access_key": access_key
        ]
        
        AF.request(url, method: .get, parameters: params)
            .validate(statusCode: 200..<300)
            .responseJSON { (response) in
                switch response.result {
                case .success:
                    do {
                        let jsonDecode = try JSONDecoder().decode(CurrencyValueModel.self, from: response.data!)
                        completion(Result.success(jsonDecode))
                    } catch let error {
                        completion(Result.failure(error))
                    }
                    break
                case .failure(let error):
                    completion(Result.failure(error))
                }
            }
    }
    
    /// Retrieves the currency code list
    ///
    /// - Returns: `Result` Returns the result of the request
    func getCurrencyList(completion: @escaping (Result) -> Void) {
        let url = baseURL.appendingPathComponent(list)
        
        let params: [String: Any] = [
            "access_key": access_key
        ]
        
        AF.request(url, method: .get, parameters: params)
            .validate(statusCode: 200..<300)
            .responseJSON { (response) in
                switch response.result {
                case .success:
                    do {
                        let jsonDecode = try JSONDecoder().decode(CurrencyListModel.self, from: response.data!)
                        completion(Result.success(jsonDecode))
                    } catch let error {
                        completion(Result.failure(error))
                    }
                    break
                case .failure(let error):
                    completion(Result.failure(error))
                }
            }
    }
    
    /// Shows an error message according to the error code
    ///
    /// - Returns: `errorCode`Error code
    func showError(errorCode: Int) {
        switch errorCode {
        case 101:
            Alert.showErrorAlert(message: "O usuário não forneceu uma chave de acesso ou forneceu uma chave de acesso inválida.")
            break
        case 102:
            Alert.showErrorAlert(message: "A conta do usuário não está ativa. O usuário será solicitado a entrar em contato com o Suporte ao cliente.")
            break
        case 103:
            Alert.showErrorAlert(message: "O usuário solicitou uma função API inexistente.")
            break
        case 104:
            Alert.showErrorAlert(message: "O usuário atingiu ou excedeu o limite de solicitação mensal de API de seu plano de assinatura.")
            break
        case 105:
            Alert.showErrorAlert(message: "O plano de assinatura atual do usuário não suporta a função API solicitada.")
            break
        case 106:
            Alert.showErrorAlert(message: "A consulta do usuário não retornou nenhum resultado.")
            break
        case 201:
            Alert.showErrorAlert(message: "O usuário inseriu uma moeda de origem inválida.")
            break
        case 202:
            Alert.showErrorAlert(message: "O usuário inseriu um ou mais códigos de moeda inválidos.")
            break
        default:
            Alert.showErrorAlert(message: "Não foi possível recuperar os dados")
            break
        }
    }
}
