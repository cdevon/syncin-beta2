//
//  ViewController.swift
//  BrightonHartwell
//
//  Created by Christian Gibson on 6/18/16.
//  Copyright © 2016 Brighton Hartwell. All rights reserved.
//


import UIKit
import Foundation
import CoreData
import MessageUI
import Contacts
import MultipeerConnectivity
import ContactsUI

var contact: NSManagedObject! //user's CoreData contact

var theContact: CNContact!

var informationArray = [String](count: 6, repeatedValue: "") //String array of user information
//sent easier over bluetooth
var imageData: NSData! //user's busi card data

var appDelegate: AppDelegate!

protocol AddContactViewControllerDelegate {
    func didFetchContacts(contacts: [CNContact])
}

class ViewController: UIViewController, UITextFieldDelegate,  CNContactPickerDelegate {
    
    var effectAdded = "false"
    var delegate: AddContactViewControllerDelegate!
    
    //information displayed on home page
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var companyNameLabel: UILabel!
    @IBOutlet weak var jobNameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var linkedInLabel: UILabel!
    @IBOutlet weak var busiCardImageView: UIImageView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var navItem: UINavigationItem!
    
    @IBOutlet weak var activityScreen: UIView!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.view.sendSubviewToBack(self.activityScreen)
        self.activityScreen.alpha = 0.0
        
        appDelegate.requestForAccess { (accessGranted) -> Void in
            if accessGranted {
                let contactsStore = appDelegate.contactStore
                let predicate = CNContact.predicateForContactsMatchingName(contact.valueForKey("name") as! String)
                let keysToFetch = [CNContactVCardSerialization.descriptorForRequiredKeys()
                    , CNContactFormatter.descriptorForRequiredKeysForStyle(.FullName),
                    CNContactEmailAddressesKey,
                    CNContactPhoneNumbersKey,
                    CNContactImageDataKey,CNContactGivenNameKey, CNContactNoteKey, CNContactJobTitleKey, CNContactFamilyNameKey, CNContactUrlAddressesKey, CNContactOrganizationNameKey]
                var results: [CNContact] = []
                do {
                    results = try contactsStore.unifiedContactsMatchingPredicate(
                        predicate, keysToFetch: keysToFetch)
                } catch {
                    print("Error fetching containers")
                }
                
                let contacts = results
                var message = ""
                if contacts.count == 0 {
                    message = "No contacts were found matching the given name."
                    print(message)
                } else {
                    message = "Got your contact!"
                    theContact = contacts[0]
                    print(theContact.givenName)
                    //print("saved")
                    
                    name = contact.valueForKey("name") as? String
                    job = contact.valueForKey("profession") as? String
                    company = contact.valueForKey("company") as? String
                    phone = contact.valueForKey("phone") as? String
                    email = contact.valueForKey("email") as? String
                    linked = contact.valueForKey("linkedIn") as? String
                    busiImage = contact.valueForKey("businessCard") as! NSData
                    profImage = contact.valueForKey("profileImage") as! NSData
                    signedIn = "true"
                    //self.performSegueWithIdentifier("signinSegue", sender: self)
                }
                
            }
            
        }

        
        self.fullNameLabel.text = name
        self.jobNameLabel.text = job
        self.companyNameLabel.text = company
        self.phoneLabel.text = phone
        self.emailLabel.text = email
        self.linkedInLabel.text = linked
        
        if self.effectAdded == "false" {
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.busiCardImageView.bounds
        blurEffectView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight] // for supporting device rotation
        self.busiCardImageView.addSubview(blurEffectView)
        self.busiCardImageView.image = UIImage(data: busiImage)
            self.profileImageView.image = UIImage(data: profImage)
            self.effectAdded = "true"
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    //Contacts button tapped brings up regular contact screen
    @IBAction func showContacts(sender: AnyObject) {
        let contactPickerViewController = CNContactPickerViewController()
        
        contactPickerViewController.delegate = self
        
        presentViewController(contactPickerViewController, animated: true, completion: nil)
    }
    
    func contactPicker(picker: CNContactPickerViewController, didSelectContact contact: CNContact) {
        //delegate.didFetchContacts([contact])
        navigationController?.popViewControllerAnimated(true)
    }
    
    func share() {
        self.shareContact(self)
    }
    @IBAction func shareContact(sender: AnyObject) {
        let ac = UIAlertController(title: "Important Message", message: "Make sure the receipient has their AirPlay on", preferredStyle: .Alert)
        self.view.bringSubviewToFront(self.activityScreen)
        UIView.animateWithDuration(0.5) {
            
            self.activityScreen.alpha = 0.5
        }
        
        
        ac.addAction(UIAlertAction(title: "Send Business Card", style: .Default, handler: { (action) in
            
            
            let controller = UIActivityViewController(activityItems: [theContact.imageData!], applicationActivities: nil)
            controller.excludedActivityTypes = [UIActivityTypePostToFacebook, UIActivityTypePostToTwitter, UIActivityTypePostToWeibo, UIActivityTypePostToFlickr, UIActivityTypePostToTencentWeibo]
            controller.view.tintColor = UIColor.init(red: 93/255, green: 149/255, blue: 170/255, alpha: 1.0)
            self.presentViewController(controller, animated: true, completion: {
                self.view.sendSubviewToBack(self.activityScreen)
                UIView.animateWithDuration(0.5) {
                
                self.activityScreen.alpha = 0.0
                }
            })
            
            controller.view.tintColor = UIColor.init(red: 93/255, green: 149/255, blue: 170/255, alpha: 1.0)
            
        }))
        
        ac.addAction(UIAlertAction(title: "Send Contact Card", style: .Default, handler: { (action) in
            
            
            let fileManager = NSFileManager.defaultManager()
            let cacheDirectory = try! fileManager.URLForDirectory(NSSearchPathDirectory.CachesDirectory, inDomain: NSSearchPathDomainMask.UserDomainMask, appropriateForURL: nil, create: true)
            
            let fileLocation = cacheDirectory.URLByAppendingPathComponent("\(CNContactFormatter().stringFromContact(theContact)!).vcf")
            
            do {
                let contactData = try CNContactVCardSerialization.dataWithContacts([theContact])
                contactData.writeToFile(fileLocation.path!, atomically: true)
                let controller = UIActivityViewController(activityItems: [fileLocation], applicationActivities: nil)
                controller.excludedActivityTypes = [UIActivityTypePostToFacebook, UIActivityTypePostToTwitter, UIActivityTypePostToWeibo, UIActivityTypePrint, UIActivityTypePostToFlickr, UIActivityTypePostToTencentWeibo]
                controller.view.tintColor = UIColor.init(red: 93/255, green: 149/255, blue: 170/255, alpha: 1.0)
                self.view.sendSubviewToBack(self.activityScreen)
                self.presentViewController(controller, animated: true, completion: {
                    UIView.animateWithDuration(0.5) {
                    
                    self.activityScreen.alpha = 0.0
                    }
                })
                controller.view.tintColor = UIColor.init(red: 93/255, green: 149/255, blue: 170/255, alpha: 1.0)
            } catch {
                print("error")
            }
            
            
            
        }))
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { (action) in
            
            UIView.animateWithDuration(0.5) {
            
            self.activityScreen.alpha = 0.0
            }
            self.view.sendSubviewToBack(self.activityScreen)
        }))
        
        //iOS 8
        ac.view.tintColor = UIColor.init(red: 93/255, green: 149/255, blue: 170/255, alpha: 1.0)
        
        self.presentViewController(ac, animated: true, completion: nil)
        
        //iOS 9
        ac.view.tintColor = UIColor.init(red: 93/255, green: 149/255, blue: 170/255, alpha: 1.0)
    }

    
  }




