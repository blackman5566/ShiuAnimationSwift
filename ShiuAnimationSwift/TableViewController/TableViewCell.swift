//
//  TableViewCell.swift
//  ShiuAnimationSwift
//
//  Created by AllenShiu on 2017/2/9.
//  Copyright © 2017年 AllenShiu. All rights reserved.
//

import UIKit

protocol TableViewCellDelegate : NSObjectProtocol
{
    func collectionViewDidSelectedItemIndexPath(indexPath:NSIndexPath,collcetionView:UICollectionView,cell:TableViewCell)
}

class TableViewCell: UITableViewCell,UICollectionViewDelegate,UICollectionViewDataSource {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var delegate:TableViewCellDelegate!
    
    // MARK: set
    var items : NSArray = [] {
        didSet{
            self.collectionView.reloadData()
        }
    }
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath){
        self.delegate?.collectionViewDidSelectedItemIndexPath(indexPath: indexPath as NSIndexPath, collcetionView: collectionView, cell: self)
    }
    
    // MARK: UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.items.count;
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
         let collectionViewCell = "CollectionViewCell";
         let cell = collectionView.dequeueReusableCell(withReuseIdentifier: collectionViewCell, for: indexPath) as! CollectionViewCell
         cell.petImageView.image = UIImage(named:"\(self.items[indexPath.row])")
        return cell
    }
    
    // MARK: setup
    
    func setupCollectionView() {
        self.collectionView.register(UINib(nibName:"CollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CollectionViewCell")
        self.collectionView.collectionViewLayout = setupCollectionViewFlowLayout();
        self.collectionView.backgroundColor = UIColor.white;
        self.collectionView.showsHorizontalScrollIndicator = false;
        self.collectionView.showsVerticalScrollIndicator = false;
        self.collectionView.dataSource = self;
        self.collectionView.delegate = self;
        self.collectionView.contentInset = UIEdgeInsetsMake(0, 20, 0, 0);
    }
   
    func setupCollectionViewFlowLayout()->UICollectionViewFlowLayout{
        let collectionViewLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        collectionViewLayout.itemSize = CGSize(width: 300, height: 236)
        collectionViewLayout.minimumInteritemSpacing = 0;
        collectionViewLayout.minimumLineSpacing = 0;
        collectionViewLayout.scrollDirection = .horizontal;
        return collectionViewLayout
    }
    
    // MARK: override
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupCollectionView()
    }
}
