//
//  CategoryTableViewController.swift
//  TodayDemo
//
//  Created by Mac on 19/04/19.
//  Copyright © 2019 Mac. All rights reserved.
//

import UIKit
import CoreData
class CategoryTableViewController: UITableViewController {

    
    var categories = [Category]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadCategories()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return categories.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath)
        
        cell.textLabel?.text = categories[indexPath.row].name
        
        return cell
    }
    
    @IBAction func addButtonClick(_ sender: Any) {
        
        var textField = UITextField()
        let alert = UIAlertController(title: "Add new category", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            
            //getting coredata persistent context
            
            let newCategory = Category(context: self.context)
            newCategory.name = textField.text!
           
            self.categories.append(newCategory)
            self.saveitems()
        }
        alert.addTextField { (alertTextfield) in
            alertTextfield.placeholder = "Add new category"
            textField = alertTextfield
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    
    //MARK: data manupulation method
    
    func saveitems(){
        do{
            try context.save()
        }catch{
            print("error saving context \(error)")
        }
        self.tableView.reloadData()
    }
    
    //read data from coredata
    func loadCategories(){
        
        let request : NSFetchRequest<Category> = Category.fetchRequest()
        
        do{
            categories =  try context.fetch(request)
        }
        catch{
            print("error while fetching data from context \(error)")
        }
        self.tableView.reloadData()
    }
    
    //MARK : tableview delegate method
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "gotoItem", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        
        if let index =  tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categories[index.row]
        }
    }
    

}
