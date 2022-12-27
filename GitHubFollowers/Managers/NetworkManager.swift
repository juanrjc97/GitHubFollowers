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
    
    

//    func getUserInfo(for username: String, completed: @escaping (Result<User, GFError>) -> Void ){
//
//        let endpoint = baseURL + "\(username)"
//
//        guard let url = URL(string: endpoint) else {
//            completed(.failure(.invalidUsername))
//            return
//        }
//
//        let task = URLSession.shared.dataTask(with: url) { data, response, error in
//
//            if let _ = error {
//                completed(.failure(.unableToComplete))
//                return
//            }
//
//            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
//                completed(.failure(.invalidResponse))
//                return
//            }
//
//            guard let data = data else {
//                completed(.failure(.invalidData))
//                return
//            }
//
//            do{
//                let decoder = JSONDecoder()
//                decoder.keyDecodingStrategy = .convertFromSnakeCase
//                let user = try decoder.decode(User.self, from: data)
//                completed(.success(user))
//
//            }catch{
//                completed(.failure(.invalidData))
//            }
//
//        }
//
//        task.resume()
//    }
//
    //CON ASYNC Y AWAIT
    func getUserInfo(for username: String ) async throws -> User {
        
        let endpoint = baseURL + "\(username)"
        
        guard let url = URL(string: endpoint) else {
            throw GFError.invalidUsername
            
        }
        //si esto falla por llama al throws para mandar el error
        let (data , response) = try await URLSession.shared.data(from: url)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw GFError.invalidResponse
        }
        
        do{
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(User.self, from: data)
        }catch{
            throw GFError.invalidData
        }
        
    }
    
    //MARK: -asi seria el network call de descargar la imagen del avatar desde el networkManagar
    // el UIImage? significa que el completed puede devolver un UIImage o un nil
    func downloadImage(from urlString: String, completed: @escaping(UIImage?)-> Void)  {
    
        let cacheKey = NSString(string: urlString)
        
        //AQUI REVISAMOS SI TENEMOS LA IMAGEN EN EL CACHE ANTES DE HACER OTRA LLAMADA AL API
        if let image = cache.object(forKey: cacheKey){
            completed(image)
            return
        }
        
        guard let url = URL(string: urlString) else {
            completed(nil)
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else {
                completed(nil)
                return}
            if error != nil {
                completed(nil)
                return}
            guard let response = response as? HTTPURLResponse , response.statusCode == 200 else {
                completed(nil)
                return }
            guard let data = data else {  completed(nil)
                return }
            
                guard let image = UIImage(data: data) else {return }
            
                self.cache.setObject(image, forKey: cacheKey)
            
               completed(image)

        }
        task.resume()
    }
    
}
