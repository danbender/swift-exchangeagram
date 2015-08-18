import UIKit
import MobileCoreServices
import CoreData

class FeedViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
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
        
//        create feed item
        let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        let entityDescription = NSEntityDescription.entityForName("Feed Item", inManagedObjectContext: managedObjectContext!)
        let feedItem = FeedItem(entity: entityDescription!, insertIntoManagedObjectContext: managedObjectContext!)
        
//        set up actual feed item and save it
        feedItem.image = imageData
        feedItem.caption = "text caption"
        
        (UIApplication.sharedApplication().delegate as! AppDelegate).saveContext()
        
        
//     Dismiss ViewController after we pick an image
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
//    UICollectionViewDataSource
    
    func numberOfSectionsInCollectionView(collectionView:UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        return UICollectionViewCell()
    }

}
