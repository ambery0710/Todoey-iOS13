//
//  CatagoryViewController.swift
//  Todoey
//
//  Created by Ge Yin on 11/4/20.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift

class CatagoryViewController: SwipeTableViewController {
    
    let realm = try! Realm()
    
    var categoryArray: Results<Category>?

    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategory()
        tableView.rowHeight = 80
    }
    
    //MARK: - TableView Datasourse Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        let curCatagory = categoryArray?[indexPath.row]
        cell.textLabel?.text = curCatagory?.name ?? "No Category added yet"
        
        return cell
    }
    
    //MARK: - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)

    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categoryArray?[indexPath.row]
        }
    }
    
    //MARK: - Add New Catagory


    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Catagory", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Catagory", style: .default) { (action) in
            let newCategory = Category()
            newCategory.name = textField.text!
            self.save(category: newCategory)
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Creat New Catagory"
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Model Manupulation Methods
    
    func save(category: Category) {
        do {
            try realm.write {
                realm.add(category)
            }
        } catch  {
            print("Error saving context \(error)")
        }
        self.tableView.reloadData()
    }
    
    func loadCategory() {
        categoryArray = realm.objects(Category.self)

        tableView.reloadData()
    }
    
    //MARK: - Delete data form swipe
    override func updateModel(at indexPath: IndexPath) {
        if let categoryToBeDeleted = self.categoryArray?[indexPath.row] {
            do{
                try self.realm.write {
                    self.realm.delete(categoryToBeDeleted)
                }
            }catch {
                print("Error deleting category, \(error)")
            }
        }
    }
}


