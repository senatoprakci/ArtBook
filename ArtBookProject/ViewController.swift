//
//  ViewController.swift
//  ArtBookProject
//
//  Created by Sena Toprakcı on 20.06.2023.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{

    @IBOutlet weak var tableView: UITableView!
    
    var nameArray = [String]()
    var idArray = [UUID]()
    var selectedPainting = " "
    var selectedPaintingId : UUID?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        
        
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(addButtonClicked))
        
        getData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NSNotification.Name(rawValue: "newData") , object: nil)
    }
    
    //Veri çekmek için getdata oluşturduk
    @objc func getData(){
        
        nameArray.removeAll()
        idArray.removeAll()
        
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            let results = try context.fetch(fetchRequest)
            if results.count > 0 {
                for result in results as! [NSManagedObject] {
                    if let name = result.value(forKey: "name") as? String{
                        self.nameArray.append(name)
                    }
                    
                    if let id = result.value(forKey: "id") as? UUID {
                        self.idArray.append(id)
                        
                    }
                    self.tableView.reloadData()
                
            }
            
                
            }
        } catch {
            print("error")
        }
     
    }
    
    @objc func addButtonClicked(){
        selectedPainting = ""
     performSegue(withIdentifier: "toDetailsVC", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nameArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = nameArray[indexPath.row]
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetailsVC" {
            let destinationVC = segue.destination as! DetailsVC
            destinationVC.chosenPainting = selectedPainting
            destinationVC.chosenPaintingId = selectedPaintingId
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedPainting = nameArray[indexPath.row]
        selectedPaintingId = idArray[indexPath.row]
        performSegue(withIdentifier: "toDetailsVC", sender: nil)
    }
    
    
    //Veri silmek
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            //fetch request neden? - ilgili veriyi çekicem çektikten sonra silicem
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
            
            //predicate kullanmamızın nedeni bir tane veriyi bulup onu silmek için
            let idString = idArray[indexPath.row].uuidString
            
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString)
            
            fetchRequest.returnsObjectsAsFaults = false
            
            do {
                let results = try context.fetch(fetchRequest)
                if results.count > 0 {
                    
                    for result in results as! [NSManagedObject] {
                        if let id = result.value(forKey: "id") as? UUID {
                            
                            //core datadan siliyor geri dönüşü yok
                            if id == idArray[indexPath.row] {
                                context.delete(result)
                                nameArray.remove(at: indexPath.row)
                                idArray.remove(at: indexPath.row)
                                self.tableView.reloadData()
                                
                                do {
                                    try context.save()
                                } catch {
                                    print("error")
                                }
                                
                            // id kullanmadığımız durumda for loop tan çıkmak için  break kullanabiliriz
        
                                break
                            }
                                
                        }
                    }
                            
                    
                }
            }
            catch{
                print("error")
            }
            
        }
            
    }


}

