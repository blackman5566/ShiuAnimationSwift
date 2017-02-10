//
//  CollectionViewCell.swift
//  ShiuAnimationSwift
//
//  Created by AllenShiu on 2017/2/9.
//  Copyright © 2017年 AllenShiu. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var petImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.petImageView.layer.borderColor = UIColor.gray.cgColor
        self.petImageView.layer.borderWidth = 3.0;
    }

}
