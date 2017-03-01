import UIKit

class SelectPlayersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    // initial from setMsg (before viewDidLoad):
    fileprivate var allPlayersByPsition:[String:[String]]!
    fileprivate var position:[String]!
    fileprivate var choosenCaptainsByPosition:[String:[String]]!
    fileprivate var captainsName:[String]!
    fileprivate var numOfTeams:Int!
    fileprivate var captainInPkr:String!
    
    fileprivate var firstTeam:[String:[String]]!
    fileprivate var secondTeam:[String:[String]]!
    fileprivate var thirdTeam:[String:[String]]!
    fileprivate var fourthTeam:[String:[String]]!
    
    fileprivate var groupNameStr: String!
    
    // initial with 0 -> first captain Index
    fileprivate var captainInPkrIndex:Int = 0
    // initial with 0 -> Teams doesn't had players when start
    fileprivate var firstTeamNumOfPlayers:Int = 0;
    fileprivate var secondTeamNumOfPlayers:Int = 0;
    fileprivate var thirdTeamNumOfPlayers:Int = 0;
    fileprivate var fourthTeamNumOfPlayers:Int = 0;
    // initial from viewDidLoad:
    fileprivate var teamsObjArr:[[String:[String]]] = [] // [firstTeam, secondTeam, ...]
    fileprivate var teamsWithNumOfPlayersArr:[Int] = []
    fileprivate var captainInPkrGiveIndex:[String:Int] = [:]
    
    @IBOutlet var numOfPlayersLbl: UILabel!
    @IBOutlet var allPlayersTbl: UITableView!
    @IBOutlet var teamPlayersTbl: UITableView!
    @IBOutlet var captainsPkr: UIPickerView!
    @IBOutlet var finishBarBtn: UIBarButtonItem!
    
    override func viewDidLoad() {
        
        teamsObjArr.append(firstTeam)
        teamsWithNumOfPlayersArr.append(firstTeamNumOfPlayers)
        teamsObjArr.append(secondTeam)
        teamsWithNumOfPlayersArr.append(secondTeamNumOfPlayers)
        teamsObjArr.append(thirdTeam)
        teamsWithNumOfPlayersArr.append(thirdTeamNumOfPlayers)
        teamsObjArr.append(fourthTeam)
        teamsWithNumOfPlayersArr.append(fourthTeamNumOfPlayers)
        
        teamPlayersTbl.isEditing = true;
        finishBarBtn.isEnabled = false;
        
        self.view.addBackground("grasspng.png")
        
        allPlayersTbl.layer.cornerRadius = 10
        teamPlayersTbl.layer.cornerRadius = 10
        captainsPkr.layer.cornerRadius = 5
        captainsPkr.layer.borderColor = UIColor(red: 160/255, green: 90/255, blue: 40/255, alpha: 1).cgColor
        captainsPkr.layer.borderWidth = 4
        captainsPkr.backgroundColor = UIColor(red: 229/255, green: 255/255, blue: 255/255, alpha: 1)
    }
    
    func setMsg(_ allPlayersByPosition:[String:[String]], position:[String], choosenCaptainsByPosition:[String:[String]], numOfTeams:Int, captainsName:[String], groupName:String){
        self.allPlayersByPsition = allPlayersByPosition
        self.position = position
        self.choosenCaptainsByPosition = choosenCaptainsByPosition
        self.numOfTeams = numOfTeams
        self.captainsName = captainsName
        self.captainInPkr = captainsName[0];
        self.firstTeam = [position[0]:[], position[1]:[], position[2]:[], position[3]:[]]
        self.secondTeam = [position[0]:[], position[1]:[], position[2]:[], position[3]:[]]
        self.thirdTeam = [position[0]:[], position[1]:[], position[2]:[], position[3]:[]]
        self.fourthTeam = [position[0]:[], position[1]:[], position[2]:[], position[3]:[]]
        self.groupNameStr = groupName
        
        for (captainIndex, captainNameStr) in captainsName.enumerated(){
            self.captainInPkrGiveIndex[captainNameStr] = captainIndex
        }
    }
    // Table View Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.position.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return tableView.headerRanDesigned(viewForHeaderInSection: section, position: position)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == allPlayersTbl{
            return allPlayersByPsition[position[section]]!.count
        }else{
            return /*playersNumInPosition()*/teamsObjArr[self.captainInPkrIndex][position[section]]!.count;
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //Separate between allPlayersTbl and teamPlayersTbl ways of treatment
        if tableView == allPlayersTbl{
            return allPlayersTbl.cellRanDesigned(allPlayersByPsition, position: position, cellForRowAtIndexPath: indexPath) // from ExtensionUIView.swift
        }else{
            return teamPlayersTbl.cellRanDesigned(teamsObjArr[self.captainInPkrIndex] /*playersNumInPosition()*/, position: position, cellForRowAtIndexPath: indexPath) // from ExtensionUIView.swift
        }
    }
    // delegate method for tbls
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // user (captain) click on player, the name deleted from tbl and added to captain tbl
        if tableView == allPlayersTbl{
            addPlayerToTeam(posIndex: indexPath.section, playerIndexInPos: indexPath.row)
            teamPlayersTbl.reloadData()
            allPlayersByPsition[position[indexPath.section]]!.remove(at: indexPath.row);
            allPlayersTbl.deleteRows(at: [indexPath], with: UITableViewRowAnimation.fade)
            
            //if there is no more players to to transfer to teams then user can move forward
            if (allPlayersByPsition.filter{teamName, teamMembers in !teamMembers.isEmpty}.isEmpty){
                finishBarBtn.isEnabled = true;
            }else{
                finishBarBtn.isEnabled = false;
            }
          }
        
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        // user click Delete on cell of player in tbl -> player deleted and added back to allplayersTbl
        if tableView == teamPlayersTbl{
            if editingStyle == .delete{
                deletePlayerFromTeam(posIndex: indexPath.section, playerIndexInPos: indexPath.row)
                teamPlayersTbl.reloadData()
                allPlayersTbl.reloadData();
                finishBarBtn.isEnabled = false;
            }
        }
    }
    // when user (captain) click on player, player will be added to captain table
    private func addPlayerToTeam(posIndex: Int, playerIndexInPos: Int){
        teamsObjArr[self.captainInPkrIndex][position[posIndex]]!.append(allPlayersByPsition[position[posIndex]]![playerIndexInPos])
        teamsWithNumOfPlayersArr[captainInPkrIndex] += 1
        numOfPlayersLbl.text = "Players: \(teamsWithNumOfPlayersArr[captainInPkrIndex])";
    }
    // when user (captain) delete player, player will be deleted and move to allPlayers table
    private func deletePlayerFromTeam(posIndex: Int, playerIndexInPos: Int){
        allPlayersByPsition[position[posIndex]]!.append(teamsObjArr[self.captainInPkrIndex][position[posIndex]]![playerIndexInPos])
        teamsObjArr[self.captainInPkrIndex][position[posIndex]]!.remove(at: playerIndexInPos)
        teamsWithNumOfPlayersArr[captainInPkrIndex] -= 1
        numOfPlayersLbl.text = "Players: \(teamsWithNumOfPlayersArr[captainInPkrIndex])";
    }
    // Picker View Methods
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return numOfTeams
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print(captainsName[row]);
        // user roll to other captain name -> the name saved in captainInPkr(String) and teamPlayerTbl reload the data of the captain that choosen in pkr by the func called playerNumInPosition
        self.captainInPkr=captainsName[row]
        self.captainInPkrIndex = self.captainInPkrGiveIndex[self.captainInPkr]!
        teamPlayersTbl.reloadData();
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        return captainsPkr.pickerViewCellRanDesigned(viewForRow: row, reusingView: view, strArr: captainsName, makeTextColors: true)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toPlayersOnField"{
            let nextScr = segue.destination as! PlayersOnFieldViewController
            nextScr.setMsg(teamsObjArr: self.teamsObjArr, captainsName: self.captainsName, position: self.position, choosenCaptainsByPosition: self.choosenCaptainsByPosition, groupName: self.groupNameStr!)
        }
    }
    
}
