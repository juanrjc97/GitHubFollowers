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

    
    // VARIABLE PARA LA PAGINACION
    var page = 1
    var hasMoreFollowers = true
    var isSearching = false
    
    var collectionView: UICollectionView!
    var dataSource : UICollectionViewDiffableDataSource<Section, Follower>!
    
    
    override func viewDidLoad() {
      
        super.viewDidLoad()
        configureVC()
        configureCollectionView()
        getFollowers(username: username, page: page)
        configureDataSource()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = false
    }
    
    func configureVC() {
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.prefersLargeTitles = true
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
        NetworkManager.shared.getFollowers(for: username, page: page) {[weak self] followers, errorMessage in
           
            //para evitar poner self? usar
            guard let self = self else{return }
            self.dismissLoadingView()
            
            guard let followers = followers else{
                self.presentGFAlertOnMainThread(title: "ERROR", message: errorMessage!, buttonTitle: "OK")
                return
            }
            if followers.count < 100 { self.hasMoreFollowers = false}
            print(followers.count)
            self.followers.append(contentsOf: followers)
            if self.followers.isEmpty {
                let message = "THIS USER DOES NOT HAVE ANY FOLLOWERS"
                DispatchQueue.main.async {
                    self.showEmptyStateView(with: message, in: self.view)
                }
            }
            self.updateData()
        }
        
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
    func updateData()  {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Follower>()
        snapshot.appendSections([.main])
        snapshot.appendItems(followers)
        DispatchQueue.main.async {
            self.dataSource.apply(snapshot, animatingDifferences: true )
        }
    }
    
}

extension FollowerListVC: UICollectionViewDelegate {
    
    //PARA DETERMINAR SI LLEGO AL FINAL DEL SCROLL
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        print("Called")
        
        let offsetY         = scrollView.contentOffset.y // obtenemos el offset que es cuan abajo hiciste scroll
        let contentHeight   = scrollView.contentSize.height // la altura del contenido en pantalla
        let height          = scrollView.frame.size.height // la altura de la pantalla

        if offsetY > contentHeight - height {
            
            guard hasMoreFollowers else { return }
            page += 1
            getFollowers(username: username, page: page)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let activeArray     = isSearching ? filteredFollowers : followers
        let follower        = activeArray[indexPath.item]

        //let destVC          = UserInfoVC()
       // destVC.username     = follower.login
       // let navController   = UINavigationController(rootViewController: destVC)
        //present(navController, animated: true)
    }
}
