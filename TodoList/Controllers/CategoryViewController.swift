//
//  CategoryViewController.swift
//  TodoList
//
//  Created by Ben Wen on 27/12/20.
//

import UIKit
import CoreData
import RealmSwift

class CategoryViewController: UITableViewController {
    // CoreData
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var categorys = [Category]()
    
    // Realm
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        coreDataLoadCategory()
    }

    // CoreData
    func coreDataLoadCategory(with request: NSFetchRequest<Category> = Category.fetchRequest()){
        do {
            categorys = try context.fetch(request)
        }catch {
            print("try to fetch items error \(error)")
        }
    }
    func coreDataAddCategory(with name: String){
        let newCategory = Category(context: self.context)
        newCategory.name = name
        categorys.append(newCategory)
        do {
           try context.save()
        }catch{
           print("Something wrong when save context : \(error)")
        }
    }
    
    @IBAction func addCategory(_ sender: UIBarButtonItem) {
        var newTextField: UITextField?
        let alertController = UIAlertController(title: "Category", message: "", preferredStyle: .alert)
        alertController.addTextField { (textField) in
            textField.placeholder = "what is your new Category"
            newTextField = textField
        }
        let alertAction = UIAlertAction (title: "Add Category", style: .default) { (action) in
            if let tf = newTextField {
                if let text = tf.text{
                    self.coreDataAddCategory(with: text)
                    self.tableView.reloadData()
                }
            }
        }
        alertController.addAction(alertAction)
        present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categorys.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)

        // Configure the cell...
        let category = categorys[indexPath.row]
        cell.textLabel?.text = category.name

        return cell
    }
    
    // MARK: - Table View delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC =  segue.destination as! TodoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categorys[indexPath.row]
        }
    }
}

