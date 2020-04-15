//
//  RatingHistoryVC.swift
//  StamuraiAssignment
//
//  Created by Rahul Bawane on 15/04/20.
//  Copyright © 2020 Rahul Bawane. All rights reserved.
//

import UIKit
import CoreData

struct RatingHistory {
    var rating = Int()
    var date = String()
    var minimum = Int()
    var maximum = Int()

    init(rating: Int, date: String, minimum: Int, maximum: Int) {
        self.rating = rating
        self.date = date
        self.minimum = minimum
        self.maximum = maximum
    }
}

class RatingHistoryCell: UITableViewCell {
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var ratingView: RatingView!

    override func awakeFromNib() {
        ratingView.isUserInteractionEnabled = false
        ratingView.backgroundColor = UIColor.clear
        ratingView.contentMode = UIView.ContentMode.scaleAspectFit
    }
    
    func configureCell(ratingData: RatingHistory) {
        ratingLabel.text = "Rating: \(ratingData.rating)"
        dateLabel.text = "Date: " + ratingData.date
        ratingView.maxRating = ratingData.maximum
        ratingView.minRating = ratingData.minimum
        ratingView.rating = ratingData.rating
    }
}

class RatingHistoryVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    var ratings = [RatingHistory]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        getRatings()
    }

        func getRatings() {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Rating")
            //request.predicate = NSPredicate(format: "age = %@", "12")
            request.returnsObjectsAsFaults = false
            do {
                let result = try context.fetch(request)
                for data in result as! [NSManagedObject] {
                    let rating = data.value(forKey: "rating") as! Int
                    let date = data.value(forKey: "date") as! String
                    let minimum = data.value(forKey: "minimum") as! Int
                    let maximum = data.value(forKey: "maximum") as! Int
                    let arrayValue = RatingHistory(rating: rating, date: date, minimum: minimum, maximum: maximum)
                    print(arrayValue)
                    ratings.append(arrayValue)
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } catch {
                print("Failed")
            }
        }
}

extension RatingHistoryVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ratings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RatingHistoryCell", for: indexPath) as! RatingHistoryCell
        cell.configureCell(ratingData: ratings[indexPath.row])
        return cell
    }
}
