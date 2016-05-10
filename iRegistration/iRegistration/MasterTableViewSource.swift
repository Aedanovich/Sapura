//
//  MasterTableViewSource.swift
//  iReception
//
//  Created by Alex on 22/11/15.
//  Copyright © 2015 A2. All rights reserved.
//

import UIKit
import CoreData

typealias DidUpdateListCount = (Int) -> ()
typealias DidSelectGuest = (Guest) -> ()

class MasterTableViewSource: NSObject, NSFetchedResultsControllerDelegate, UITableViewDataSource, UITableViewDelegate {
    var didSelectGuest: DidSelectGuest? = nil
    var didUpdateListCount: DidUpdateListCount? = nil
    
    var tableView: UITableView? = nil
    var managedObjectContext: NSManagedObjectContext? = nil
    
    func clear() {
        _fetchedResultsController = nil
    }
    
    func reload() {
        do {
            try fetchedResultsController.performFetch()
        }
        catch {
            
        }
    }
    
    // MARK: - Table View
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header: UIView! = UIView(frame: CGRectMake(0, 0, tableView.bounds.size.width, 20))
        header.backgroundColor = UIColor(white: 0.15, alpha: 1.0)
        
        let label = UILabel(frame: CGRectInset(header.bounds, 15.0, 0))
        label.font = UIFont(name: "HelveticaNeue", size: 12.0)
        label.textColor = UIColor.whiteColor()
        header.addSubview(label)
        
        if let title = self.fetchedResultsController.sections?[section].name {
            label.text = title
        }
        
        return header
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return (self.fetchedResultsController.sections?.count != 0) ?  20 : 0
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 64
    }
    
    let defaultCount = 1
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        guard let sections = self.fetchedResultsController.sections else { return defaultCount }
        if sections.count == 0 { return defaultCount }

        return sections.count ?? defaultCount
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = self.fetchedResultsController.sections else {
            return defaultCount
        }
        if sections.count == 0 {
            return defaultCount
        }
        
        let sectionInfo = sections[section]
        return sectionInfo.numberOfObjects
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var isAddCell = false
        if let sections = self.fetchedResultsController.sections {
            if sections.count == 0 {
                isAddCell = true
            }
        }

        if isAddCell {
            let cell = tableView.dequeueReusableCellWithIdentifier("AddGuestTableViewCell", forIndexPath: indexPath)
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCellWithIdentifier("GuestTableViewCell", forIndexPath: indexPath)
            self.configureCell(cell, atIndexPath: indexPath)
            return cell
        }
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if self.fetchedResultsController.sections?.count != 0 {
            if let _ = didSelectGuest {
                let object: Guest! = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Guest
                didSelectGuest!(object)
            }
        }
    }
    
    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        let object: Guest! = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Guest
        
        let guestCell = cell as! GuestTableViewCell
        
        if let value = object.name {
            guestCell.nameLabel.text = value
        }
        if let value = object.host?.name {
            guestCell.hostNameLabel.text = "Host " + value
        }
        if let value = object.timeStamp {
            guestCell.timelabel.text = value.getStringTime()
        }
        if let value = object.image {
            guestCell.guestImageView?.image = UIImage(data: value)
        }
        else if let value = object.imagePath {
            guestCell.guestImageView?.setImageWithURL(NSURL(string: value), usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.White)
            guestCell.guestImageView?.backgroundColor = UIColor.blackColor()
        }
        else {
            guestCell.guestImageView?.image = UIImage(named: "user-placeholder.png")
        }
    }
    
    
    // MARK: - Fetched results controller
    
    var fetchedResultsController: NSFetchedResultsController {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest = NSFetchRequest()
        // Edit the entity name as appropriate.
        let entity = NSEntityDescription.entityForName("Guest", inManagedObjectContext: self.managedObjectContext!)
        fetchRequest.entity = entity
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        
        // Edit the sort key as appropriate.
        let sortDescriptor = NSSortDescriptor(key: "timeStamp", ascending: false)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: "date", cacheName: "Master")
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
        do {
            try _fetchedResultsController!.performFetch()
        } catch {
            abort()
        }
        
        didUpdateListCount!(todayListCount())

        return _fetchedResultsController!
    }
    
    var _fetchedResultsController: NSFetchedResultsController? = nil
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.tableView!.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case .Insert:
            if controller.sections?.count == 1 && controller.sections?[0].objects?.count == 1 {
                tableView!.reloadData()
            }
            else {
                self.tableView!.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
            }
            break
        case .Delete:
            self.tableView!.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
            break
        default:
            return
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        if let _ = tableView {
            switch type {
            case .Insert:
                if controller.sections?.count == 1 && controller.sections?[0].objects?.count == 1 {
                    tableView!.reloadData()
                }
                else {
                    tableView!.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
                }
                break
            case .Delete:
                tableView!.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
                break
            case .Update:
                if let cell = tableView!.cellForRowAtIndexPath(indexPath!) {
                    self.configureCell(cell, atIndexPath: indexPath!)
                }
                break
            case .Move:
                tableView!.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
                tableView!.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
                break
            }            
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        didUpdateListCount!(todayListCount())

        self.tableView!.endUpdates()
    }
    
    // MARK: Today's Guest
    func todayListCount() -> Int {
        var count = 0
        for section in self.fetchedResultsController.sections! {
            if section.name.containsString("Today") {
                count = section.numberOfObjects
                break
            }
        }
        return count
    }
    
}
