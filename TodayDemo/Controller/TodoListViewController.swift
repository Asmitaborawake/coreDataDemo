//
//  ViewController.swift
//  TodayDemo
//
//  Created by Mac on 17/04/19.
//  Copyright © 2019 Mac. All rights reserved.
//

import UIKit
import  CoreData
class TodoListViewController: UITableViewController {
    
    
    var itemArray = [Item]()
    var selectedCategory : Category?{
        didSet{
            loaditem()
        }
    }
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    
    //MARK: Tableview datasource method
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "todoCell", for: indexPath)
        let item =  itemArray[indexPath.row]
        cell.textLabel?.text = item.title
        //Ternary operater :
        //value = condition  ? valueTrue : valueFalse
        cell.accessoryType = item.done == true ? .checkmark : .none
        //use above ternary operater for if - else bottom
        //        if item.done == true{
        //            cell.accessoryType = .checkmark
        //        }else{
        //            cell.accessoryType = .none
        //        }
        return cell
        
    }
    
    //MARK: Delegate method
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(itemArray[indexPath.row])
        
        //this line of code works same as bottom code if - else
        //   itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        
        //        if itemArray[indexPath.row].done == false{
        //            itemArray[indexPath.row].done = true
        //        }else {
        //            itemArray[indexPath.row].done = false
        //        }
        
        
        //for delete object from coredata firstly delete object from context and then delete from array
        context.delete(itemArray[indexPath.row])
        itemArray.remove(at: indexPath.row)
        saveitems()
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    @IBAction func barButtonClick(_ sender: Any) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add todo item", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            
            //getting coredata persistent context
            
            let newItem = Item(context: self.context)
            newItem.title = textField.text!
            newItem.done = false
            newItem.parentCategory = self.selectedCategory
            self.itemArray.append(newItem)
            self.saveitems()
        }
        alert.addTextField { (alertTextfield) in
            alertTextfield.placeholder = "Create new item"
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
    func loaditem(with request : NSFetchRequest<Item> = Item.fetchRequest() , predicate: NSPredicate? = nil){
        //above we have external parameter as with and internal parameter as request in parameters we assign Item.fetchRequest() baecuse if we dont have parameter to give loaditem method then it will use Item.fetchRequest() else request as parameter , we use this method in viewdidload without parameter and in searchbar delegate method with parameter
        //here we have predicate parameter to chcek in which category or selcetd category will
        let CategoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        if let additionalPredicate = predicate{
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [CategoryPredicate ,additionalPredicate])
        }else {
            request.predicate = CategoryPredicate
        }
        
        do{
            itemArray =  try context.fetch(request)
        }
        catch{
            print("error while fetching data from context \(error)")
        }
        self.tableView.reloadData()
    }
    
    
    
    
    
}

//MARK: Searchbar method
extension TodoListViewController : UISearchBarDelegate{
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request : NSFetchRequest<Item> = Item.fetchRequest()
        let predicate  = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        
        //for soreting data in ascending order
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        loaditem(with: request, predicate: predicate)
        
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loaditem()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
            
        }
    }
}
