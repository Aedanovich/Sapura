//
//  MasterViewController.swift
//  iReception
//
//  Created by Alex on 18/11/15.
//  Copyright © 2015 A2. All rights reserved.
//

import UIKit
import CoreData

class MasterViewController: BaseTableViewController, SettingsOptionsViewControllerDelegate {

    var detailViewController: DetailViewController? = nil
    var tableViewSource: MasterTableViewSource? = nil
    @IBOutlet weak var leftBarButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureView()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    /**
    * Configure the view
    *
    * Assign the delegate and datasource to detailview
    * Assign the didSelectGuest and didUpdateListCount handler from the table view source
    *
    * @see DetailViewDelegate
    * @see DetailViewDataSource
    * @see var detailViewController: DetailViewController
    * @see var tableViewSource: MasterTableViewSource
    */
    func configureView() {
        // Weak Reference
        weak var weakSelf = self
        
        // Table View Source
        tableViewSource = MasterTableViewSource()

        let cdm = CoreDataManager.sharedInstance
        tableViewSource?.managedObjectContext = cdm.managedObjectContext
        
        tableViewSource?.tableView = tableView
        
        // Assign the didSelectGuest handler from the table view source
        tableViewSource?.didSelectGuest = { guest in
            weakSelf?.detailViewController?.detailItem = guest
        }
        
        // Assign the didUpdateListCount handler from the table view source
        tableViewSource?.didUpdateListCount = { listCount in
            weakSelf?.updateTodayList(listCount)
        }

        // Assign the delegate and datasource to detailview
        tableView.delegate = tableViewSource
        tableView.dataSource = tableViewSource
        
        // Assign the detailViewController reference
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
    }
    

    /**
    * Updates the Navigation Bar Title, e.g. Guests (1 Today)
    *
    * @param list Number of guests for today
    */
    func updateTodayList(list: Int) {
        var title = "Guests"
        if list > 0 {
            title += " (\(list) today)"
        }
        self.title = title
    }

    /**
    * Handler for tapping the settings button at the left side of the navigation bar
    *
    * @param sender UIButton
    */
    @IBAction func settingsTapped(sender: AnyObject) {
        let popoverContent: SettingsOptionsViewController = self.storyboard?.instantiateViewControllerWithIdentifier("SettingsPopover") as! SettingsOptionsViewController

        popoverContent.delegate = self
        popoverContent.modalPresentationStyle = .Popover

        if let popover = popoverContent.popoverPresentationController {
            let viewForSource = sender as! UIView
            popover.sourceView = viewForSource
            
            // The position of the popover where it's showed
            popover.sourceRect = viewForSource.bounds
            
            // Arrow Direction
            popover.permittedArrowDirections = .Up
            
            // Size you want to display for the popover
            popoverContent.preferredContentSize = CGSizeMake(200, 54)
        }
        
        self.presentViewController(popoverContent, animated: true, completion: nil)
    }
    
    /**
    * Delegate Method for teh SettingsOptions Popover
    * Invokes the logout method
    */
    func settingsOptionsLogout() {
        logout()
        
        tableViewSource?.clear()
        CoreDataManager.sharedInstance.DeleteGuests()
                
        showLogin()
    }

    
    // MARK: - Segues
    /**
    * Segue
    *
    * @see DetailViewController
    */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
            let object = self.tableViewSource!.fetchedResultsController.objectAtIndexPath(indexPath)
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = object as? Guest
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }
}

