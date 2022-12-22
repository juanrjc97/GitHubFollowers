//
//  FavoritesListVC.swift
//  GitHubFollowers
//
//  Created by Juan Jimenez on 12/12/22.
//

import UIKit

class FavoritesListVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    

    let tableView = UITableView()
    var favorites: [Follower] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configVC()
        configTableView()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getFavorites()
    }

    func configVC()  {
        view.backgroundColor = .systemBackground
        title = "Favorites"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    //aqui configuramos para que la celda tome los datos del array de favoritos
    func getFavorites()  {
        PersistenceManager.retrieveFavorites {[weak self] result in
            guard let self = self else {return}
            
            switch result {
            case .success(let favorites):
                
                if favorites.isEmpty {
                    self.showEmptyStateView(with: "No Favorites\nAdd one on the follower screen", in: self.view)
                }else{
                    self.favorites =  favorites //asignamos los datos guardados  al array de favorties
                    //cargamos los datos a la UI del table view
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        self.view.bringSubviewToFront(self.tableView) // por si acaso se cargo la del empty state ,traera la vista del tableview al frente
                    }
                }

            case .failure(let error):
                self.presentGFAlertOnMainThread(title: "SOMETHING WENT WRONG", message: error.rawValue, buttonTitle: "OK")
            }
        }
    }
    
    //para configurar el table view
    // se necesita setear los delegados para el table view y el data source
    func configTableView(){
        view.addSubview(tableView)
        tableView.frame = view.bounds
        tableView.rowHeight = 80
        tableView.delegate = self
        tableView.dataSource = self
        //registrando la celda  en el table view
        tableView.register(FavoriteCell.self, forCellReuseIdentifier: FavoriteCell.reuseID)
        
        
    }
    
    // MARK: - TableView DELEGATE FUNCTIONS
    
    //AQUI CREAMOS LAS CELDAS EN ESTOS 2 METODOS
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favorites.count //number of rows in section / how many favorties have the table
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FavoriteCell.reuseID) as! FavoriteCell
        let favorite = favorites[indexPath.row]
        cell.set(favorite: favorite)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let favorite = favorites[ indexPath.row]
        let followerVC =  FollowerListVC()
        followerVC.username = favorite.login
        followerVC.title = favorite.login
        
        //aqui se manda el push del nuevo navigationViewcontroller porque el followerListVC tiene su propio navigationViewcontroller
        navigationController?.pushViewController(followerVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        guard editingStyle ==  .delete else {
            return
        }
        let favorite = favorites[ indexPath.row]
        favorites.remove(at: indexPath.row) // lo borro del arreglo
        tableView.deleteRows(at: [indexPath], with: .left) //lo borro del tableView
        
        //weak self porque vamos a presentar una alerta desde aqui que mostrara en pantalla algo por lo que
        //tenemos que manejar el espacio y las referencias en memoria
        PersistenceManager.updateFavorites(favorite: favorite, actionType: .remove) { [weak self] error in
            guard let self = self else {return}
            
            if error != nil {
                self.presentGFAlertOnMainThread(title: "UNABLE TO REMOVE", message: error?.rawValue ?? "Can't delete the favorite ", buttonTitle: "OK")
            }
            
        }
        
    }
    
   
  

}
