//
//  FollowerListVCViewController.swift
//  GitHubFollowers
//
//  Created by Juan Jimenez on 12/13/22.
//

import UIKit



class FollowerListVC: UIViewController {

    enum Section {
    case main
    }
    
    var username: String!
    var followers: [Follower] = []
    var filteredFollowers: [Follower] = []
    //varible para que hacer tracking del scroll
    var lastScrollPosition: CGFloat = 0
    
    // VARIABLE PARA LA PAGINACION
    var page = 1
    var hasMoreFollowers = true
    var isSearching = false
    var isLoadingMoreFollowers = false
    var collectionView: UICollectionView!
    var dataSource : UICollectionViewDiffableDataSource<Section, Follower>!
    
    
    override func viewDidLoad() {
      
        super.viewDidLoad()
        configureVC()
        configureCollectionView()
        getFollowers(username: username, page: page)
        configureDataSource()
        configSearchController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = false
    }
    
    func configureVC() {
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.prefersLargeTitles = true
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))
        navigationItem.rightBarButtonItem = addButton
    }
    
    
    func configureCollectionView() {
        //PRIMERO INICIALIZAMOS EL COLLECTION VIEW
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: UIHelper.createThreeColumnFlowLayout(in: view))
        //AGREGAR EL COLLECTION VIEW DENTRO DEL VIEW PRINCIPAL
        view.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.backgroundColor = .systemBackground
        collectionView.register(FollowerCell.self, forCellWithReuseIdentifier: FollowerCell.reuseID)
    }
    
    func getFollowers(username: String, page: Int) {
        showLoadingView()// mostramos el view de carga mientras llamamos la nueva data
        isLoadingMoreFollowers = true
        NetworkManager.shared.getFollowers(for: username, page: page) {[weak self] followers, errorMessage in
           
            //para evitar poner self? usar
            guard let self = self else{return }
            self.dismissLoadingView()
            
            guard let followers = followers else{
                self.presentGFAlertOnMainThread(title: "ERROR", message: errorMessage!, buttonTitle: "OK")
                return
            }
            
            if followers.count < 100 { self.hasMoreFollowers = false}
            
            self.followers.append(contentsOf: followers)
            if self.followers.isEmpty {
                let message = "THIS USER DOES NOT HAVE ANY FOLLOWERS"
                DispatchQueue.main.async {
                    self.showEmptyStateView(with: message, in: self.view)
                }
            }
            self.updateData(on: self.followers)
        }
        isLoadingMoreFollowers = false
        
    }
    
    //SEARCH CONTROLLER
    func configSearchController()  {
        // inicializar el searchController
        let searchController = UISearchController()
        //decretar el delegado del search controller
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "Seach for a username"
        navigationItem.searchController = searchController
        
    }
    
    //aqui se confifgura la la celda para que se reoganice cuando se filtra en la vista
    func configureDataSource()  {
        
        dataSource = UICollectionViewDiffableDataSource<Section,Follower>(collectionView: collectionView, cellProvider: { collectionView, indexPath, follower in
            //PASO 1 CREAR UNA CELDA REUSABLE
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FollowerCell.reuseID, for: indexPath) as! FollowerCell
            cell.set(follower: follower)
            
            //RETORNAR LA CELDA
            return cell
            
        })
    }
    
    //AQUI SE CONFIGURA/ASIGNA LA DATA A LAS CELDAS PARA QUE LA MUESTREN EN EL DATASOURCE Y LA VIEW
    func updateData(on followers:[Follower])  {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Follower>()
        snapshot.appendSections([.main])
        snapshot.appendItems(followers)
        DispatchQueue.main.async {
            self.dataSource.apply(snapshot, animatingDifferences: true )
        }
    }
    
    @objc func addButtonTapped()  {
        showLoadingView()
//        NetworkManager.shared.getUserInfo(for: username) { [weak self] result in
//
//            guard let self = self else {return}
//            self.dismissLoadingView()
//            switch result {
//
//            case .success(let user):
//
//                let favorite = Follower(login: user.login, avatarUrl: user.avatarUrl)
//                PersistenceManager.updateFavorites(favorite: favorite, actionType: .add) {[weak self] error in
//
//                    guard let self = self else {return}
//                    guard let error = error else {
//                        self.presentGFAlertOnMainThread(title: "Success!", message: "You have successfully added this user", buttonTitle: "OK")
//                        return
//                    }
//                    self.presentGFAlertOnMainThread(title: "Something Went Wrong", message: error.rawValue, buttonTitle: "OK")
//
//                }
//
//            case .failure(let error):
//                self.presentGFAlertOnMainThread(title: "Something Went Wrong", message: error.rawValue, buttonTitle: "OK")
//            }
//        }
        
        Task{
            do{
                let user = try await NetworkManager.shared.getUserInfo(for: username)
                let favorite = Follower(login: user.login, avatarUrl: user.avatarUrl)
                dismissLoadingView()
                PersistenceManager.updateFavorites(favorite: favorite, actionType: .add) {[weak self] error in
                    
                    guard let self = self else {return}
                    guard let error = error else {
                        self.presentGFAlertOnMainThread(title: "Success!", message: "You have successfully added this user", buttonTitle: "OK")
                        return
                    }
                    self.presentGFAlertOnMainThread(title: "Something Went Wrong", message: error.rawValue, buttonTitle: "OK")
                    
                }
                
            }catch{
                if let gfError = error as? GFError {
                    presentGFAlertOnMainThread(title: "Something went wrong", message: gfError.rawValue, buttonTitle: "OK")
                }else {
                    self.presentGFAlertOnMainThread(title: "Something went wrong", message: "NETWORK ERROR, SORRY WE DON'T KNOW WHAT HAPPEND", buttonTitle: "OK")
                }
                dismissLoadingView()
            }
        }
    }
    
}

extension FollowerListVC: UICollectionViewDelegate {
    
    //PARA DETERMINAR SI LLEGO AL FINAL DEL SCROLL
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
     
        
        let offsetY         = scrollView.contentOffset.y // obtenemos el offset que es cuan abajo hiciste scroll
        let contentHeight   = scrollView.contentSize.height // la altura del contenido en pantalla
        let height          = scrollView.frame.size.height // la altura de la pantalla

        if offsetY > contentHeight - height {
            
            guard hasMoreFollowers && !isLoadingMoreFollowers else { return }
            page += 1
            getFollowers(username: username, page: page)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let activeArray     = isSearching ? filteredFollowers : followers
        let follower        = activeArray[indexPath.item]

        let userInfVC          = UserInfoVC()
        userInfVC.username     = follower.login
        userInfVC.delegate     = self
        //se crea el navController para que podamos usar el nav en la pantalla emergente 
        let navController   = UINavigationController(rootViewController: userInfVC)
        present(navController, animated: true)
    }
    
    //ESTOS DOS SON PARA QUE EL DETECTAR CUANDO EL USER HACE SCROLL HACIA ARRIBA Y LE APAREZCA EL SEARCH BAR
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        lastScrollPosition = scrollView.contentOffset.y
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if lastScrollPosition < scrollView.contentOffset.y {
            navigationItem.hidesSearchBarWhenScrolling = true
        }else if lastScrollPosition > scrollView.contentOffset.y  {
            navigationItem.hidesSearchBarWhenScrolling = false
        }
    }
}


extension FollowerListVC : UISearchResultsUpdating {
    
    //FUNCION DE BUSQUEDA
    func updateSearchResults(for searchController: UISearchController) {
        //aqui se crea el filtro
        guard let filter = searchController.searchBar.text, !filter.isEmpty else {
            //si el filtro esta vacio
            filteredFollowers.removeAll()
            isSearching = false
            updateData(on: followers)
            return
        }
        
        //aqui se filtra
        isSearching = true
        filteredFollowers = followers.filter { $0.login.lowercased().contains(filter.lowercased())}
        updateData(on: filteredFollowers)
    }
    
}

extension FollowerListVC: UserInfoVCDelegate {
    
    func didRequestFollowers(for Username: String) {
        
        //get followers for the new user and Reseting the page with the new user data
        self.username = Username
        title = Username
        page = 1
        followers.removeAll()
        filteredFollowers.removeAll()
        //para que el collection view se vaya al inicio cuando se carge nuevamente de datos
        collectionView.scrollsToTop = true
        getFollowers(username: Username, page: page)
    }
    
    
}
