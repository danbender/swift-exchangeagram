import UIKit

class FilterViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var thisFeedItem: FeedItem!
//    write collectionView in code, not drag'n drop it in storyboard
    var collectionView: UICollectionView!
    let kIntensity = 0.7
    var context:CIContext = CIContext(options: nil)
    var filters:[CIFilter] = []
    let placeHolderImage = UIImage(named: "Placeholder")
    let tmp = NSTemporaryDirectory()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//    write collectionView in code, not drag'n drop it in storyboard
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
//        item size (cell size)
        layout.itemSize = CGSize(width: 150.0, height: 150.0)
        
//         actually create collectionView
        collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        
        collectionView.dataSource = self
        collectionView.delegate = self

//        add to view; basic styling to make it visible
        collectionView.backgroundColor = UIColor.whiteColor()
        
//        in viewDidLoad register filterCell class with the collectionView
        collectionView.registerClass(FilterCell.self, forCellWithReuseIdentifier: "MyCell")
        
        self.view.addSubview(collectionView)
        
        filters = photoFilters()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
//    UICollectionViewDataSource
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filters.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell:FilterCell = collectionView.dequeueReusableCellWithReuseIdentifier("MyCell", forIndexPath: indexPath) as! FilterCell
        
//        if cell's image view has no image, create placeholer
        if cell.imageView.image == nil {
           
            //        set up default
            cell.imageView.image = placeHolderImage
            
            
            //        Create queue to fix single-thread perfomance crash;
            //        UI-related stuff ALWAYS ON THE MAIN THREAD!!
            let filterQueue:dispatch_queue_t = dispatch_queue_create("filter queue", nil)
            
            dispatch_async(filterQueue, { () -> Void in
                let filterImage = self.filteredImageFromImage(self.thisFeedItem.thumbNail, filter: self.filters[indexPath.row])
                
                //            once get back the filtered image, want to use that image to update our cells' imageView's image property
                //            update on main thread!
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    cell.imageView.image = filterImage
                })
            })
    
        }
        
        
        return cell
    }
    
    
//    Helper function
    
    func photoFilters() -> [CIFilter] {
        
        let blur = CIFilter(name: "CIGaussianBlur")
        let instant = CIFilter(name: "CIPhotoEffectInstant")
        let noir = CIFilter(name: "CIPhotoEffectNoir")
        let transfer = CIFilter(name: "CIPhotoEffectTransfer")
        let unsharpen = CIFilter(name: "CIUnsharpMask")
        let monochrome = CIFilter(name: "CIColorMonochrome")
        
//        adjust filters by setting the setValue() func
        let colorControls = CIFilter(name: "CIColorControls")
        colorControls.setValue(0.5, forKey: kCIInputSaturationKey)
        
        let sepia = CIFilter(name: "CISepiaTone")
        sepia.setValue(kIntensity, forKey: kCIInputIntensityKey)
        
        let colorClamp = CIFilter(name: "CIColorClamp")
        colorClamp.setValue(CIVector(x: 0.9, y: 0.9, z: 0.9, w: 0.9), forKey: "inputMaxComponents")
        colorClamp.setValue(CIVector(x: 0.2, y: 0.2, z: 0.2, w: 0.2), forKey: "inputMinComponents")
        
//        composite/combine filters by getting sepia.outputImage and then composite.outputImage etc.
        let composite = CIFilter(name: "CIHardLightBlendMode")
        composite.setValue(sepia.outputImage, forKey: kCIInputImageKey)
        
        let vignette = CIFilter(name: "CIVignette")
        vignette.setValue(composite.outputImage, forKey: kCIInputImageKey)
        vignette.setValue(kIntensity * 2, forKey: kCIInputIntensityKey)
        vignette.setValue(kIntensity * 30, forKey: kCIInputRadiusKey)
        
        return [blur, instant, noir, transfer, unsharpen, monochrome, colorControls, sepia, colorClamp, composite, vignette]
    }
    
    
//        pass in data from feedItem, pass in one of the filters
    func filteredImageFromImage (imageData: NSData, filter: CIFilter) -> UIImage {
        
        let unfilteredImage = CIImage(data: imageData)
        filter.setValue(unfilteredImage, forKey: kCIInputImageKey)
        
//        apply filter's properties to unfiltered image
        let filteredImage:CIImage = filter.outputImage
        
//        optimize image: sample image so creat extent which creates rect
        let extent = filteredImage.extent()
        let cgImage:CGImageRef = context.createCGImage(filteredImage, fromRect: extent)
        
//        get back final image, convert to UIImage
        let finalImage = UIImage(CGImage: cgImage)
        
        return finalImage!
        
    }
    
//    caching functions
    func cacheImage(imageNumber: Int) {
        let fileName = "\(imageNumber)"
        let uniquePath = tmp.stringByAppendingPathComponent(fileName)
        
        if !NSFileManager.defaultManager().fileExistsAtPath(fileName) {
            let data   = self.thisFeedItem.thumbNail
            let filter = self.filters[imageNumber]
            let image  = filteredImageFromImage(data, filter: filter)
            
            UIImageJPEGRepresentation(image, 1.0).writeToFile(uniquePath, atomically: true)
        }
    }
    
    func getCachedImage(imageNumber: Int) -> UIImage {
        let fileName = "\(imageNumber)"
        let uniquePath = tmp.stringByAppendingPathComponent(fileName)
       
        var image:UIImage
        
        if NSFileManager.defaultManager().fileExistsAtPath(uniquePath) {
            image = UIImage(contentsOfFile: uniquePath)!
        } else {
            self.cacheImage(imageNumber)
            image = UIImage(contentsOfFile: uniquePath)!
        }
        
        return image
    }
    
    
    
    
    
}
