
import UIKit
import Firebase

class AddAllPlayersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate  {
    
    fileprivate var position:[String]=["Attack", "Midfielder", "Defence", "Goalkeeper"];
    fileprivate var allPlayersDivideByPosition:[String:[String]]=["Attack":[], "Midfielder":[], "Defence":[], "Goalkeeper":[]];
    fileprivate var allPlayersNames:[String]=[];
    
    fileprivate var playerPositionInPickerView:String = "Attack"; // Attack is the default in pickerView
    fileprivate var rowNameSelectedFromTableView:String = ""; // change to player name when user click on tbl row
    fileprivate var rowNumberSelectedFromTableView:Int = 0;
    fileprivate var pos:String = ""; // change to the position of player when user click on tbl row
    
    fileprivate let MAX_SIZE_PLAYER_NAME = 10
    fileprivate let MIN_PLAYERS_REQUIRED = 2
    
    @IBOutlet var insertPlayerName: UITextField!
    @IBOutlet var containerViewUp: UIView!
    @IBOutlet var containerViewDown: UIView!
    @IBOutlet var tblAllPlayers: UITableView!
    @IBOutlet var pckPlayerPosition: UIPickerView!
    @IBOutlet var playerPositionLabel: UILabel!
    @IBOutlet var nextBarBtn: UIBarButtonItem!
    @IBOutlet var playerAddedTitle: UILabel!
    
    fileprivate var groupNameStr:String?
    
    var rootRef = FIRDatabase.database().reference()
    
    override func viewDidLoad() {
        self.hideKeyboardWhenTappedAround()
        insertPlayerName.delegate = self
        
        containerViewUp.layer.cornerRadius = 10
        containerViewDown.layer.cornerRadius = 10
        tblAllPlayers.layer.cornerRadius = 10
        
        // background image for view
        self.view.addBackground("grasspng.png")// <- from ExtensionUIView.swift
        
        // check if in user storage (in UserDefaults) uploaded enough player to countinue
        // it's possible only if user move to this view from home page - UPLOAD PREVIOUS PLAYERS row
        if allPlayersNames.count < MIN_PLAYERS_REQUIRED{
            nextBarBtn.isEnabled = false;
        }
    }
    
    //from home page - UPLOAD PREVIOUS PLAYERS row -> players from storage (userDefault) + group name
    func setMsg(_ allPlayersDivideByPosition:[String:[String]], allPlayersNames:[String], groupName:String){
        self.allPlayersNames = allPlayersNames
        self.allPlayersDivideByPosition = allPlayersDivideByPosition
        self.groupNameStr = groupName
    }
    //overloaded method - from home page - ADD ALL PLAYERS row -> initial only group name
    func setMsg(groupName:String){
        self.groupNameStr = groupName
    }
    
    @IBAction func addPlayerBtn(_ sender: UIButton) {
        let nameInsert:String = insertPlayerName.text!
        // Toast if user try to add player when TextField is empty
        if nameInsert == "" {
            self.view.makeToast("Please, insert the player name...", duration: 3.0, position: .center, title: "Player Name Is Empty", image: nil, style: nil, completion: nil)
            return;
        }
        // Toast if user try to add long name of player
        if nameInsert.characters.count > MAX_SIZE_PLAYER_NAME{
            self.view.makeToast("Please, insert  10 letters max...", duration: 3.0, position: .center, title: "Player Name Is Too Long", image: nil, style: nil, completion: nil)
            return;
        }
        // Toast if user try to add an existing player
        for player in allPlayersNames{
            if nameInsert == player{
                self.view.makeToast("\(player) already exist", duration: 3.0, position: .center)
                return;
            }
        }
        
        reloadTblAllPlayers(nameInsert, playerPositionInPickerView : playerPositionInPickerView);
        insertPlayerName.text = "";
        
        // if user insert enough players, allow coutinue to next view
        if allPlayersNames.count >= MIN_PLAYERS_REQUIRED{//22{
            nextBarBtn.isEnabled = true;
        }
        
    }
    
    @IBAction func deletePlayerBtn(_ sender: UIButton) {
        if allPlayersNames.count == 0{
            self.view.makeToast("there is nothing to delete...", duration: 3.0, position: .center, title: "Table of Players Is Empty", image: nil, style: nil, completion: nil)
            return;
        }
        
        if rowNameSelectedFromTableView == ""{
            let lastNameInAllPlayerNameArr = self.allPlayersNames[allPlayersNames.count-1]
            for posa in self.position{
                for (indexName, name) in self.allPlayersDivideByPosition[posa]!.enumerated(){
                    //remove last player in allPlayersNames Array from allPlayersDivideByPosition Array
                    if name == lastNameInAllPlayerNameArr{
                        allPlayersDivideByPosition[posa]!.remove(at: indexName)
                    }
                }
            }
            self.allPlayersNames.removeLast();
            
        }else{
            for posa in self.position{
                for (indexName, name) in self.allPlayersDivideByPosition[posa]!.enumerated(){
            //remove player name in rowNameSelectedFromTableView from allPlayersDivideByPosition Array
                    if name == self.rowNameSelectedFromTableView{
                        allPlayersDivideByPosition[posa]!.remove(at: indexName)
                    }
                }
            }
            self.allPlayersNames.remove(at: self.rowNumberSelectedFromTableView);
            self.rowNameSelectedFromTableView = "";
            self.rowNumberSelectedFromTableView = allPlayersNames.count-1;
        }
        self.playerPositionLabel.text = "player position";
        
        // if there isn't MIN_PLAYERS_REQUIRED in list, don't allow continue to next view
        if allPlayersNames.count < MIN_PLAYERS_REQUIRED{//22{
            nextBarBtn.isEnabled = false;
        }
        reloadTblAllPlayers();
        
    }
    
    @IBAction func deleteAllPlayersBtn(_ sender: UIButton) {
        if allPlayersNames.count == 0{
            self.view.makeToast("there is nothing to delete...", duration: 3.0, position: .center, title: "Table of Players Is Empty", image: nil, style: nil, completion: nil)
        }else{
            //UIAlert - warning the user about he is going to delete all players he added
            let dialog = UIAlertController(title: "Delete all players added?", message: "YES -> for delete all, NO -> stay with the players added", preferredStyle: .alert);
            
            //Add Positive handler
            func okHandler(_ t:UIAlertAction){
                //allPlayersNames array became empty and reload empty table
                self.allPlayersNames = []
                self.allPlayersDivideByPosition = [position[0]:[], position[1]:[], position[2]:[], position[3]:[]];
                nextBarBtn.isEnabled = false;
                reloadTblAllPlayers()
                
            }
            dialog.addAction(UIAlertAction(title: "YES", style: .cancel, handler: okHandler));
            dialog.addAction(UIAlertAction(title: "NO", style: .default, handler: nil));
            present(dialog, animated: true, completion: nil);
        }
    }
    
    
    
    // change playersDivideByPosition Array by player name (TextField) in player position (PickerView)
    fileprivate func reloadTblAllPlayers(_ playerName:String, playerPositionInPickerView:String) {
        allPlayersNames.append(playerName);
        allPlayersDivideByPosition[playerPositionInPickerView]!.append(playerName);
        tblAllPlayers.reloadData();
    }
    
    fileprivate func reloadTblAllPlayers() {
        tblAllPlayers.reloadData();
    }
    
    
    // Methods for TableView
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.allPlayersNames.count;
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tblAllPlayers.cellDecoration(allPlayersNames, cellForRowAtIndexPath: indexPath)//cell;
    }
    
    // delegate method for TableView
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        for posa in self.position{ // player position when click on player name from tbl
            for name in self.allPlayersDivideByPosition[posa]!{
                if name == self.allPlayersNames[indexPath.row]{
                    self.pos = posa;
                }
            }
        }
        
        playerPositionLabel.text =  "\(self.pos) player";
        self.rowNameSelectedFromTableView = self.allPlayersNames[indexPath.row];
        self.rowNumberSelectedFromTableView = indexPath.row;
        
    }
    // Methods for PickerView
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1;
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 4; //Attack, MidFielder, Defence, GoalKeeper
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        return pickerView.pickerViewCellRanDesigned(viewForRow: row, reusingView: view, strArr: position, makeTextColors: false)
        
    }
    
    // delegate method for pickerView
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.playerPositionInPickerView = self.position[row];
    }
    
    @IBAction func infoBtn(_ sender: UIButton) {
        //build in Alert Dialog with UIAlertController object
        let dialog = UIAlertController(title: "Adding and deleting players", message: "For adding player:\nInsert player name in the white box, below choose the player position, finally press on 'Add Player' button.\nFor Deleting Player:\nChoose player from table, then press on 'Delete Player' button.\npress on 'Delete Player' button without choosing player will delete the last added player", preferredStyle: .alert);
        //add default button to dialog
        let btnAction=UIAlertAction(title: "OK", style: .cancel, handler: nil);
        dialog.addAction(btnAction);
        //show the dialog
        present(dialog, animated: true, completion: nil);
    }
    
    // Called when 'return' key pressed. return NO to ignore.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // Called when the user click on the view (outside the UITextField).
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toSelectTheCaptains"{
            let nextScrn = segue.destination as! CaptainsSelectViewController;
            nextScrn.setMsg(allPlayersDivideByPosition, position: position, allPlayersNames: allPlayersNames, groupName: groupNameStr!);
        }
    }
    
}

