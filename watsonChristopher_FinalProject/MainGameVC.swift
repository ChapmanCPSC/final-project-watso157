//
//  MainGameVC.swift
//  watsonChristopher_FinalProject
//
//  Created by Christopher Watson on 5/11/16.
//  Copyright © 2016 Chapman University. All rights reserved.
//

import UIKit
import GameplayKit

class FlickrFotoObject : NSObject {
    var title : String!
    var content : String!
}

class GameFotoObject : NSObject {
    var image : UIImage!
    var name : String!
}


class MainGameVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet weak var cvMemoryBoard: UICollectionView!
    @IBOutlet weak var lblAttempts: UILabel!
    @IBOutlet weak var lblTopScore: UILabel!
    
    @IBOutlet weak var btnReplay: UIButton!
    @IBOutlet weak var btnNewCategory: UIButton!
    @IBOutlet weak var lblLoading: UILabel!
    
    var catImport : String = "None"
    var flickrFeed = NSMutableArray()
    var catImageArray = NSMutableArray()
    var answerKey = NSMutableArray()
    var gameArray = NSMutableArray()
    
    var firstPickedName = ""
    var secondPickedName = ""
    var firstPickedIndex = NSIndexPath()
    var secondPickedIndex = NSIndexPath()
    var tapCount = 0
    var tryCount = 0
    var matchedPairs = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Add pulse to lblloading
        self.lblLoading.layer.addAnimation(self.addPulseAnimation(), forKey: nil)

        
        //Set up the views hidden property
        self.lblTopScore.hidden = true
        self.lblAttempts.hidden = true
        self.cvMemoryBoard.hidden = true
        self.btnNewCategory.hidden = true
        self.btnReplay.hidden = true
        
        
        if catImport == "None" {
            print(catImport)
            
            let alert = UIAlertController(title: "Whoops!", message: "Please select a category", preferredStyle: UIAlertControllerStyle.Alert)
            let alertOK = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default) { (action) in
                self.navigationController!.popToRootViewControllerAnimated(true)
            }
            
            alert.addAction(alertOK);
            
            self.presentViewController(alert, animated: true, completion: nil)

            
        }
        else {
            makeRequest()
            for object in flickrFeed{
                print(object.title)
            }
        }
        
        self.cvMemoryBoard.registerNib(UINib(nibName: "CustomViewCell", bundle: nil), forCellWithReuseIdentifier: "memCardCell")
        
    }
    

    func makeRequest() {
        
        let urlString = "https://api.flickr.com/services/feeds/photos_public.gne?tags=\(catImport)&format=json&nojsoncallback=1"
        
        //NSURL Request Start
        if let URL = NSURL(string: urlString) {
            
            //Set up Swift NS parsed request
            NSURLSession.sharedSession().dataTaskWithURL(URL,
                completionHandler: { (data : NSData?, response: NSURLResponse?, error : NSError?) -> Void in
                    
                    let fetchedData = NSString(data: data!, encoding: NSUTF8StringEncoding)
                
                    let cleansed = fetchedData?.stringByReplacingOccurrencesOfString("\\'", withString: "'")
                    
                    let cleansedData : NSData = (cleansed!.dataUsingEncoding(NSUTF8StringEncoding))!
//                    
//                    print (fetchedData!)
//                    print ("Cleansed is: \(cleansed!)")
                    
        
                    //Create Dict for json objects
                    do {
                        if let picList = try NSJSONSerialization.JSONObjectWithData(cleansedData, options: []) as? NSDictionary{
                            
                            let pics = picList.valueForKey("items") as! NSArray
                            
                            //For each Jsonpic, make a FlickrFotoObject
                            for i in 0...7
                            {
                                let dicPic = pics[i] as! NSDictionary
                                let object = FlickrFotoObject()
                                
                                object.title = "\(dicPic.valueForKey("title") as! String)i"
                                object.content = dicPic.valueForKeyPath("media.m") as! String
                                
                                //When object is made, add it to the
                                self.flickrFeed.addObject(object)
                                
                            }
                            print("Number of dicPics loaded \(self.flickrFeed.count)")

                            //Give the pictures to the collection view when done
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                //For each flickrfoto download the images and put them into an image array
                                for image in self.flickrFeed{
                                    let imgURL = NSURL(string: image.content)
//                                    print(image.content)
                                    self.getDataFromUrl(imgURL!) { (data, response, error)  in
                                        dispatch_async(dispatch_get_main_queue()) { () -> Void in
                                            guard let data = data where error == nil else { return }
                                            
                                            let imageToAdd = UIImage(data: data)
                                            let gameObject = GameFotoObject()
                                            gameObject.image = imageToAdd!
                                            gameObject.name = image.title!
                                            self.catImageArray.addObject(gameObject)
                                            self.catImageArray.addObject(gameObject)
//                                            print(gameObject.name)
//                                            print("Number of images loaded \(self.catImageArray.count)")
                                            if self.catImageArray.count == 16 {
                                                self.scrambleAndAssembleGame()
                                                self.lblLoading.hidden = true
                                                self.lblLoading.layer.removeAllAnimations()
                                                self.lblAttempts.hidden = false
                                                self.lblTopScore.hidden = false
                                                self.cvMemoryBoard.hidden = false
                                            }
                                        }
                                    }
                                }
                            })
                            
//                            print(picList)
//                            for image in self.flickrFeed{
//                                print(image)
//                            }
                        }
                    }
                    catch let error as NSError {
                        print(error.localizedDescription)
                        let alert = UIAlertController(title: "Whoops!", message: "You must have internet connection", preferredStyle: UIAlertControllerStyle.Alert)
                        let alertOK = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default) { (action) in
                            self.navigationController!.popToRootViewControllerAnimated(true)
                        }
                        
                        alert.addAction(alertOK);
                        
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                    
                    
            }).resume()
        }
    }

    func scrambleAndAssembleGame() {
        for item in self.catImageArray{
            print (item.name!)
        }
        
        
        let shuffledArray = GKRandomSource.sharedRandom().arrayByShufflingObjectsInArray(self.catImageArray as Array)
        for item in shuffledArray {
            self.gameArray.addObject(item)
            print(item)
        }
        
        
        print("#ofItems in gameArry = \(self.gameArray.count)")
        
        
    }
    
    
    //Collection View Methods
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 4
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("memCardCell", forIndexPath: indexPath) as! CustomViewCell
        
        cell.backgroundColor = UIColor.whiteColor()
        

        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        //Assign cell and get indexNum from position
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! CustomViewCell
        
        var indexNum = 0;
        if (indexPath.section == 0){
            indexNum = indexPath.row
        }
        else if (indexPath.section == 1){
            indexNum = indexPath.row + 4
        }
        else if (indexPath.section == 2){
            indexNum = indexPath.row + 8
        }
        else if (indexPath.section == 3){
            indexNum = indexPath.row + 12
        }
        
        //Tap handlers and so on
        //Inc tap count now
        ++tapCount
        
        //Set second touched card to secondPicked
        
        if (tapCount == 3){
            for customIndexPath : NSIndexPath in self.cvMemoryBoard.indexPathsForVisibleItems() {
                print("Removing all images")
                self.cvMemoryBoard.deselectItemAtIndexPath(customIndexPath, animated: false)
                let cellLosingImage = collectionView.cellForItemAtIndexPath(customIndexPath) as! CustomViewCell
                if cellLosingImage.userInteractionEnabled{
                    cellLosingImage.customImage.image = nil
                }
            }
            tapCount = 1
        }
        
        let gameObject = self.gameArray[indexNum] as! GameFotoObject
        let image : UIImage = gameObject.image as UIImage
        
        // set a transition style
        let transitionOptions = UIViewAnimationOptions.TransitionFlipFromTop
        
        UIView.transitionWithView(cell.contentView, duration: 0.5, options: transitionOptions, animations: {
            //Assign image to cell
            cell.customImage.image = image
            
            }, completion: { finished in
                
        })
        
        
        //Set first touched card to firstPicked
        if tapCount == 1{
            self.firstPickedName = gameObject.name
            self.firstPickedIndex = indexPath
            
        }
        else if (tapCount == 2){
            ++tryCount
            self.lblAttempts.text = "Tries: \(tryCount)"
            self.secondPickedName = gameObject.name
            self.secondPickedIndex = indexPath
            
            var score = 48 - tryCount
            self.lblTopScore!.text = "Score: \(score)"
            
            if (self.firstPickedName == self.secondPickedName) && (self.firstPickedIndex != self.secondPickedIndex) {
                let cellToDisable1 = collectionView.cellForItemAtIndexPath(self.firstPickedIndex) as! CustomViewCell
                cellToDisable1.userInteractionEnabled = false
                cellToDisable1.customImage.alpha = 0.5
                let cellToDisable2 = collectionView.cellForItemAtIndexPath(self.secondPickedIndex) as! CustomViewCell
                cellToDisable2.userInteractionEnabled = false
                cellToDisable2.customImage.alpha = 0.5
                ++matchedPairs
                
                if matchedPairs == 8 {
                    self.cvMemoryBoard.hidden = true
                    self.btnNewCategory.hidden = false
                    self.btnReplay.hidden = false
                    self.lblLoading!.text = "You Win!"
                    self.lblLoading.hidden = false
                    self.lblLoading.layer.addAnimation(self.addPulseAnimation(), forKey: nil)
                }
            }
        }
        
        
        
        
        
        
        
        print("Image selected with indexNum: \(indexNum)")
        
        
        
    }
    
    
    @IBAction func tappedCategory(sender: AnyObject) {
        self.lblLoading!.text = "Loading..."
        self.lblLoading.layer.removeAllAnimations()
        self.navigationController!.popToRootViewControllerAnimated(true)
        
    }
    @IBAction func tappedReplay(sender: AnyObject) {
        self.lblLoading.hidden = true
        self.lblLoading!.text = "Loading..."
        self.lblLoading.layer.removeAllAnimations()
        self.matchedPairs = 0
        self.tapCount = 0
        self.tryCount = 0
        
        for index : NSIndexPath in self.cvMemoryBoard.indexPathsForVisibleItems(){
            let cell = self.cvMemoryBoard.cellForItemAtIndexPath(index) as! CustomViewCell
            cell.userInteractionEnabled = true
            cell.customImage.alpha = 1.0
            cell.customImage.image = nil
        }
        
        
        self.cvMemoryBoard.hidden = false
        self.btnReplay.hidden = true
        self.btnNewCategory.hidden = true
        
        
        
        
    }
    func addPulseAnimation() -> CABasicAnimation {
        let pulseAnimation = CABasicAnimation(keyPath: "opacity")
        pulseAnimation.duration = 0.2
        pulseAnimation.fromValue = 0
        pulseAnimation.toValue = 1
        pulseAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        pulseAnimation.autoreverses = true
        pulseAnimation.repeatCount = FLT_MAX
        return pulseAnimation
    }
    
    
    func getDataFromUrl(url:NSURL, completion: ((data: NSData?, response: NSURLResponse?, error: NSError? ) -> Void)) {
        NSURLSession.sharedSession().dataTaskWithURL(url) { (data, response, error) in
            completion(data: data, response: response, error: error)
            }.resume()
    }
    
    

}

