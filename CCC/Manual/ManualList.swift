//
//  ManualList.swift
//  CCC
//
//  Created by Truk Karawawattana on 21/1/2565 BE.
//

import UIKit
import Alamofire
import SwiftyJSON
import ProgressHUD



class ManualList: UIViewController, UIScrollViewDelegate {
    
    var manualJSON:JSON?
    
    @IBOutlet weak var myCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("MANUAL LIST")
        
        // CollectionView
        myCollectionView.delegate = self
        myCollectionView.dataSource = self
        myCollectionView.contentInset = UIEdgeInsets(top: 20, left: 30, bottom: 20, right: 30)
        
        loadList()
    }
    
    func loadList() {
        let parameters:Parameters = [:]
        loadRequest(method:.post, apiName:"activity_main", authorization:true, showLoadingHUD:true, dismissHUD:true, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                ProgressHUD.dismiss()

            case .success(let responseObject):
                let json = JSON(responseObject)
                //print("SUCCESS MANUAL LIST\(json)")
                
                self.manualJSON = json["data"]
                self.myCollectionView.reloadData()
            }
        }
    }
    
    @IBAction func back(_ sender: UIButton) {
        self.navigationController!.popViewController(animated: true)
    }
}

// MARK: - UICollectionViewDataSource

extension ManualList: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        if (manualJSON != nil) {
            return manualJSON!.count
        }
        else{
            return 0
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cellArray = manualJSON![indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier:"CategoryCell", for: indexPath) as! CategoryCell
        cell.cellImage.sd_setImage(with: URL(string:cellArray["act_img_name"].stringValue), placeholderImage: UIImage(named: "icon_1024"))
        //cell.cellTitle.text = cellArray["act_name_th"].stringValue
        
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension ManualList: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: 150 , height: 160)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0) //.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 30
    }
}

// MARK: - UICollectionViewDelegate

extension ManualList: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        
        let vc = UIStoryboard.manualStoryBoard.instantiateViewController(withIdentifier: "ManualForm") as! ManualForm
        vc.manualJSON = manualJSON![indexPath.item]
        self.navigationController!.pushViewController(vc, animated: true)
    }
}
