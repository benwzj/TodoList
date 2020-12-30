//
//  ViewController.swift
//  TodoList
//
//  Created by Ben Wen on 23/12/20.
//

import UIKit
import CoreData
import RealmSwift

class TodoListViewController: SwipeTableViewController{

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 80.0
    }
    
    // CoreData
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var items = [Item]()
    var selectedCategory: Category? {
        didSet{
            loadItems()
        }
    }
    func saveItems() {
        do {
            try context.save()
        }catch{
            print("Something wrong when save context : \(error)")
        }
    }
    func addItem(with title: String){
        let newItem = Item(context: self.context)
        newItem.title = title
        newItem.done = false
        newItem.parentCategory = selectedCategory
        items.append(newItem)
        saveItems()
    }
    func loadItems(with predicate: NSPredicate? = nil ) {
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        
        if let additionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate])
        }else {
            request.predicate = categoryPredicate
        }
        
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        do {
            items = try context.fetch(request)
        }catch {
            print("try to fetch items error \(error)")
        }
    }
    
    // MARK: - realm
    var selectedRealmCategory: RealmCategory? {
        didSet {
            realmLoadItems()
        }
    }
    let realm = try! Realm()
    var realmItems: Results<RealmItem>?
    func realmSave(with item: RealmItem){
        do {
            try realm.write{
                realm.add(item)
            }
        }catch{
            print("something wrong when realmSave(): \(error)")
        }
    }
    func realmAdd(with text: String){
        if let currentCategory = selectedRealmCategory {
            do {
                try realm.write{
                    let newItem = RealmItem()
                    newItem.title = text
                    newItem.createdDate = Date()
                    currentCategory.items.append(newItem)
                }
            }catch{
                print("Something wrong when realmAdd(): \(error)")
            }
        }
    }
    func realmLoadItems(){
        realmItems = selectedRealmCategory?.items.sorted(byKeyPath: "title", ascending: true)
    }
    
    // MARK: - tableView dataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // coredata
        //return items.count
        
        // realm
        return realmItems?.count ?? 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView( tableView, cellForRowAt: indexPath)
        
        // CoreData
        //let item = items[indexPath.row]
        //cell.textLabel?.text = item.title
        //cell.accessoryType = item.done ? .checkmark : .none

        // realm
        if let item = realmItems?[indexPath.row]{
            cell.textLabel?.text = item.title
            cell.accessoryType = item.done ? .checkmark : .none
        }else{
            cell.textLabel?.text = "no item yet"
        }
        
        return cell
    }
    
    // MARK: - tableview delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt: IndexPath){
        // CoreData
        //items[didSelectRowAt.row].done = !items[didSelectRowAt.row].done
        //self.saveItems()
        
        // realm
        if let item = realmItems?[didSelectRowAt.row] {
            do{
                try realm.write{
                    item.done = !item.done
                }
            }catch{
                print ("Something wrong: \(error)")
            }
        }
        
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
                    //coredata
                    // self.addItem(with: text)
                    
                    //realm
                    self.realmAdd(with: text)
                    
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
    
    override func deleteCell(indexPath: IndexPath) {

        if let items = realmItems {
            do{
               try realm.write{
                    realm.delete(items[indexPath.row])
                }
            }catch {
                print("Someting wrong at deleteCell items \(error)")
            }
            //self.tableView.reloadData()
        }
    }
}

// MARK: - searchBar

extension TodoListViewController: UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // CoreData
        //let predicate = NSPredicate(format: "title CONTAINS [cd] %@", searchBar.text!)
        //loadItems(with: predicate)
        
        // realm
        realmItems = realmItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "title", ascending: true)
        
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            //CoreData
            //loadItems()
            
            // realm
            realmLoadItems()
            
            tableView.reloadData()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}
