import UIKit

class SelectPlayersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    fileprivate var allPlayersByPsition:[String:[String]]=[:]
    fileprivate var position:[String]=[]
    fileprivate var choosenCaptainsByPosition:[String:[String]]=[:]
    fileprivate var captainsName:[String]=[]
    fileprivate var numOfTeams:Int=2
    fileprivate var captainInPkr = "";
    
    fileprivate var firstTeam:[String:[String]]=[:]
    fileprivate var secondTeam:[String:[String]]=[:]
    fileprivate var thirdTeam:[String:[String]]=[:]
    fileprivate var fourthTeam:[String:[String]]=[:]
    fileprivate var colors = [UIColor.blue, UIColor.green, UIColor.orange, UIColor.brown]
    
    fileprivate var firstTeamNumOfPlayers:Int = 0;
    fileprivate var secondTeamNumOfPlayers:Int = 0;
    fileprivate var thirdTeamNumOfPlayers:Int = 0;
    fileprivate var fourthTeamNumOfPlayers:Int = 0;
    
    @IBOutlet var numOfPlayersLbl: UILabel!
    @IBOutlet var allPlayersTbl: UITableView!
    @IBOutlet var teamPlayersTbl: UITableView!
    @IBOutlet var captainsPkr: UIPickerView!
    @IBOutlet var finishBarBtn: UIBarButtonItem!
    
    fileprivate var groupNameStr: String!
    
    
    override func viewDidLoad() {
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
    }
    // Table View Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.position.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return tableView.headerRanDesigned(viewForHeaderInSection: section, position: position)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == allPlayersTbl{
            return allPlayersByPsition[position[section]]!.count
        }else{
            return playersNumInPosition()[position[section]]!.count;
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //Separate between allPlayersTbl and teamPlayersTbl ways of treatment
        if tableView == allPlayersTbl{
            return allPlayersTbl.cellRanDesigned(allPlayersByPsition, position: position, cellForRowAtIndexPath: indexPath) // from ExtensionUIView.swift
        }else{
            return teamPlayersTbl.cellRanDesigned(playersNumInPosition(), position: position, cellForRowAtIndexPath: indexPath) // from ExtensionUIView.swift
        }
    }
    // delegate method for tbls
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // user (captain) click on player name in allPlayerTbl the name deleted from tbl and added to captain tbl
        if tableView == allPlayersTbl{
            switch true {
            case captainInPkr==captainsName[0]:
                firstTeam[position[indexPath.section]]!.append(allPlayersByPsition[position[indexPath.section]]![indexPath.row])
                firstTeamNumOfPlayers = firstTeamNumOfPlayers + 1;
                numOfPlayersLbl.text = "Players: \(firstTeamNumOfPlayers)";
                break;
            case captainInPkr==captainsName[1]:
                secondTeam[position[indexPath.section]]!.append(allPlayersByPsition[position[indexPath.section]]![indexPath.row])
                secondTeamNumOfPlayers = secondTeamNumOfPlayers + 1;
                numOfPlayersLbl.text = "Players: \(secondTeamNumOfPlayers)";
                break;
            case captainInPkr==captainsName[2]:
                thirdTeam[position[indexPath.section]]!.append(allPlayersByPsition[position[indexPath.section]]![indexPath.row])
                thirdTeamNumOfPlayers = thirdTeamNumOfPlayers + 1;
                numOfPlayersLbl.text = "Players: \(thirdTeamNumOfPlayers)";
                break;
            default: // captainInPkr==captainsName[3]
                fourthTeam[position[indexPath.section]]!.append(allPlayersByPsition[position[indexPath.section]]![indexPath.row])
                fourthTeamNumOfPlayers = fourthTeamNumOfPlayers + 1;
                numOfPlayersLbl.text = "Players: \(fourthTeamNumOfPlayers)";
                break;
            }
            teamPlayersTbl.reloadData()
            allPlayersByPsition[position[indexPath.section]]!.remove(at: indexPath.row);
            //allPlayersTbl.reloadData();
            allPlayersTbl.deleteRows(at: [indexPath], with: UITableViewRowAnimation.fade)
            
            if (allPlayersByPsition.filter{teamName, teamMembers in !teamMembers.isEmpty}.isEmpty){
                finishBarBtn.isEnabled = true;
            }
            
        }else{
            
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        // user click Delete on cell of player in tbl -> player deleted and added back to allplayersTbl
        if tableView == teamPlayersTbl{
            if editingStyle == .delete{
                switch true {
                case captainInPkr==captainsName[0]:
                    allPlayersByPsition[position[indexPath.section]]!.append(firstTeam[position[indexPath.section]]![indexPath.row]);
                    firstTeam[position[indexPath.section]]!.remove(at: indexPath.row)
                    firstTeamNumOfPlayers = firstTeamNumOfPlayers - 1;
                    numOfPlayersLbl.text = "Players: \(firstTeamNumOfPlayers)";
                    break;
                case captainInPkr==captainsName[1]:
                    allPlayersByPsition[position[indexPath.section]]!.append(secondTeam[position[indexPath.section]]![indexPath.row]);
                    secondTeam[position[indexPath.section]]!.remove(at: indexPath.row)
                    secondTeamNumOfPlayers = secondTeamNumOfPlayers - 1;
                    numOfPlayersLbl.text = "Players: \(secondTeamNumOfPlayers)";
                    break;
                case captainInPkr==captainsName[2]:
                    allPlayersByPsition[position[indexPath.section]]!.append(thirdTeam[position[indexPath.section]]![indexPath.row]);
                    thirdTeam[position[indexPath.section]]!.remove(at: indexPath.row)
                    thirdTeamNumOfPlayers = thirdTeamNumOfPlayers - 1;
                    numOfPlayersLbl.text = "Players: \(thirdTeamNumOfPlayers)";
                    break;
                default: // captainInPkr==captainsName[3]
                    allPlayersByPsition[position[indexPath.section]]!.append(fourthTeam[position[indexPath.section]]![indexPath.row]);
                    fourthTeam[position[indexPath.section]]!.remove(at: indexPath.row)
                    fourthTeamNumOfPlayers = fourthTeamNumOfPlayers - 1;
                    numOfPlayersLbl.text = "Players: \(fourthTeamNumOfPlayers)";
                    break;
                }
                teamPlayersTbl.reloadData()
                allPlayersTbl.reloadData();
                finishBarBtn.isEnabled = false;
            }
        }
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
        teamPlayersTbl.reloadData();
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        return captainsPkr.pickerViewCellRanDesigned(viewForRow: row, reusingView: view, strArr: captainsName, makeTextColors: true)
        
    }
    
    func playersNumInPosition()->[String:[String]]{
        switch true {
        case captainInPkr==captainsName[0]:
            numOfPlayersLbl.text = "Players added: \(firstTeamNumOfPlayers)";
            return firstTeam
        case captainInPkr==captainsName[1]:
            numOfPlayersLbl.text = "Players added: \(secondTeamNumOfPlayers)";
            return secondTeam
        case captainInPkr==captainsName[2]:
            numOfPlayersLbl.text = "Players added: \(thirdTeamNumOfPlayers)";
            return thirdTeam
        default:
            numOfPlayersLbl.text = "Players added: \(fourthTeamNumOfPlayers)";
            return fourthTeam // captainsName[3]
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toPlayersOnField"{
            let nextScr = segue.destination as! PlayersOnFieldViewController
            nextScr.setMsg(self.firstTeam, secondTeam: self.secondTeam, thirdTeam: self.thirdTeam, fourthTeam: self.fourthTeam, captainsName: self.captainsName, position: self.position, choosenCaptainsByPosition: self.choosenCaptainsByPosition, groupName: self.groupNameStr!)
        }
    }
    
}
