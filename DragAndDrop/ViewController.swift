//
//  ViewController.swift
//  DragAndDrop
//
//  Created by Mansi Mahajan on 7/3/18.
//  Copyright © 2018 Mansi Mahajan. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var imageArray = [#imageLiteral(resourceName: "search1"), #imageLiteral(resourceName: "camera"), #imageLiteral(resourceName: "search1"), #imageLiteral(resourceName: "camera"), #imageLiteral(resourceName: "search1"), #imageLiteral(resourceName: "camera"), #imageLiteral(resourceName: "search1"), #imageLiteral(resourceName: "camera"), #imageLiteral(resourceName: "search1"), #imageLiteral(resourceName: "camera")]

    @IBOutlet weak var collectionViewOutlet: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionViewOutlet.dragInteractionEnabled = true
        collectionViewOutlet.dropDelegate = self
        collectionViewOutlet.dragDelegate = self
        collectionViewOutlet.reorderingCadence = .fast
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //reorder positions of images
    private func reorderItems(coordinator: UICollectionViewDropCoordinator, destinationIndexPath: IndexPath, collectionView: UICollectionView)
    {
        let items = coordinator.items
        if items.count == 1, let item = items.first, let sourceIndexPath = item.sourceIndexPath
        {
            var dIndexPath = destinationIndexPath
            if dIndexPath.row >= collectionView.numberOfItems(inSection: 0)
            {
                dIndexPath.row = collectionView.numberOfItems(inSection: 0) - 1
            }
            collectionView.performBatchUpdates({
                self.imageArray.remove(at: sourceIndexPath.row)
                self.imageArray.insert(item.dragItem.localObject as! UIImage, at: dIndexPath.row)
                collectionView.deleteItems(at: [sourceIndexPath])
                collectionView.insertItems(at: [dIndexPath])
            })
            coordinator.drop(items.first!.dragItem, toItemAt: dIndexPath)
        }
    }

}

//set images and number of cells in collectionView
extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as! CollectionViewCell
        cell.imageSet.image = imageArray[indexPath.row]
        return cell
    }
}


//perform drag operation
extension ViewController: UICollectionViewDragDelegate {
    
    //Drag only 1 image at a time
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let item = imageArray[indexPath.row]
        let itemProvider = NSItemProvider(object: item as UIImage)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = item
        return [dragItem]
    }
    
    //Drag multiple images
    func collectionView(_ collectionView: UICollectionView, itemsForAddingTo session: UIDragSession, at indexPath: IndexPath, point: CGPoint) -> [UIDragItem] {
        let item = imageArray[indexPath.row]
        let itemProvider = NSItemProvider(object: item as UIImage)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = item
        return [dragItem]
    }
    
    //set size of the preview
    func collectionView(_ collectionView: UICollectionView, dragPreviewParametersForItemAt indexPath: IndexPath) -> UIDragPreviewParameters?
    {
            let previewParameters = UIDragPreviewParameters()
            previewParameters.visiblePath = UIBezierPath(rect: CGRect(x: 5, y: 5, width: 70, height: 70))
            return previewParameters
    }
}


extension ViewController: UICollectionViewDropDelegate {
    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool
    {
        print(session.canLoadObjects(ofClass: UIImage.self))
        return session.canLoadObjects(ofClass: UIImage.self)
    }
    
    //performed before dragging the image
    //while dragging an image, CollectionView calls this method repeatedly to determine how you would handle the drop if it occurs at the specified location
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal
    {
        if session.localDragSession != nil
        {
            if collectionView.hasActiveDrag
            {
                return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
            }
            else
            {
                return UICollectionViewDropProposal(operation: .copy, intent: .insertAtDestinationIndexPath)
            }
        }
        else
        {
            return UICollectionViewDropProposal(operation: .forbidden)
        }
    }
    
    //perform drop operation at destination
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator)
    {
        let destinationIndexPath: IndexPath
        if let indexPath = coordinator.destinationIndexPath
        {
            destinationIndexPath = indexPath
        }
        else
        {
            // Get last index path of table view.
            let section = collectionView.numberOfSections - 1
            let row = collectionView.numberOfItems(inSection: section)
            destinationIndexPath = IndexPath(row: row, section: section)
        }
        
        switch coordinator.proposal.operation
        {
        case .move:
            self.reorderItems(coordinator: coordinator, destinationIndexPath:destinationIndexPath, collectionView: collectionView)
            break
            
        case .copy: break
            //self.copyItems(coordinator: coordinator, destinationIndexPath: destinationIndexPath, collectionView: collectionView)
            
        default:
            return
        }
    }
}
