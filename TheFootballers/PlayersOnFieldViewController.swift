import UIKit
import Firebase

class PlayersOnFieldViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var CFLbl: UILabel!
    @IBOutlet var SSLbl: UILabel!
    @IBOutlet var RWLbl: UILabel!
    @IBOutlet var LWLbl: UILabel!
    @IBOutlet var AMLbl: UILabel!
    @IBOutlet var CM1Lbl: UILabel!
    @IBOutlet var CM2Lbl: UILabel!
    @IBOutlet var RMLbl: UILabel!
    @IBOutlet var LMLbl: UILabel!
    @IBOutlet var DMLbl: UILabel!
    @IBOutlet var LWBLbl: UILabel!
    @IBOutlet var RWBLbl: UILabel!
    @IBOutlet var LBLbl: UILabel!
    @IBOutlet var CB1Lbl: UILabel!
    @IBOutlet var CB2Lbl: UILabel!
    @IBOutlet var RBLbl: UILabel!
    @IBOutlet var SWLbl: UILabel!
    @IBOutlet var GKLbl: UILabel!
    
    fileprivate var captainsName:[String]=[]
    fileprivate var choosenCaptainsByPosition:[String:[String]]=[:]
    fileprivate var firstTeam:[String:[String]]=[:]
    fileprivate var secondTeam:[String:[String]]=[:]
    fileprivate var thirdTeam:[String:[String]]=[:]
    fileprivate var fourthTeam:[String:[String]]=[:]
    fileprivate var position:[String]=[]
    fileprivate var currentPlayerChooseInRow:String = ""
    fileprivate var playersDeletedFromTbl:[String:[String]] = [:]
    
    fileprivate var firstTeamOnField:[String:String] = [:]
    fileprivate var secondTeamOnField:[String:String] = [:]
    fileprivate var thirdTeamOnField:[String:String] = [:]
    fileprivate var fourthTeamOnField:[String:String] = [:]
    
    fileprivate var currentTeamChoosen:[String:[String]] = [:]
    fileprivate var teamChoosen:String!
    
    fileprivate var colors = [UIColor.blue, UIColor(red: 0/255, green:153/255 ,blue:51/255 , alpha:1), UIColor.orange, UIColor.brown]
    
    @IBOutlet var firstTeamBtn: UIButton!
    @IBOutlet var secondTeamBtn: UIButton!
    @IBOutlet var thirdTeamBtn: UIButton!
    @IBOutlet var fourthTeamBtn: UIButton!
    @IBOutlet var tbl: UITableView!
    
    fileprivate var ref = FIRDatabase.database().reference()
    fileprivate var refGroup: FIRDatabaseReference!
    fileprivate var refPlayersByDivideToTeams: FIRDatabaseReference!
    
    fileprivate let allPossibleTeamsNameByNum = ["First", "Second", "Third", "Fourth"]
    
    fileprivate var groupNameStr:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("\(groupNameStr!) moved to PlayerOnFieldVC")
        
        refGroup = ref.child("Groups").child(groupNameStr)
        refPlayersByDivideToTeams = ref.child("Groups").child(groupNameStr).child("selection")
        
        //TODO: CREATE DIALOG THAT SAVE PLAYERS IN TEAM BY POSITION -> USER CAN VIEW THE CAPTAIN SELECTION FROM HOME PAGE
        let dialog = UIAlertController(title: "Save and allow to all group to see the selection players result?", message: "YES -> for save selection, NO -> stay with the previous players selection saved", preferredStyle: .alert);
        
        //Add Positive handler
        func okHandler(_ t:UIAlertAction){
            //Add to Firebase
            let teams = [firstTeam, secondTeam, thirdTeam, fourthTeam] //Objects: [String Position: [PlayersName]]
            var teamsName:[String] = []
            var teamsNameByNum = [String]()
            
            // Both index and value for every move in iteration
            for (index, captain) in captainsName.enumerated(){
                print("Index \(index): \(captain), team name: \(captainsName[index])-Team")
                //teamsName[index] = "\(captainsName[index])-Team"
                teamsName.append("\(captainsName[index])-Team")
                teamsNameByNum.append(self.allPossibleTeamsNameByNum[index])
                
            }
            
            // Both index and value for every move in iteration
            for (index, _) in teamsName.enumerated(){ // [firstTeam, secondTeam, thirdTeam, fourthTeam]
                //var teamIndex = 0
                refGroup.child("TeamsNameByCaptains").child("\(index+1)").setValue(teamsName[index])
                
                var playerNum = 1
                for pos in position{
                    for playerName in teams[index][pos]!{ // [pos String: [players Arr]]
                        refPlayersByDivideToTeams.child(teamsNameByNum[index]).child(pos).child("\(playerNum)").setValue(playerName)
                        print("team name: \(teamsNameByNum[index]), position: \(pos), player Number: \(playerNum), name: \(playerName)")
                        playerNum += 1
                    }
                }
            }
            
            // Both index and value for every move in iteration
            for (index, team) in teams.enumerated(){ // [firstTeam, secondTeam, thirdTeam, fourthTeam]
                var playerNum = 1
                for pos in position{
                    for playerName in team[pos]!{ // [pos String: [players Arr]]
                        refGroup.child("PlayersInTeams").child(teamsName[index]).child("\(playerNum)").setValue(playerName)
                        print("team name: \(teamsNameByNum[index]) , player Number: \(playerNum), name: \(playerName)")
                        playerNum += 1
                    }
                }
            }
            
        }
        dialog.addAction(UIAlertAction(title: "YES", style: .cancel, handler: okHandler));
        dialog.addAction(UIAlertAction(title: "NO", style: .default, handler: nil));
        present(dialog, animated: true, completion: nil);
        
        
        teamChoosen = "firstTeam"
        tbl.layer.cornerRadius = 10
        
        firstLoadingLabelsToAllTeamsOnField()
        addCaptainsToTheirTeamsByPositionAndShowButtons()
        //LBLbl.userInteractionEnabled = true <- I already done it for all labels in storyboard
        addGestureAndSelectorFuncToLabels()
        
        currentTeamPlayersByPositionOnTbl(firstTeam, teamIndex: 0)
        currentTeamOnFieldNames(firstTeamOnField)
        teamChoosen = "firstTeam"
    }
    
    func setMsg(_ firstTeam:[String:[String]], secondTeam:[String:[String]], thirdTeam:[String:[String]], fourthTeam:[String:[String]], captainsName:[String], position:[String], choosenCaptainsByPosition:[String:[String]], groupName:String){
        self.firstTeam = firstTeam
        self.secondTeam = secondTeam
        self.thirdTeam = thirdTeam
        self.fourthTeam = fourthTeam
        self.captainsName = captainsName
        self.position = position
        self.choosenCaptainsByPosition = choosenCaptainsByPosition
        self.currentTeamChoosen = firstTeam
        self.playersDeletedFromTbl = [position[0]:[], position[1]:[], position[2]:[], position[3]:[]]
        self.groupNameStr = groupName
    }
    
    var currentPositionTapped:String!
    
    //if user click on player in cell from tbl and then click/tap on label in field -> the position name will change to the name in cell picked.. if there is already a name in the label -> when user tap on it the name go back to tbl and at the label it will change to position name
    func lblTappedInPositionOnField(_ positionTapped:UILabel){
        let tempNameInLbl = positionTapped.text
        transferPositionTappedToStr(positionTapped)
        
        if currentPlayerChooseInRow != ""{ // if user clicked on player row in tbl
            if tempNameInLbl == currentPositionTapped{ //if the name in label clicked equal to position name
                if teamChoosen == "firstTeam"{
                    firstTeamOnField[currentPositionTapped] = self.currentPlayerChooseInRow
                    currentTeamOnFieldNames(firstTeamOnField)
                }else if teamChoosen == "secondTeam"{
                    secondTeamOnField[currentPositionTapped] = self.currentPlayerChooseInRow
                    currentTeamOnFieldNames(secondTeamOnField)
                }else if teamChoosen == "thirdTeam"{
                    thirdTeamOnField[currentPositionTapped] = self.currentPlayerChooseInRow
                    currentTeamOnFieldNames(thirdTeamOnField)
                }else{
                    fourthTeamOnField[currentPositionTapped] = self.currentPlayerChooseInRow
                    currentTeamOnFieldNames(fourthTeamOnField)
                }
                //The deleted player goes into playerDeletedFromTbl array
                deletePlayerFromTbl(currentPlayerChooseInRow)
                currentPlayerChooseInRow = ""
            }
        }
        
        if tempNameInLbl != currentPositionTapped{ //Move the player from Label and add him back to Tbl
            
            var tempPos = ""
            for pos in position{
                for player in playersDeletedFromTbl[pos]!{
                    if player == tempNameInLbl{
                        tempPos = pos
                    }
                }
            }
            
            if teamChoosen == "firstTeam"{
                firstTeamOnField[currentPositionTapped] = currentPositionTapped
                currentTeamOnFieldNames(firstTeamOnField)
                firstTeam[tempPos]?.append(tempNameInLbl!)
                currentTeamPlayersByPositionOnTbl(firstTeam, teamIndex: 0)
            }else if teamChoosen == "secondTeam"{
                secondTeamOnField[currentPositionTapped] = currentPositionTapped
                currentTeamOnFieldNames(secondTeamOnField)
                secondTeam[tempPos]?.append(tempNameInLbl!)
                currentTeamPlayersByPositionOnTbl(secondTeam, teamIndex: 1)
            }else if teamChoosen == "thirdTeam"{
                thirdTeamOnField[currentPositionTapped] = currentPositionTapped
                currentTeamOnFieldNames(thirdTeamOnField)
                thirdTeam[tempPos]?.append(tempNameInLbl!)
                currentTeamPlayersByPositionOnTbl(thirdTeam, teamIndex: 2)
            }else{
                fourthTeamOnField[currentPositionTapped] = currentPositionTapped
                currentTeamOnFieldNames(fourthTeamOnField)
                fourthTeam[tempPos]?.append(tempNameInLbl!)
                currentTeamPlayersByPositionOnTbl(fourthTeam, teamIndex: 3)
            }
            
            currentPlayerChooseInRow = ""
        }
    }
    
    func transferPositionTappedToStr(_ positionTapped:UILabel){
        var positionTappedToStr = [GKLbl:"GK", CB1Lbl:"CB1", CB2Lbl:"CB2", SWLbl:"SW", RBLbl:"RB", LBLbl:"LB",  RMLbl:"RM", LMLbl:"LM", DMLbl:"DM", CM1Lbl:"CM1", CM2Lbl:"CM2",AMLbl:"AM", RWLbl:"RW", LWLbl:"LW", SSLbl:"SS", CFLbl:"CF",  RWBLbl:"RWB", LWBLbl:"LWB"]
        currentPositionTapped = positionTappedToStr[positionTapped]
    }
    
    func deletePlayerFromTbl(_ currentPlayerInRow:String){
        var temp:[String:[String]] = [position[0]:[], position[1]:[], position[2]:[], position[3]:[]]
        for pos in position{
            for player in currentTeamChoosen[pos]!{
                if player != currentPlayerInRow{
                    temp[pos]?.append(player)
                }else{
                    playersDeletedFromTbl[pos]?.append(player)
                }
            }
        }
        if teamChoosen == "firstTeam"{
            firstTeam = temp
            currentTeamPlayersByPositionOnTbl(firstTeam, teamIndex: 0)
        }else if teamChoosen == "secondTeam"{
            secondTeam = temp
            currentTeamPlayersByPositionOnTbl(secondTeam, teamIndex: 1)
        }else if teamChoosen == "thirdTeam"{
            thirdTeam = temp
            currentTeamPlayersByPositionOnTbl(thirdTeam, teamIndex: 2)
        }else{
            fourthTeam = temp
            currentTeamPlayersByPositionOnTbl(fourthTeam, teamIndex: 3)
        }
    }
    //when user click on captain name button -> the players from his team updated in the labels on field
    func currentTeamOnFieldNames(_ currentTeam:[String:String]){
        CFLbl.text = currentTeam["CF"]
        SSLbl.text = currentTeam["SS"]
        RWLbl.text = currentTeam["RW"]
        LWLbl.text = currentTeam["LW"]
        AMLbl.text = currentTeam["AM"]
        LMLbl.text = currentTeam["LM"]
        RMLbl.text = currentTeam["RM"]
        CM1Lbl.text = currentTeam["CM1"]
        CM2Lbl.text = currentTeam["CM2"]
        DMLbl.text = currentTeam["DM"]
        RBLbl.text = currentTeam["RB"]
        LBLbl.text = currentTeam["LB"]
        SWLbl.text = currentTeam["SW"]
        CB1Lbl.text = currentTeam["CB1"]
        CB2Lbl.text = currentTeam["CB2"]
        GKLbl.text = currentTeam["GK"]
        RWBLbl.text = currentTeam["RWB"]
        LWBLbl.text = currentTeam["LWB"]
    }
    
    // when user click on captain name button -> the tbl updated with the players from his team
    func currentTeamPlayersByPositionOnTbl(_ teamChoosenArr:[String:[String]], teamIndex:Int){
        //let teamArrToTeamStr = [firstTeam:"firstTeam", secondTeam:"secondTeam", thirdTeam:"thirdTeam", fourthTeam:"fourthTeam"]
        let teamsArr = ["firstTeam", "secondTeam", "thirdTeam", "fourthTeam"]
        currentPlayerChooseInRow = ""
        currentTeamChoosen = teamChoosenArr
        teamChoosen = teamsArr[teamIndex]
        tbl.reloadData()
    }
    
    @IBAction func firstTeamShowBtn(_ sender: UIButton) {
        currentTeamPlayersByPositionOnTbl(firstTeam, teamIndex: 0)
        currentTeamOnFieldNames(firstTeamOnField)
    }
    
    
    @IBAction func secondTeamShow(_ sender: UIButton) {
        currentTeamPlayersByPositionOnTbl(secondTeam, teamIndex: 1)
        currentTeamOnFieldNames(secondTeamOnField)
    }
    
    @IBAction func thirdTeamShow(_ sender: UIButton) {
        currentTeamPlayersByPositionOnTbl(thirdTeam, teamIndex: 2)
        currentTeamOnFieldNames(thirdTeamOnField)
    }
    
    @IBAction func fourthTeamShow(_ sender: UIButton) {
        currentTeamPlayersByPositionOnTbl(fourthTeam, teamIndex: 3)
        currentTeamOnFieldNames(fourthTeamOnField)
    }
    
    // Table View Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.position.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return tableView.headerRanDesigned(viewForHeaderInSection: section, position: position)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.currentTeamChoosen[position[section]]!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.cellRanDesigned(currentTeamChoosen, position: position, cellForRowAtIndexPath: indexPath)
    }
    // delegate method for tbls
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.currentPlayerChooseInRow = self.currentTeamChoosen[position[indexPath.section]]![indexPath.row]
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
    }
    
    func firstLoadingLabelsToAllTeamsOnField(){
        let teamOnField:[String:String] = ["CF":"CF", "SS":"SS", "RW":"RW", "LW":"LW", "AM":"AM" , "CM1":"CM1", "CM2":"CM2" , "RM":"RM", "LM":"LM", "DM":"DM", "LWB":"LWB", "RWB":"RWB", "LB":"LB", "RB":"RB", "CB1":"CB1", "CB2":"CB2", "SW":"SW", "GK":"GK"]
        self.firstTeamOnField = teamOnField
        self.secondTeamOnField = teamOnField
        self.thirdTeamOnField = teamOnField
        self.fourthTeamOnField = teamOnField
    }
    
    func addCaptainsToTheirTeamsByPositionAndShowButtons(){
        for pos in position{
            for captain in choosenCaptainsByPosition[pos]!{
                
                if captain == captainsName[0]{
                    firstTeam[pos]?.append("\(captain) *C*")
                }
                if captain == captainsName[1]{
                    secondTeam[pos]?.append("\(captain) *C*")
                }
                if captainsName.count == 3{
                    if captain == captainsName[2]{
                        thirdTeam[pos]?.append("\(captain) *C*")
                    }
                }
                if captainsName.count == 4{
                    if captain == captainsName[2]{
                        thirdTeam[pos]?.append("\(captain) *C*")
                    }
                    if captain == captainsName[3]{
                        fourthTeam[pos]?.append("\(captain) *C*")
                    }
                }
            }
            
        }
        
        firstTeamBtn.buttonRanDesigned() //from ExtensionUIView.swift
        secondTeamBtn.buttonRanDesigned()
        thirdTeamBtn.buttonRanDesigned()
        fourthTeamBtn.buttonRanDesigned()
        
        firstTeamBtn.setTitle(captainsName[0], for: UIControlState())
        firstTeamBtn.setTitleColor(colors[0], for: UIControlState())
        secondTeamBtn.setTitle(captainsName[1], for: UIControlState())
        secondTeamBtn.setTitleColor(colors[1], for: UIControlState())
        
        switch captainsName.count {
        case 3:
            thirdTeamBtn.isHidden = false
            thirdTeamBtn.setTitle(captainsName[2], for: UIControlState())
            thirdTeamBtn.setTitleColor(colors[2], for: UIControlState())
        case 4:
            thirdTeamBtn.isHidden = false
            fourthTeamBtn.isHidden = false
            thirdTeamBtn.setTitle(captainsName[2], for: UIControlState())
            thirdTeamBtn.setTitleColor(colors[2], for: UIControlState())
            fourthTeamBtn.setTitle(captainsName[3], for: UIControlState())
            fourthTeamBtn.setTitleColor(colors[3], for: UIControlState())
        default:
            break
        }
    }
    
    func lblTappedGK(){
        lblTappedInPositionOnField(GKLbl)
    }
    func lblTappedRB(){
        lblTappedInPositionOnField(RBLbl)
    }
    func lblTappedCB1(){
        lblTappedInPositionOnField(CB1Lbl)
    }
    func lblTappedCB2(){
        lblTappedInPositionOnField(CB2Lbl)
    }
    func lblTappedSW(){
        lblTappedInPositionOnField(SWLbl)
    }
    func lblTappedLB(){
        lblTappedInPositionOnField(LBLbl)
    }
    func lblTappedRM(){
        lblTappedInPositionOnField(RMLbl)
    }
    func lblTappedLM(){
        lblTappedInPositionOnField(LMLbl)
    }
    func lblTappedDM(){
        lblTappedInPositionOnField(DMLbl)
    }
    func lblTappedCM1(){
        lblTappedInPositionOnField(CM1Lbl)
    }
    func lblTappedCM2(){
        lblTappedInPositionOnField(CM2Lbl)
    }
    func lblTappedAM(){
        lblTappedInPositionOnField(AMLbl)
    }
    func lblTappedRW(){
        lblTappedInPositionOnField(RWLbl)
    }
    func lblTappedLW(){
        lblTappedInPositionOnField(LWLbl)
    }
    func lblTappedSS(){
        lblTappedInPositionOnField(SSLbl)
    }
    func lblTappedCF(){
        lblTappedInPositionOnField(CFLbl)
    }
    func lblTappedLWB(){
        lblTappedInPositionOnField(LWBLbl)
    }
    func lblTappedRWB(){
        lblTappedInPositionOnField(RWBLbl)
    }
    
    func addGestureAndSelectorFuncToLabels(){
        let aSelectorGK : Selector = #selector(PlayersOnFieldViewController.lblTappedGK)
        let aSelectorRB : Selector = #selector(PlayersOnFieldViewController.lblTappedRB)
        let aSelectorCB1 : Selector = #selector(PlayersOnFieldViewController.lblTappedCB1)
        let aSelectorCB2 : Selector = #selector(PlayersOnFieldViewController.lblTappedCB2)
        let aSelectorSW : Selector = #selector(PlayersOnFieldViewController.lblTappedSW)
        let aSelectorLB : Selector = #selector(PlayersOnFieldViewController.lblTappedLB)
        let aSelectorRM : Selector = #selector(PlayersOnFieldViewController.lblTappedRM)
        let aSelectorLM : Selector = #selector(PlayersOnFieldViewController.lblTappedLM)
        let aSelectorDM : Selector = #selector(PlayersOnFieldViewController.lblTappedDM)
        let aSelectorCM1 : Selector = #selector(PlayersOnFieldViewController.lblTappedCM1)
        let aSelectorCM2 : Selector = #selector(PlayersOnFieldViewController.lblTappedCM2)
        let aSelectorAM : Selector = #selector(PlayersOnFieldViewController.lblTappedAM)
        let aSelectorRW : Selector = #selector(PlayersOnFieldViewController.lblTappedRW)
        let aSelectorLW : Selector = #selector(PlayersOnFieldViewController.lblTappedLW)
        let aSelectorSS : Selector = #selector(PlayersOnFieldViewController.lblTappedSS)
        let aSelectorCF : Selector = #selector(PlayersOnFieldViewController.lblTappedCF)
        let aSelectorLWB : Selector = #selector(PlayersOnFieldViewController.lblTappedLWB)
        let aSelectorRWB : Selector = #selector(PlayersOnFieldViewController.lblTappedRWB)
        
        let tapGestureGK = UITapGestureRecognizer(target: self, action: aSelectorGK)
        let tapGestureRB = UITapGestureRecognizer(target: self, action: aSelectorRB)
        let tapGestureCB1 = UITapGestureRecognizer(target: self, action: aSelectorCB1)
        let tapGestureCB2 = UITapGestureRecognizer(target: self, action: aSelectorCB2)
        let tapGestureSW = UITapGestureRecognizer(target: self, action: aSelectorSW)
        let tapGestureLB = UITapGestureRecognizer(target: self, action: aSelectorLB)
        let tapGestureRM = UITapGestureRecognizer(target: self, action: aSelectorRM)
        let tapGestureLM = UITapGestureRecognizer(target: self, action: aSelectorLM)
        let tapGestureDM = UITapGestureRecognizer(target: self, action: aSelectorDM)
        let tapGestureCM1 = UITapGestureRecognizer(target: self, action: aSelectorCM1)
        let tapGestureCM2 = UITapGestureRecognizer(target: self, action: aSelectorCM2)
        let tapGestureAM = UITapGestureRecognizer(target: self, action: aSelectorAM)
        let tapGestureRW = UITapGestureRecognizer(target: self, action: aSelectorRW)
        let tapGestureLW = UITapGestureRecognizer(target: self, action: aSelectorLW)
        let tapGestureSS = UITapGestureRecognizer(target: self, action: aSelectorSS)
        let tapGestureCF = UITapGestureRecognizer(target: self, action: aSelectorCF)
        let tapGestureLWB = UITapGestureRecognizer(target: self, action: aSelectorLWB)
        let tapGestureRWB = UITapGestureRecognizer(target: self, action: aSelectorRWB)
        
        GKLbl.addGestureRecognizer(tapGestureGK)
        RBLbl.addGestureRecognizer(tapGestureRB)
        CB1Lbl.addGestureRecognizer(tapGestureCB1)
        CB2Lbl.addGestureRecognizer(tapGestureCB2)
        SWLbl.addGestureRecognizer(tapGestureSW)
        LBLbl.addGestureRecognizer(tapGestureLB)
        RMLbl.addGestureRecognizer(tapGestureRM)
        LMLbl.addGestureRecognizer(tapGestureLM)
        DMLbl.addGestureRecognizer(tapGestureDM)
        CM1Lbl.addGestureRecognizer(tapGestureCM1)
        CM2Lbl.addGestureRecognizer(tapGestureCM2)
        AMLbl.addGestureRecognizer(tapGestureAM)
        RWLbl.addGestureRecognizer(tapGestureRW)
        LWLbl.addGestureRecognizer(tapGestureLW)
        SSLbl.addGestureRecognizer(tapGestureSS)
        CFLbl.addGestureRecognizer(tapGestureCF)
        LWBLbl.addGestureRecognizer(tapGestureLWB)
        RWBLbl.addGestureRecognizer(tapGestureRWB)
    }
    
}
