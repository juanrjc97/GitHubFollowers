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
    var collectionView: UICollectionView!
    var dataSource : UICollectionViewDiffableDataSource<Section, Follower>!
    
    override func viewDidLoad() {
      
        super.viewDidLoad()
        configureVC()
        configureCollectionView()
        getFollowers()
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
        //collectionView.delegate = self
        collectionView.backgroundColor = .systemBackground
        collectionView.register(FollowerCell.self, forCellWithReuseIdentifier: FollowerCell.reuseID)
    }
    
    func getFollowers() {
        
        NetworkManager.shared.getFollowers(for: username, page: 1) {[weak self] followers, errorMessage in
            
            //para evitar poner self? usar
            guard let self = self else{return }
            
            guard let followers = followers else{
                self.presentGFAlertOnMainThread(title: "ERROR", message: errorMessage!, buttonTitle: "OK")
                return
            }
            
            self.followers = followers
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
