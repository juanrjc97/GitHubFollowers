//
//  NetworkManager.swift
//  GitHubFollowers
//
//  Created by Juan Jimenez on 12/14/22.
//

import UIKit

class NetworkManager {
    
    
    //Cache para las imagenes
    let cache = NSCache<NSString, UIImage>()
    
    //ESTO ES LO QUE LO HACE UN SINGLETON A ESTA CLASE
    static let shared = NetworkManager()
    //ESTO ES LO QUE LO HACE UN SINGLETON
    private init(){}
     
    
    private let baseURL = "https://api.github.com/users/"
    
    //ASI SE HACE UN NETWORK CALL CON CODIGO BASE
    //                                                                       LO QUE RETORNA / EL ERROR EN STRING
    func getFollowers(for username: String, page: Int, completed: @escaping ([Follower]?, String?)-> Void ) {
        
        //PASO 1
        let endpoint = baseURL + "\(username)/followers?per_page=100&page=\(page)"
        //PASO 2
        guard let url = URL(string: endpoint) else {
            // PRIMER ARGUMENTO = ARREGLO NULO DE FOLLOWERS
            //SEGUNDO ARGUMENTO = MENSAJE QUE SE LE PASA AL VIEW/CONTROLADOR QUE HIZO ESTA LLAMADA AL API
            completed(nil, "THIS USER CREATED AN INVALID REQUEDST .")
            return
        }
        //PASO 3 esto es COMO LA LLAMADA HTTP EN ANGULAR
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            
            //3.1 CHEQUEO EL ERROR
            if let _ = error {
                completed(nil, "UNABLE TO COMPLETE YOUR REQUEST.")
                return
            }
            
            //3.2 CHEQUEO LA RESPUESTA DEL SERVER
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                completed(nil, "INVALID RESPONSE FROM THE SERVER , PLEASE TRY AGAIN")
                return
            }
            
            //3.3 CHEQUEO SI RECIBI DATA DESDE EL API
            guard let data = data else {
                completed(nil, "INVALID DATA")
                return
            }
            
            //3.4 TRABAJO CON LA DATA RECIBIDA
            do{
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let followers = try decoder.decode([Follower].self, from: data)
                completed(followers,nil)
                
            }catch{
                completed(nil, "INVALID DATA")
            }
            
        }
        
        task.resume()
    }
    
    
    
}
