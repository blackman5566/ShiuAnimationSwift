//
//  TableViewController.swift
//  ShiuAnimationSwift
//
//  Created by AllenShiu on 2017/2/9.
//  Copyright © 2017年 AllenShiu. All rights reserved.
//

import UIKit

enum SnapShotType {
    case SnapShotTypeUp // 剪裁var半部分
    case SnapShotTypeDown // 剪裁下半部分
}

class TableViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,TableViewCellDelegate,UIViewControllerTransitioningDelegate {
    var items : NSMutableArray = []
    let ScreenWidth = UIScreen.main.bounds.size.width
    let ScreenHeight = UIScreen.main.bounds.size.height
    let browseAnimation:BrowseAnimation = BrowseAnimation()
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: UIViewControllerTransitioningDelegate
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning?{
        self.browseAnimation.styleType = .StyleTypeFadeIn
        return self.browseAnimation
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.browseAnimation.styleType = .StyleTypeDismissNone
        return self.browseAnimation
    }
    
    // MARK: TableViewCellDelegate
    
    func collectionViewDidSelectedItemIndexPath(indexPath:NSIndexPath,collcetionView:UICollectionView,cell:TableViewCell)
    {
        // 獲得 collectionView 點擊 cell 的 imageView
        let collectionCell = collcetionView.cellForItem(at: indexPath as IndexPath) as! CollectionViewCell
        let imageView = collectionCell.petImageView
        let tapImageViewFrame = imageView?.superview?.convert((imageView?.frame)!, to: nil)
        let tapY = tapImageViewFrame?.origin.y
        let downY = tapY! + (tapImageViewFrame?.size.height)!
        
        // 上方圖片與下方圖片開始的 Frame
        let topImageViewOriginalFrame = CGRect(x: 0, y: 0, width: ScreenWidth, height: tapY!)
        let downImageViewOriginalFrame = CGRect(x: 0, y: downY, width: ScreenWidth, height: ScreenHeight - downY)
        
        // 上方圖片與下方圖片結束的 Frame
        let topImageViewEndFrame = CGRect(x: 0, y: -tapY!, width: ScreenWidth, height: tapY!)
        let downImageViewEndFrame = CGRect(x: 0, y: ScreenHeight, width: ScreenWidth, height: ScreenHeight - downY)
        
        // 獲得當前畫面的 image ，與上方跟下方的 image
        let snapImage = snapShotToImage()
        let topImage:UIImage = separationImage(image: snapImage, tapImageViewTopY: tapY!, snapShotType: .SnapShotTypeUp) as! UIImage
        let downImage:UIImage = separationImage(image: snapImage, tapImageViewTopY: downY, snapShotType: .SnapShotTypeDown) as! UIImage
        
        
        // 上方的圖片
        let topAnimationImageView = UIImageView()
        topAnimationImageView.frame = topImageViewOriginalFrame
        topAnimationImageView.image = topImage
        self.view.window?.addSubview(topAnimationImageView)
        
        // 下方的圖片
        let downAnimationImageView = UIImageView()
        downAnimationImageView.frame = downImageViewOriginalFrame
        downAnimationImageView.image = downImage
        self.view.window?.addSubview(downAnimationImageView)
        
        // 中間部分的圖片
        let collectionViewImageViewsInfo = findImageViewsFromCollectionView(collectionView:collcetionView);
        let imageViewOriginalFrames = collectionViewImageViewsInfo["collectionViewImageViewsFrame"];
        let collectionViewImageViews:NSMutableArray = collectionViewImageViewsInfo["collectionViewImageViews"] as! NSMutableArray;
        
        // 計算中間部分圖片的結束位置
        let imageViewEndFrames = calculateEndFrameWithImageViewOriginalFrames(imageViewOriginalFrames: imageViewOriginalFrames as! NSMutableArray, tapImageViewFrame: tapImageViewFrame!)
        
        UIView.animate(withDuration: 0.3, delay: 0.1, options: .curveEaseOut, animations:{
            
            // 上方的圖片往上移動
            topAnimationImageView.frame = topImageViewEndFrame;
            
            // 下方的圖片往下移動
            downAnimationImageView.frame = downImageViewEndFrame;
            
            // collectionView 每個 cell 圖片，設定結束的 frame
            for index in 0...collectionViewImageViews.count - 1 {
                let imageView:UIImageView = collectionViewImageViews.object(at: index) as! UIImageView
                let value:NSValue = imageViewEndFrames.object(at: index) as! NSValue
                let rect = value.cgRectValue
                imageView.frame = rect
            }
            self.tableView.isHidden = true;
        }, completion: { (finished: Bool) in
            let detailViewController = DetailViewController()
            detailViewController.selectImage = collectionCell.petImageView.image!
            let navigationController:UINavigationController = UINavigationController(rootViewController: detailViewController)
            navigationController.transitioningDelegate = self
            navigationController.modalPresentationStyle = .custom;
            
            // 將 DetailViewController 顯示出來
            self.present(navigationController, animated: true, completion: {
                // 當完成動畫時清除動畫圖片
                topAnimationImageView.removeFromSuperview()
                downAnimationImageView.removeFromSuperview()
                for imageView in collectionViewImageViews {
                    let findImageView:UIImageView = imageView as! UIImageView
                    findImageView.removeFromSuperview()
                }
                collectionViewImageViews.removeAllObjects();
            })
            
            // 設定結束時動畫
            detailViewController.closeBlock = self.closeAnimationWithTopImage(topImage: topImage, topImageViewOriginalFrame: topImageViewOriginalFrame, topImageViewEndFrame: topImageViewEndFrame, downImage: downImage, downImageViewOriginalFrame: downImageViewOriginalFrame, downImageViewEndFrame: downImageViewEndFrame, visibleCells: collcetionView.visibleCells as NSArray, imageViewEndFrames: imageViewEndFrames, imageViewOriginalFrames: imageViewOriginalFrames as! NSArray, detailViewController: detailViewController)
        })
        
    }
    
    func closeAnimationWithTopImage(topImage:UIImage,topImageViewOriginalFrame:CGRect,topImageViewEndFrame:CGRect,downImage:UIImage,downImageViewOriginalFrame:CGRect,downImageViewEndFrame:CGRect,visibleCells:NSArray,imageViewEndFrames:NSArray,imageViewOriginalFrames:NSArray,detailViewController:DetailViewController) -> CloseBlock{
        let closeBlock:CloseBlock = {
            // 上方的圖片
            let topAnimationImageView = UIImageView()
            topAnimationImageView.frame = topImageViewEndFrame
            topAnimationImageView.image = topImage
            detailViewController.view.window?.addSubview(topAnimationImageView)
            
            // 下方的圖片
            let downAnimationImageView = UIImageView()
            downAnimationImageView.frame = downImageViewEndFrame
            downAnimationImageView.image = downImage
            detailViewController.view.window?.addSubview(downAnimationImageView)
            
            // collectionView 每個 cell 圖片，設定結束的 frame
            let animationImageViews = NSMutableArray()
            for index in 0...visibleCells.count - 1 {
                let imageView:UIImageView = UIImageView()
                animationImageViews.add(imageView)
                let value:NSValue = imageViewEndFrames.object(at: index) as! NSValue
                let rect = value.cgRectValue
                imageView.frame = rect
                
                let collectionCell:CollectionViewCell = visibleCells.object(at: index) as! CollectionViewCell
                imageView.image = collectionCell.petImageView.image
                detailViewController.view.window?.addSubview(imageView)
            }
            
            UIView.animate(withDuration: 0.3, delay: 0.1, options: .curveEaseOut, animations:{
                
                // 上方的圖片往下移動
                topAnimationImageView.frame = topImageViewOriginalFrame;
                
                // 下方的圖片往上移動
                downAnimationImageView.frame = downImageViewOriginalFrame;
                
                // collectionView 每個 cell 圖片，設定結束的 frame
                for index in 0...animationImageViews.count - 1 {
                    let imageView:UIImageView = animationImageViews.object(at: index) as! UIImageView
                    let value:NSValue = imageViewOriginalFrames.object(at: index) as! NSValue
                    let rect = value.cgRectValue
                    imageView.frame = rect
                }
                
                // 詳細頁面的 view 隱藏
                detailViewController.view.isHidden = true;
                
            }, completion: { (finished: Bool) in
                
                // 當完成動畫時清除動畫圖片
                topAnimationImageView.removeFromSuperview()
                downAnimationImageView.removeFromSuperview()
                for imageView in animationImageViews {
                    let findImageView:UIImageView = imageView as! UIImageView
                    findImageView.removeFromSuperview()
                }
                animationImageViews.removeAllObjects();
                
                // 詳細頁面 dismis 掉
                detailViewController.dismiss(animated: true, completion: nil)
                
                // tbleView 與 navigationBar 顯示出來。
                self.tableView.isHidden = false;
                self.navigationController?.navigationBar.isHidden = false;
                
            })
        }
        return closeBlock
    }
    
    // MARK: UITableViewDataSource
    
    func tableView(_ tableView : UITableView, cellForRowAt indexPath : IndexPath)->UITableViewCell {
        let simpleTableIdentifier = "TableViewCell";
        let cell = tableView.dequeueReusableCell(withIdentifier: simpleTableIdentifier, for: indexPath) as! TableViewCell
        cell.titleLabel.text = "貓咪紅牌 第\( indexPath.row + 1)區";
        cell.items = self.items.object(at: indexPath.row) as! NSArray;
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if self.items.count > 0{
            return self.items.count
        }
        return 0
    }
    
    // MARK: private instance method
    // MARK: init
    
    func setupInitValue(){
        self.title = "貓貓紅牌榜";
    }
    
    func setupTableView(){
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.estimatedRowHeight = 300;
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        self.tableView.separatorStyle = .none;
        self.tableView.register(UINib(nibName:"TableViewCell", bundle: nil), forCellReuseIdentifier: "TableViewCell"
        )
        self.tableView.reloadData()
    }
    
    func setupTableViewData(){
        let items1 = ["1","2","3","4","5"]
        let items2 = ["6","7","8","9","10"]
        let items3 = ["11","12","13","14","15"]
        self.items.add(items1)
        self.items.add(items2)
        self.items.add(items3)
    }
    
    // MARK: misc
    
    func snapShotToImage () -> UIImage
    {
        UIGraphicsBeginImageContextWithOptions((self.view.window?.bounds.size)!, (self.view.window?.isOpaque)!, 0)
        self.view.window?.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    func separationImage( image : UIImage, tapImageViewTopY : CGFloat, snapShotType : SnapShotType) -> Any?{
        // 將圖片剪裁
        // 因為是取得點擊圖片的最小的 y 值，所以會有兩種情況必須要做判斷
        // 第一種：tapImageViewTopY 必須要大於 0 ，如果小於 0 的話代表點擊的圖片上半部份超出螢幕外面，所以就不做剪裁動作。
        // 第二種：tapImageViewTopY 必須要小於 imageSize.height，如果大於 imageSize.height 的話代表點擊的圖片下半部份超出螢幕外面，所以就不做剪裁動作。
        
        let imageSize = image.size
        let scale = UIScreen.main.scale
        var rect = CGRect.zero
        let isOverTopScreen = (tapImageViewTopY > 0)
        let isOverDownScreen = (tapImageViewTopY < imageSize.height)
        
        if isOverTopScreen && isOverDownScreen {
            switch snapShotType {
            case .SnapShotTypeUp:
                rect = CGRect(x: 0, y: 0, width: imageSize.width * scale, height: tapImageViewTopY * scale)
                break
            case .SnapShotTypeDown:
                rect = CGRect(x:0, y:tapImageViewTopY * scale, width:imageSize.width * scale,height:(imageSize.height - tapImageViewTopY) * scale)
                break
            }
            let sourceImageRef = image.cgImage;
            let newImageRef = sourceImageRef!.cropping(to: rect);
            let newImage = UIImage(cgImage: newImageRef!)
            return newImage;
        }else{
            return nil
        }
    }
    
    func findImageViewsFromCollectionView(collectionView:UICollectionView) -> NSDictionary{
        let cells = collectionView.visibleCells
        let collectionViewImageViews = NSMutableArray(capacity:cells.count)
        let collectionViewImageViewsFrame = NSMutableArray(capacity:cells.count)
        for cell in cells {
            // 轉換 frame
            let collectionViewCell:CollectionViewCell = cell as! CollectionViewCell
            let rect:CGRect = (collectionViewCell.petImageView?.superview?.convert((collectionViewCell.petImageView?.frame)!, to: nil))!
            let value = NSValue(cgRect:rect);
            collectionViewImageViewsFrame.add(value)
            
            // 將中間部分目前可視的 cell 拆成圖片並加入至 collectionViewImageViews，讓待會動畫時好處理。
            let animationImageView = UIImageView()
            animationImageView.image = collectionViewCell.petImageView.image;
            animationImageView.frame = rect;
            self.view.window?.addSubview(animationImageView)
            collectionViewImageViews.add(animationImageView)
        }
        // collectionViewImageViews:存放中間部分目前可視的 cell 圖片
        // collectionViewImageViewsFrame :存放中間部分目前可視的 cell 圖片 frame
        return ["collectionViewImageViews" : collectionViewImageViews,"collectionViewImageViewsFrame" : collectionViewImageViewsFrame]
    }
    
    func calculateEndFrameWithImageViewOriginalFrames(imageViewOriginalFrames:NSMutableArray,tapImageViewFrame:CGRect) -> NSMutableArray{
        // 中間圖片高度 2:3
        let tapImageViewEndFrame = CGRect(x: 0, y: 0, width: ScreenWidth, height: ScreenWidth * 2.0 / 3.0)
        let animationEndFrames = NSMutableArray()
        // 開始計算
        for index in 0...imageViewOriginalFrames.count - 1 {
            let value:NSValue = imageViewOriginalFrames.object(at: index) as! NSValue;
            let rect = value.cgRectValue;
            var targetRect = tapImageViewEndFrame;
            
            // 判斷目前圖片是在點擊圖片的左側還右側
            let isTapImageViewLeft = (rect.origin.x < tapImageViewFrame.origin.x)
            let isTapImageViewRight = (rect.origin.x > tapImageViewFrame.origin.x)
            if (isTapImageViewLeft) {
                // 在左邊
                let detla = tapImageViewFrame.origin.x - rect.origin.x;
                targetRect.origin.x = -(detla * ScreenWidth) / tapImageViewFrame.size.width;
            }else if (isTapImageViewRight) {
                // 在右邊
                let detla = rect.origin.x - tapImageViewFrame.origin.x;
                targetRect.origin.x = (detla * ScreenWidth) / tapImageViewFrame.size.width;
            }
            // 儲存起來
            let targetValue = NSValue(cgRect:targetRect);
            animationEndFrames.add(targetValue)
        }
        return animationEndFrames;
    }
    
    // MARK: life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupInitValue()
        setupTableViewData()
        setupTableView()
    }
}
