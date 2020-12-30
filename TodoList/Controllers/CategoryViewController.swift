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
    override func viewDidLoad() {
        super.viewDidLoad()
        //coredata
        //coreDataLoadCategory()
        
        //realm
        realmLoadCategory()
    }
    
    // CoreData
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var categorys = [Category]()
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
    
    // Realm
    let realm = try! Realm()
    var realmCategorys: Results<RealmCategory>?   // Results is a auto-update container type
    func realmAddCategory (with name: String){
        let newCategory = RealmCategory()
        newCategory.name = name

        do {
            try realm.write{
                realm.add(newCategory)
            }
        }catch{
            print("something wrong when realm. write \(error)")
        }
    }
    func realmLoadCategory (){
        realmCategorys = realm.objects(RealmCategory.self)
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
                    //coredata
                    //self.coreDataAddCategory(with: text)
                    
                    //realm
                    self.realmAddCategory(with: text)
                    
                    self.tableView.reloadData()
                }
            }
        }
        alertController.addAction(alertAction)
        present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //cordata
        //return categorys.count
        
        // realm
        return realmCategorys?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)

        // coredata
        //let text = categorys[indexPath.row].name
        
        // realm
        let text = realmCategorys?[indexPath.row].name ?? "no Category yet"
        cell.textLabel?.text = text

        return cell
    }
    
    // MARK: - Table View delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC =  segue.destination as! TodoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            // coredata
            //destinationVC.selectedCategory = categorys[indexPath.row]
            
            // realm
            destinationVC.selectedRealmCategory = realmCategorys?[indexPath.row]
        }
    }
}

