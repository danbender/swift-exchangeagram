import UIKit
import MobileCoreServices
import CoreData
import MapKit

class FeedViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    
//    use this feedArray to grab an array of feed items when i make the fetch request manually
    var feedArray:[AnyObject] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        //         make request
        let request = NSFetchRequest(entityName: "FeedItem")
        //        access to AppDelegate instance
        let appDelegate:AppDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
        //        with that access to NSManagedOjectContext
        let context:NSManagedObjectContext = appDelegate.managedObjectContext!
        //        actually make the request
        feedArray = context.executeFetchRequest(request, error: nil)!
        
//        refresh collectionView
        collectionView.reloadData()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func profileTapped(sender: UIBarButtonItem) {
        self.performSegueWithIdentifier("profileSegue", sender: nil)
    }
    
    
    @IBAction func snapBarButtonItemTapped(sender: UIBarButtonItem) {

        //        check if camera is available (it's not in simulator)
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            
//          Set up image controller: 
//          UIImagePickerController: special type of ui navigation controller that gives access to photos, videos, their libs
            
            var cameraController = UIImagePickerController()
            cameraController.delegate = self
            
//            which source type and media format
            cameraController.sourceType = UIImagePickerControllerSourceType.Camera
            let mediaTypes:[AnyObject] = [kUTTypeImage]
            cameraController.mediaTypes = mediaTypes
//            here, disallow editing of photos
            cameraController.allowsEditing = false
            
//            present on screen
            self.presentViewController(cameraController, animated: true, completion: nil)
        }
            
//            use photo lib if no cam is available (e.g. in simulator)
        else if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
                
                var photoLibraryController = UIImagePickerController()
                photoLibraryController.delegate = self
                photoLibraryController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
                
                let mediaTypes:[AnyObject] = [kUTTypeImage]
                photoLibraryController.mediaTypes = mediaTypes
                photoLibraryController.allowsEditing = false
                
                self.presentViewController(photoLibraryController, animated: true, completion: nil)
                
        }
            
        else {
                var alertController = UIAlertController(title: "Alert", message: "Your device does not support the camera or photo library", preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                
                self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    
//    UIImagePickerControllerDelegate
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {

//    Since this is a dict we don't know which type we're getting back; specfifying with as!: want the original image UIImagePickerControllerOriginalImage back; no cropping, editing or so
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        println(image)
        
//        convert img in data representation of this img
        let imageData = UIImageJPEGRepresentation(image, 1.0)
        let thumbNailData = UIImageJPEGRepresentation(image, 0.1)
        
//        create feed item
        let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        let entityDescription = NSEntityDescription.entityForName("FeedItem", inManagedObjectContext: managedObjectContext!)
        let feedItem = FeedItem(entity: entityDescription!, insertIntoManagedObjectContext: managedObjectContext!)
        
//        set up actual feed item and save it
        feedItem.image = imageData
        feedItem.caption = "text caption"
        feedItem.thumbNail = thumbNailData
        
        (UIApplication.sharedApplication().delegate as! AppDelegate).saveContext()
        
//        save directly
        feedArray.append(feedItem)
        
//     Dismiss ViewController after we pick an image
        self.dismissViewControllerAnimated(true, completion: nil)
        
//        tell collection to reload itself directly
        self.collectionView.reloadData()
        
    }
    
    
//    UICollectionViewDataSource
    
    func numberOfSectionsInCollectionView(collectionView:UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return feedArray.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
//        set up cell
        var cell:FeedCell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! FeedCell
        
        let thisItem = feedArray[indexPath.row] as! FeedItem
        
//        update cell to display image and caption.
        cell.imageView.image = UIImage(data: thisItem.image)
        cell.captionLabel.text = thisItem.caption
        
        return cell
    }
    
    
//    UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
//        get the item that was tapped
        let thisItem = feedArray[indexPath.row] as! FeedItem
        
        var filterVC = FilterViewController()
        filterVC.thisFeedItem = thisItem
        
//        push to filterVC
        self.navigationController?.pushViewController(filterVC, animated: false)
        
    }

    
    
    
    
    
    
    
    
    
    
}
