//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved./Users/geyin/Dropbox/CS/IOS app/Todoey-iOS13/Todoey/Controllers/TodoListViewController.swift
//

import UIKit

class TodoListViewController: UITableViewController {
    
    var itemArray = [Items]()
    let dataFilepath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
    
    override func viewDidLoad() {
        super.viewDidLoad()
//
//        print(dataFilepath)
        
        let newItem = Items()
        newItem.title = "A"
        itemArray.append(newItem)
        let newItem2 = Items()
        newItem2.title = "B"
        itemArray.append(newItem2)
        
//        if let items = defaults.array(forKey: "TodoListArray") as? [Items] {
//            itemArray = items
//        }
        // Do any additional setup after loading the view.
    }

    //Mark - TableView Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoItemCell", for: indexPath)
        
        let curItem = itemArray[indexPath.row]
        cell.textLabel?.text = curItem.title
        
        cell.accessoryType = curItem.done ? .checkmark : .none
        
        return cell
    }
    
    //Mark - TebleView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        saveItems()
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //Mark - Add New Items
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Todo Item", message: "", preferredStyle: .alert)
        
        //this happens when the additemaction completed
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            //what will happen once the user clickes the add item button on our alert
            let newItem = Items()
            newItem.title = textField.text!
            self.itemArray.append(newItem)
            self.saveItems()
        }
        
        //this happens when the alert pop up
        alert.addTextField { (alertTextField) in
            //alertTextField only exist in this closeure scope, shoule expand it use local var textfield
            alertTextField.placeholder = "Creat new item"
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func saveItems() {
        let encoder = PropertyListEncoder()
        do {
            let data = try encoder.encode(itemArray)
            try data.write(to: dataFilepath!)
        } catch {
            print("Error encoding item array, \(error)")
        }
        
        
        self.tableView.reloadData()
    }
}
