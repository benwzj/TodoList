//
//  ViewController.swift
//  TodoList
//
//  Created by Ben Wen on 23/12/20.
//

import UIKit
import CoreData

class TodoListViewController: UITableViewController{

    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var items = [Item]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadItems()
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoItemCell", for: indexPath)
        let item = items[indexPath.row]
        cell.textLabel?.text = item.title
        cell.accessoryType = item.done ? .checkmark : .none

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt: IndexPath){
        items[didSelectRowAt.row].done = !items[didSelectRowAt.row].done
        self.saveItems()
        tableView.reloadData()
        tableView.deselectRow(at: didSelectRowAt, animated: true)
    }
    
//MARK: - Add Items
    
    @IBAction func AddButtonPressed(_ sender: UIBarButtonItem) {
        var newTextField: UITextField?
        let alertController = UIAlertController(title: "Add Item Title", message: "", preferredStyle: .alert)
        let alertAction = UIAlertAction (title: "Add Item", style: .default) { (action) in
            if let tf = newTextField {
                if let text = tf.text{
                    let newItem = Item(context: self.context)
                    newItem.title = text
                    newItem.done = false
                    self.items.append(newItem)
                    self.saveItems()
                    self.tableView.reloadData()
                }
            }
        }
        alertController.addAction(alertAction)
        alertController.addTextField { (textField) in
            textField.placeholder = "please write something"
            newTextField = textField
        }
        present(alertController, animated: true, completion: nil)
        
    }
    
    func saveItems() {
        do {
            try context.save()
        }catch{
            print("Something wrong when save context : \(error)")
        }
    }
    
    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest()) {
        do {
            items = try context.fetch(request)
        }catch {
            print("try to fetch items error \(error)")
        }
    }
}

// MARK: - searchBar

extension TodoListViewController: UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        request.predicate = NSPredicate(format: "title CONTAINS [cd] %@", searchBar.text!)
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        loadItems(with: request)
        tableView.reloadData()
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            tableView.reloadData()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}
