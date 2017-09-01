//
//  CollectionViewLayout.swift
//  CollectionViewWithDifferentCellSizes
//
//  Created by naoya.watanabe on 2017/09/01.
//  Copyright © 2017年 naoya.watanabe. All rights reserved.
//

import UIKit

class CollectionViewLayout: UICollectionViewLayout {
    
    fileprivate var layoutAttributes = [UICollectionViewLayoutAttributes]()
    fileprivate var collection = Collection()
    
    fileprivate struct Collection {
        
        var size = CGSize.zero
        let columns = 3
        let interItemSpacing: CGFloat = 1
        let lineSpacing: CGFloat = 1
        var columnLength: CGFloat {
            get {
                return (self.size.width - interItemSpacing * CGFloat(self.columns - 1)) / CGFloat(self.columns)
            }
        }
        var layoutUnitHeight: CGFloat {
            get {
                let height = columnLength * CGFloat(layoutUnit.last!.row + layoutUnit.last!.length)
                let spacing = lineSpacing * CGFloat(layoutUnit.last!.row + layoutUnit.last!.length)
                return height + spacing
            }
        }
        
        let layoutUnit = [
            Item(.small,  col: 0, row: 0, length: 1),
            Item(.small,  col: 1, row: 0, length: 1),
            Item(.small,  col: 2, row: 0, length: 1),
            Item(.medium, col: 0, row: 1, length: 2),
            Item(.small,  col: 2, row: 1, length: 1),
            Item(.small,  col: 2, row: 2, length: 1),
            Item(.small,  col: 0, row: 3, length: 1),
            Item(.small,  col: 1, row: 3, length: 1),
            Item(.small,  col: 2, row: 3, length: 1),
            Item(.large,  col: 0, row: 4, length: 3)
        ]
        
        struct Item {
            
            let itemType: ItemType
            let col: Int
            let row: Int
            let length: Int
            
            enum ItemType {
                case small
                case medium
                case large
            }
            
            init(_ itemType: ItemType, col: Int, row: Int, length: Int) {
                self.itemType = itemType
                self.col = col
                self.row = row
                self.length = length
            }
        }
        
        func rect(at indexPath: IndexPath) -> CGRect {
            
            let item = self.layoutUnit[indexPath.row % self.layoutUnit.count]
            let x = columnLength * CGFloat(item.col) + interItemSpacing * CGFloat(item.col)
            let y = columnLength * CGFloat(item.row) + lineSpacing * CGFloat(item.row) + layoutUnitHeight * CGFloat(Int(indexPath.row / layoutUnit.count))
            let length: CGFloat
            
            switch item.itemType {
            case .small:
                length = columnLength * CGFloat(item.length)
            case .medium:
                length = columnLength * CGFloat(item.length) + interItemSpacing
            case .large:
                length = columnLength * CGFloat(item.length) + interItemSpacing * CGFloat(columns - 1)
            }
            return CGRect(x: x, y: y, width: length, height: length)
        }
        
    }
    
    override func prepare() {
        super.prepare()
        if self.collection.size != CGSize.zero { return }
        self.prepareLayoutAttributes()
    }
    
    override var collectionViewContentSize : CGSize {
        return self.collection.size
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var layoutAttributesInRect = [UICollectionViewLayoutAttributes]()
        
        for attributes in self.layoutAttributes {
            if attributes.frame.intersects(rect) {
                layoutAttributesInRect.append(attributes)
            }
        }
        return layoutAttributesInRect
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return self.layoutAttributes[indexPath.row]
    }
    
    fileprivate func prepareLayoutAttributes() {
        self.collection.size.width = collectionView!.bounds.width

        for item in 0 ..< collectionView!.numberOfItems(inSection: 0) {
            let indexPath = IndexPath(item: item, section: 0)
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = self.collection.rect(at: indexPath)
            self.layoutAttributes.append(attributes)
        }
        self.collection.size.height = self.layoutAttributes.last!.frame.origin.y + self.layoutAttributes.last!.frame.height
    }
    
}
