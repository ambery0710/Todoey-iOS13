//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved./Users/geyin/Dropbox/CS/IOS app/Todoey-iOS13/Todoey/Controllers/TodoListViewController.swift
//

import UIKit
import RealmSwift
import ChameleonFramework

class TodoListViewController: SwipeTableViewController {
    
    var todoItems: Results<Item>?
    let realm = try! Realm()
    @IBOutlet weak var searchBar: UISearchBar!
    
    var selectedCategory : Category? {
        didSet{
            loadItems()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if let colorHex = selectedCategory?.color {
            title = selectedCategory!.name
            guard let navBar = navigationController?.navigationBar else {fatalError("Navigation controller does not exist")}
            
            if let navBarColor = UIColor(hexString: colorHex) {
                navBar.backgroundColor = navBarColor
                navBar.tintColor =  ContrastColorOf(navBarColor, returnFlat: true)
                navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: ContrastColorOf(navBarColor, returnFlat: true)]
                searchBar.barTintColor = navBarColor
            }
        }
    }

    //MARK: - TableView Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let curItem = todoItems?[indexPath.row] {
            cell.textLabel?.text = curItem.title
            if let color = UIColor(hexString: selectedCategory!.color)?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(todoItems!.count)) {
                cell.backgroundColor = color
                cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
            }
            cell.accessoryType = curItem.done ? .checkmark : .none
            
        } else {
            cell.textLabel?.text = "No item added yet"
        }
        
        return cell
    }
    
    //MARK: - TebleView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let item = todoItems?[indexPath.row] {
            do {
                try realm.write {
                    item.done = !item.done
                }
            } catch {
                print("Error update done status,\(error)")
            }
            
        }
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK: - Add New Items
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Todo Item", message: "", preferredStyle: .alert)
        
        //this happens when the additemaction completed
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            //what will happen once the user clickes the add item button on our alert
            
            if let currentCategoty = self.selectedCategory {
                do {
                    try self.realm.write {
                        let newItem = Item()
                        newItem.title = textField.text!
                        newItem.dateCreated = Date()
                        currentCategoty.items.append(newItem)
                    }
                } catch  {
                    print("Error saving new items,\(error)")
                }
            }
            self.tableView.reloadData()
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
    
    //MARK: - Model Manupulation Methods
    
    func loadItems(){
        todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        tableView.reloadData()
    }
    
    //MARK: - Delete data from swipe
    override func updateModel(at indexPath: IndexPath) {
        
        if let itemToBeDeleted = todoItems?[indexPath.row] {
            do {
                try realm.write{
                    realm.delete(itemToBeDeleted)
                }
            } catch {
                print("Error deleting item, \(error)")
            }
        }
    }
    

}

// MARK: - Search Bar Methods
extension TodoListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        tableView.reloadData()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()

            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}
