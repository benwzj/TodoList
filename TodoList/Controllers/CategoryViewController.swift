//
//  CategoryViewController.swift
//  TodoList
//
//  Created by Ben Wen on 27/12/20.
//

import UIKit
import CoreData
import RealmSwift
import ChameleonFramework

class CategoryViewController: SwipeTableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 80.0
        
        //coredata
        //coreDataLoadCategory()
        
        //realm
        realmLoadCategory()
    }
    override func viewWillAppear(_ animated: Bool) {
        guard let navBar = navigationController?.navigationBar else {
            fatalError("navigatinBar is not ready")
        }
        navBar.backgroundColor = UIColor(hexString: "1D9BF6")
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
        newCategory.color = UIColor.randomFlat().hexValue()

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
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        // coredata
        //let text = categorys[indexPath.row].name
        
        // realm
        let text = realmCategorys?[indexPath.row].name ?? "no Category yet"
        cell.textLabel?.text = text
        if let cellColor = UIColor(hexString: realmCategorys?[indexPath.row].color ?? "6EC2F8"){
            cell.textLabel?.textColor = ContrastColorOf(cellColor, returnFlat: true)
            cell.backgroundColor = cellColor
        }
        
        return cell
    }
    
    // MARK: - Table View delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
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
    override func deleteCell(indexPath: IndexPath){
        if let categorys = realmCategorys {
            do{
               try realm.write{
                    realm.delete(categorys[indexPath.row])
                }
            }catch {
                print("Someting wrong \(error)")
            }
            //tableView.reloadData()
        }
    }
}
