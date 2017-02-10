//
//  DetailViewController.swift
//  ShiuAnimationSwift
//
//  Created by AllenShiu on 2017/2/10.
//  Copyright © 2017年 AllenShiu. All rights reserved.
//

import UIKit

typealias CloseBlock = () -> ()

class DetailViewController: UIViewController {
    var selectImage:UIImage = UIImage()
    var closeBlock:CloseBlock?
    
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    
    // MARK: setup
    
    func setupViews(){
        // 設定顯示圖片
         self.imageView.image = self.selectImage;
        
        // 設定按鈕
        self.button.alpha = 0;
        let constraintTop:NSLayoutConstraint = self.button.constraintTopWithSuper() as! NSLayoutConstraint
        constraintTop.constant = 25;
        self.view.layoutIfNeeded()
        
        // 設定 navigationBar 隱藏
        self.navigationController?.navigationBar.isHidden = true;

    }
    
    func setupShowButton(){
        let constraintTop:NSLayoutConstraint = self.button.constraintTopWithSuper() as! NSLayoutConstraint
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            constraintTop.constant = 0
            self.button.alpha = 1;
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    // MARK: IBAction
    
    @IBAction func closeButtonAction(_ sender: Any) {
        if self.closeBlock != nil {
            self.closeBlock!()
        }
    }
    
    // MARK: life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupShowButton()
    }
}

// MARK: Extension 使用

extension UIView {
    func constraintTopWithSuper()-> Any?{
        // 尋找 top 的 constraint
        for constraint in (self.superview?.constraints)!{
            let findConstraint:NSLayoutConstraint = constraint
            let isThisItem = (findConstraint.firstItem as! NSObject == self) || (findConstraint.secondItem as! NSObject == self)
            
            let isConstraint = constraint.firstAttribute == .top || constraint.secondAttribute == .top;
            
            if (isThisItem && isConstraint) {
                return constraint;
            }
        }
        print("No find this constraint")
        return nil;
    }
}
