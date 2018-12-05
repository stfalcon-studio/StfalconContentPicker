//
//  MenuViewController.swift
//  CollectionImagePicker
//
//  Created by Vitalii Vasylyda on 11/23/18.
//  Copyright © 2018 stFalcon. All rights reserved.
//

import UIKit

final class MenuViewController: UIViewController {

    // MARK: - IBOutlet
    
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var pageControl: UIPageControl!
    
    // MARK: - properties
    
    let mockDescription = MockDescription()
    var dataSource: [ProjectDescription] = []
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Stfalcon content picker example"
        dataSource = mockDescription.getMockData()
        collectionView.reloadData()
    }
}

// MARK: - Private methods

private extension MenuViewController {
    func configureCalendarCollectionView() {
        collectionView.register(MenuCollectionViewCell.nib, forCellWithReuseIdentifier: MenuCollectionViewCell.reuseIdentifier)
    }
}

// MARK: - UICollectionViewDataSource

extension MenuViewController: UICollectionViewDataSource, UIScrollViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MenuCollectionViewCell.reuseIdentifier, for: indexPath) as! MenuCollectionViewCell
        
        cell.configureWith(dataSource[indexPath.item].title, description: dataSource[indexPath.item].descriptionString)
        
        cell.didTapOnButtonAction = { [unowned self] in
            switch indexPath.item {
            case 0: self.performSegue(withIdentifier: "MediaViewController", sender: self)
            case 1: self.performSegue(withIdentifier: "ConversationViewController", sender: self)
            default: break
            }
        }
        
        return cell
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        pageControl?.currentPage = Int(scrollView.contentOffset.x) / Int(scrollView.frame.width)
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        pageControl?.currentPage = Int(scrollView.contentOffset.x) / Int(scrollView.frame.width)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension MenuViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: collectionView.bounds.height)
    }
}
