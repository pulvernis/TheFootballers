
import UIKit
import Firebase
// make array of obj instead string - make struct player with var txt and var selection \u{2610} and \u{2612}
// in cell will be name (var txt) with checkbox inside (var selection)
class AddAllPlayersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate  {
    
    fileprivate var position:[String]=[]; //Attack, MidFielder, Defence, GoalKeeper -> initialize from viewDidLoad
    fileprivate var allPlayersDivideByPosition:[String:[String]]=["Attack":[], "Midfielder":[], "Defence":[], "Goalkeeper":[]];
    fileprivate var allPlayersNames:[String]=[];
    fileprivate let prefs = UserDefaults.standard;
    
    fileprivate var playerPositionInPickerView:String = "Attack"; // Attack is the default in pickerView
    fileprivate var rowNameSelectedFromTableView:String = ""; // change to player name when user click on row in tableView
    fileprivate var rowNumberSelectedFromTableView:Int = 0;
    fileprivate var pos:String = ""; // change to the position of player when user click on row in -> tableView <-
    //private var playerNameSelected:String = "";
    
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
        
        print()
        if(groupNameStr != nil){
            print("\(groupNameStr!) String has moved to AddAllPlayersVC")
        }else{
            print("group name doesn't pass to this AddAllPlayersVC")
        }
        
        containerViewUp.layer.cornerRadius = 10
        containerViewDown.layer.cornerRadius = 10
        tblAllPlayers.layer.cornerRadius = 10
        
        // background image for view
        self.view.addBackground("grasspng.png")// <- from ExtensionUIView.swift
        
        position = ["Attack", "Midfielder", "Defence", "Goalkeeper"];
        //allPlayersDivideByPosition = [position[0]:[], position[1]:[], position[2]:[], position[3]:[]];
        
        // check if in user storage (in UserDefaults) uploaded enough player to countinue
        if allPlayersNames.count < MIN_PLAYERS_REQUIRED{
            nextBarBtn.isEnabled = false; //move to next screen by nextBatBtn initialized with false (not possible) until user add at least 2 players
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
        // Alert if user try to add player when TextField is empty
        if nameInsert == "" {
            //build in Alert Dialog with UIAlertController object
            let dialog = UIAlertController(title: "Player Name Is Empty", message: "Please, insert the player name...", preferredStyle: .alert);
            //add default button to dialog
            let btnAction=UIAlertAction(title: "OK", style: .cancel, handler: nil);
            dialog.addAction(btnAction);
            //show the dialog
            present(dialog, animated: true, completion: nil);
            return;
        }
        // Alert if user try to add long name of player
        if nameInsert.characters.count > MAX_SIZE_PLAYER_NAME{
            let dialog = UIAlertController(title: "Player Name Is Too Long", message: "Please, insert  10 letters max...", preferredStyle: .alert);
            let btnAction=UIAlertAction(title: "OK", style: .cancel, handler: nil);
            dialog.addAction(btnAction);
            present(dialog, animated: true, completion: nil);
            return;
        }
        // Alert if user try to add an existing player
        for player in allPlayersNames{
            if nameInsert == player{
                let dialog = UIAlertController(title: "\(player) already exist", message: nil, preferredStyle: .alert);
                let btnAction=UIAlertAction(title: "OK", style: .cancel, handler: nil);
                dialog.addAction(btnAction);
                present(dialog, animated: true, completion: nil);
                return;
            }
        }
        
        reloadTblAllPlayers(nameInsert, playerPositionInPickerView : playerPositionInPickerView);
        insertPlayerName.text = "";
        
        // check if user insert enough player to countinue
        if allPlayersNames.count >= MIN_PLAYERS_REQUIRED{//22{
            nextBarBtn.isEnabled = true;
        }
        
    }
    
    @IBAction func deletePlayerBtn(_ sender: UIButton) {
        if allPlayersNames.count == 0{
            //build in Alert Dialog with UIAlertController object
            let dialog = UIAlertController(title: "Table of Players Is Empty", message: "there is nothing to delete...", preferredStyle: .alert);
            //add default button to dialog
            let btnAction=UIAlertAction(title: "OK", style: .cancel, handler: nil);
            dialog.addAction(btnAction);
            //show the dialog
            present(dialog, animated: true, completion: nil);
            return;
        }
        if rowNameSelectedFromTableView == ""{
            var allPlayerDivideTemp:[String:[String]] = [position[0]:[], position[1]:[], position[2]:[], position[3]:[]];
            for posa in self.position{
                for name in self.allPlayersDivideByPosition[posa]!{
                    if name != self.allPlayersNames[allPlayersNames.count-1]{
                        allPlayerDivideTemp[posa]!.append(name);
                    }
                }
            }
            self.allPlayersDivideByPosition = allPlayerDivideTemp;
            
            self.allPlayersNames.removeLast();
            
            self.playerPositionLabel.text = "player position";
            
            //return;
        }else{
            var allPlayerDivideTemp:[String:[String]] = [position[0]:[], position[1]:[], position[2]:[], position[3]:[]];
            for posa in self.position{
                for name in self.allPlayersDivideByPosition[posa]!{
                    if name != self.rowNameSelectedFromTableView{
                        allPlayerDivideTemp[posa]!.append(name);
                    }
                }
            }
            self.allPlayersDivideByPosition = allPlayerDivideTemp;
            
            allPlayersNames.remove(at: self.rowNumberSelectedFromTableView);
            self.playerPositionLabel.text = "player position";
            self.rowNameSelectedFromTableView = "";
            self.rowNumberSelectedFromTableView = allPlayersNames.count-1;
        }
        // check if user when user delete player there is less than min player required for countinue
        if allPlayersNames.count < MIN_PLAYERS_REQUIRED{//22{
            nextBarBtn.isEnabled = false;
        }
        reloadTblAllPlayers();
        
    }
    
    @IBAction func deleteAllPlayersBtn(_ sender: UIButton) {
        if allPlayersNames.count == 0{
            //build in Alert Dialog with UIAlertController object
            let dialog = UIAlertController(title: "Table of Players Is Empty", message: "there is nothing to delete...", preferredStyle: .alert);
            //add default button to dialog
            let btnAction=UIAlertAction(title: "OK", style: .cancel, handler: nil);
            dialog.addAction(btnAction);
            //show the dialog
            present(dialog, animated: true, completion: nil);
            
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
        let dialog = UIAlertController(title: "Adding and deleting players", message: "From left side screen Top to Bottom:\nFor adding player:\nInsert player name in the white box, then down below choose the player position. for adding press on add Player button\nFor Deleting Player:\nChoose player from the Players Added table, then press on Delete Player button\nIf you don't choose player from table and you pressed on the Delete Player button, the last player who was added to the table will be deleted", preferredStyle: .alert);
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
            //Add to userDefault <- moved to next VC with UIAlert (option for user to save or not)
            //prefs.setValue(self.allPlayersDivideByPosition, forKey: "allPlayersDivideByPosition")
            //prefs.setValue(self.allPlayersNames, forKey: "allPlayersNames")
        }
    }
    
    
    
    
}

