//
//  EnterRatingVC.swift
//  StamuraiAssignment
//
//  Created by Rahul Bawane on 14/04/20.
//  Copyright © 2020 Rahul Bawane. All rights reserved.
//

import UIKit
import CoreData

class EnterRatingVC: UIViewController {

    @IBOutlet weak var ratingView: RatingView!
    @IBOutlet weak var submitButton: UIButton!
    
    var minimum = 0
    var maximum = 9
    var rating = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        ratingView.backgroundColor = UIColor.clear

        /** Note: With the exception of contentMode, type and delegate,
         all properties can be set directly in Interface Builder **/
        ratingView.delegate = self
        ratingView.contentMode = UIView.ContentMode.scaleAspectFit
        ratingView.maxRating = maximum
        ratingView.minRating = minimum
        rating = minimum
    }
    
    @IBAction func submitAction(_ sender: UIButton) {
        let date = Date().changeFormat(from: "yyyy-MM-dd hh:mm:ss", to: "dd/MMM/yyyy HH:mm:ss a")
        addRating(rating: self.rating, date: "\(date)")
    }
}

extension EnterRatingVC: RatingViewDelegate {
    func updatedRating(rating: Int) {
        print(">>>>>>\(rating)")
        self.rating = rating
    }
    
    func updatingRating(rating: Int) {
        print("------\(rating)")
        self.rating = rating
    }
    
    func addRating(rating: Int, date: String) {
           let appDelegate = UIApplication.shared.delegate as! AppDelegate
           let context = appDelegate.persistentContainer.viewContext
           let entity = NSEntityDescription.entity(forEntityName: "Rating", in: context)!
           let data = NSManagedObject(entity: entity, insertInto: context)
           data.setValue(rating, forKey: "rating")
           data.setValue(date, forKey: "date")
            data.setValue(self.minimum, forKey: "minimum")
            data.setValue(self.maximum, forKey: "maximum")
           do {
               try context.save()
            self.navigationController?.popViewController(animated: true)
           } catch {
               print("Failed saving")
           }
       }
}

extension Date  {
    func changeFormat(from: String, to: String) -> String {
           let dateFormatter = DateFormatter()
           dateFormatter.dateFormat = from
           let date = dateFormatter.date(from: dateFormatter.string(from: self))
           dateFormatter.dateFormat = to
           return  dateFormatter.string(from: date!)
       }
}
