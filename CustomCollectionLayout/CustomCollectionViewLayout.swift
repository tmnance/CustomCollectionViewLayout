//
//  CustomCollectionViewLayout.swift
//  CustomCollectionLayout
//
//  Created by JOSE MARTINEZ on 15/12/2014.
//  Copyright (c) 2014 brightec. All rights reserved.
//

import UIKit

class CustomCollectionViewLayout: UICollectionViewLayout {
    lazy var numberOfColumns: Int = {
        return collectionView?.numberOfItems(inSection: 0) ?? 0
    }()
    var shouldPinFirstColumn = true
    var shouldPinFirstRow = true

    var itemAttributes = [[UICollectionViewLayoutAttributes]]()
    var itemsSize = [CGSize]()
    var contentSize: CGSize = .zero

    override func prepare() {
        guard let collectionView = collectionView else {
            return
        }

        if collectionView.numberOfSections == 0 {
            return
        }

        if itemAttributes.count != collectionView.numberOfSections {
            // first pass, generate initial values
            generateItemAttributes(collectionView: collectionView)
            return
        }

//        // update pass, only need to update frozen rows/cols
//        for section in 0..<collectionView.numberOfSections {
//            for item in 0..<numberOfColumns {
//                if section != 0 && item != 0 {
//                    continue
//                }
//
//                let attributes = layoutAttributesForItem(
//                    at: IndexPath(item: item, section: section)
//                    )!
//
//                if section == 0 {
//                    attributes.frame.origin.y = max(
//                        collectionView.contentOffset.y,
//                        0
//                    )
//                }
//                if item == 0 {
//                    attributes.frame.origin.x =
//                        min(
//                            collectionView.contentOffset.x +
//                                collectionView.frame.width -
//                                attributes.frame.width,
//                            contentSize.width - attributes.frame.width
//                    )
//                }
//            }
//        }

        // update pass, only need to update frozen rows/cols
        for rowIndex in 0..<collectionView.numberOfSections {
//            let attributes = layoutAttributesForItem(
//                at: IndexPath(item: 0, section: rowIndex)
//                )!
            let attributes = itemAttributes[rowIndex][0]
            attributes.frame.origin.x =
                min(
                    collectionView.contentOffset.x +
                        collectionView.frame.width -
                        attributes.frame.width,
                    contentSize.width - attributes.frame.width
            )
        }

        let newY = max(
            collectionView.contentOffset.y,
            0
        )
        for colIndex in 0..<numberOfColumns {
//            let attributes = layoutAttributesForItem(
//                at: IndexPath(item: colIndex, section: 0)
//            )!
            let attributes = itemAttributes[0][colIndex]
            attributes.frame.origin.y = newY
        }
    }

    override var collectionViewContentSize: CGSize {
        return contentSize
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return itemAttributes[indexPath.section][indexPath.row]
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var attributes = [UICollectionViewLayoutAttributes]()
        for section in itemAttributes {
            let filteredArray = section.filter { obj -> Bool in
                return rect.intersects(obj.frame)
            }

            attributes.append(contentsOf: filteredArray)
        }

        return attributes
    }

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}


// MARK: - Helpers
extension CustomCollectionViewLayout {
    func generateItemAttributes(collectionView: UICollectionView) {
        if itemsSize.count != numberOfColumns {
            calculateItemSizes()
        }

        var column = 0
        var xOffset: CGFloat = 0
        var yOffset: CGFloat = 0
        var contentWidth: CGFloat = 0
        var frozenColWidth: CGFloat = 0

        itemAttributes = []

        for rowIndex in 0..<collectionView.numberOfSections {
            var sectionAttributes: [UICollectionViewLayoutAttributes] = []

            for colIndex in 0..<numberOfColumns {
                let itemSize = itemsSize[colIndex]
                let indexPath = IndexPath(item: colIndex, section: rowIndex)
                let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                attributes.frame = CGRect(
                    x: xOffset,
                    y: yOffset,
                    width: itemSize.width,
//                    width: colIndex == 0 && rowIndex % 2 == 1 ?
//                        collectionView.frame.width :
//                        itemSize.width,
                    height: rowIndex == 0 ? CGFloat(40) : itemSize.height
                ).integral
                attributes.transform = CGAffineTransform(scaleX: -1, y: 1)

                if rowIndex == 0 && colIndex == 0 {
                    // First cell should be on top
                    attributes.zIndex = 1024
                } else if rowIndex == 0 || colIndex == 0 {
                    // First row/column should be above other cells
                    attributes.zIndex = 1023
                }

                if rowIndex == 0 {
                    attributes.frame.origin.y = collectionView.contentOffset.y
                }
                if colIndex == 0 {
                    attributes.frame.origin.x =
                        collectionView.contentOffset.x +
                        collectionView.frame.width -
                        attributes.frame.width
                    frozenColWidth = attributes.frame.width
                }

                sectionAttributes.append(attributes)

                if colIndex > 0 {
                    xOffset += attributes.frame.width
                }
                column += 1

                if colIndex == numberOfColumns - 1 {
                    xOffset += frozenColWidth
                    if xOffset > contentWidth {
                        contentWidth = xOffset
                    }

                    column = 0
                    xOffset = 0
                    yOffset += attributes.frame.height
                }
            }

            itemAttributes.append(sectionAttributes)
        }

        if let attributes = itemAttributes.last?.last {
            contentSize = CGSize(width: contentWidth, height: attributes.frame.maxY)
        }
    }

    func calculateItemSizes() {
        itemsSize = []

        for index in 0..<numberOfColumns {
            itemsSize.append(sizeForItemWithColumnIndex(index))
        }
    }

    func sizeForItemWithColumnIndex(_ columnIndex: Int) -> CGSize {
        var text: NSString

        switch columnIndex {
        case 0:
            text = "MMM-99"

        default:
            text = "☑️"
        }

        let size: CGSize = text.size(
            withAttributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14.0)]
        )
        let width: CGFloat = size.width + 16
        return CGSize(width: width, height: 30)
    }
}
