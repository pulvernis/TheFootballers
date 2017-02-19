//
//  GroupSelectionViewController.swift
//  TheFootballers
//
//  Created by Ran Pulvernis on 07/02/2017.
//  Copyright © 2017 RanPulvernis. All rights reserved.
//

import UIKit
import Firebase

class GroupSelectionViewController: UIViewController, UITableViewDataSource {
    
    @IBOutlet weak var tblPlayers: UITableView!
    
    @IBOutlet weak var firstTeamBtn: UIButton!
    @IBOutlet weak var secondTeamBtn: UIButton!
    @IBOutlet weak var thirdTeamBtn: UIButton!
    @IBOutlet weak var fourthTeamBtn: UIButton!
    
    @IBOutlet weak var lblTeamName: UILabel!
    @IBOutlet weak var lblWellcomeUser: UILabel!
    @IBOutlet var btnRefOrShow: UIButton!
    @IBOutlet weak var tblPlayersInPositionsInTeam: UITableView!
    
    fileprivate var groupNameForViewSelection:String!
    fileprivate var viewControllerInstance:UIViewController = UIViewController()
    fileprivate var user = FIRAuth.auth()?.currentUser
    
    fileprivate var ref = FIRDatabase.database().reference()
    fileprivate var refSelection: FIRDatabaseReference!
    fileprivate var refPlayersInTeams: FIRDatabaseReference!
    
    fileprivate let myGroupPlayers = DispatchGroup()
    fileprivate let myGroupTeams = DispatchGroup()
    
    fileprivate var nowItsShowInBtn:Bool = true
    
    fileprivate var currentTeamName:String = "emptyStr"
    fileprivate var currentTeamWithPlayers:[String] = []
    
    fileprivate var teamsNameArr = [String]()
    fileprivate var teamsArrWithPlayers: [[String]] = [] //[[playerStr, player2Str], [player3, player4]]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // show back button on navigationBar
        let backButton: UIBarButtonItem = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.plain, target: self, action: nil)
        navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
        
        self.navigationItem.title = groupNameForViewSelection
        
        tblPlayers.layer.cornerRadius = 10
        
        if(user!.displayName != nil){
            lblWellcomeUser.text = "Wellcome \(user!.displayName!)"
            print("\(user!.displayName!) in GroupSelectionVC")
        }else{
            lblWellcomeUser.text = "Wellcome \(user!.email!)"
            print("\(user!.email!) in GroupSelectionVC")
        }
        
        refSelection = ref.child("Groups").child(groupNameForViewSelection!).child("selection")
        refPlayersInTeams = ref.child("Groups").child(groupNameForViewSelection!).child("PlayersInTeams")
        
        currentTeamWithPlayers = [" "]
        getAllTeamsNameFromFirebaseToTeamsNameArr()
        getAllPlayersNameToTeamsFromFirebase()
        
    }
    
    func setMsg(groupName:String){
        self.groupNameForViewSelection = groupName
    }
    
    @IBAction func changesWithTeamsBtn(sender: UIButton) {
        switch sender {
        case firstTeamBtn:
            changesOnTeamBtnClicked(indexTeam: 0)
        case secondTeamBtn:
            changesOnTeamBtnClicked(indexTeam: 1)
        case thirdTeamBtn:
            changesOnTeamBtnClicked(indexTeam: 2)
        case fourthTeamBtn:
            changesOnTeamBtnClicked(indexTeam: 3)
        default:
            break
        }
    }
    
    @IBAction func btnRefreshOrShow(_ sender: UIButton) {
        if nowItsShowInBtn{  // when click on 'Present Selection' title in storyboard
            nowItsShowInBtn = false
            btnRefOrShow.setTitle("Refresh", for: .normal)
            lblTeamName.text = teamsNameArr[0]
            currentTeamName = teamsNameArr[0]
            currentTeamWithPlayers = teamsArrWithPlayers[0]
            
            print("teamsArrWithPlayers[0][0]: \(teamsArrWithPlayers[0][0])")
            
            firstTeamBtn.isHidden = false
            secondTeamBtn.isHidden = false
            
            switch teamsNameArr.count {
            case 3:
                thirdTeamBtn.isHidden = false
                
            case 4:
                thirdTeamBtn.isHidden = false
                fourthTeamBtn.isHidden = false
                
            default:
                break
            }
            
            tblPlayers.isHidden = false
            tblPlayers.reloadData()

        }else{  // when click on 'Refresh' title in storyboard
            nowItsShowInBtn = true
            getAllTeamsNameFromFirebaseToTeamsNameArr()
            getAllPlayersNameToTeamsFromFirebase()
            btnRefOrShow.setTitle("Present Selection", for: .normal)
            hideAllTeamsButtons()
        }
    }
    
    // Methods for TableView
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if currentTeamName != "emptyStr" {
            let numOfRows = self.currentTeamWithPlayers.count
            return numOfRows
        }else{
            return 1
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let playerNameInCell = self.currentTeamWithPlayers[indexPath.row]
        //let cell = UITableViewCell();
        //cell.textLabel!.text = playerNameInCell
        //return cell
        return tblPlayers.cellDecoration(currentTeamWithPlayers, cellForRowAtIndexPath: indexPath)
    }
    
    private func getAllTeamsNameFromFirebaseToTeamsNameArr(){
        
        var tempTeamsNameArr = [String]()
        
        self.myGroupPlayers.enter()
        refPlayersInTeams.observeSingleEvent(of: .value, with: { (snapshot) in
            // get teams name
            for (teamIndex, team) in snapshot.children.enumerated() {
                let teamName = (team as AnyObject).key!
                tempTeamsNameArr.append(teamName)
                print("teamName \(teamIndex): \(teamName)")
                
            }
            
            self.myGroupPlayers.leave()
            
            self.myGroupPlayers.notify(queue: DispatchQueue.main, execute: {
                print("tempTeamsNameArr: \(tempTeamsNameArr)")
                self.teamsNameArr = tempTeamsNameArr
            })
            
        })
        
    }
    
    private func getAllPlayersNameToTeamsFromFirebase() {
        
        let tempFirstTeam = [String]()
        let tempSecondTeam = [String]()
        let tempThirdTeam = [String]()
        let tempFourthTeam = [String]()
        
        var tempTeamArrWithPlayers = [tempFirstTeam, tempSecondTeam, tempThirdTeam, tempFourthTeam]
        
        refPlayersInTeams.observeSingleEvent(of: .value, with: { (snapshot) in
            for (teamIndex, team) in snapshot.children.enumerated(){
                self.myGroupTeams.enter()
                self.refPlayersInTeams.child((team as AnyObject).key).observeSingleEvent(of: .value, with: { (snapshot) in
                    // get into players in team
                    for player in snapshot.children {
                        tempTeamArrWithPlayers[teamIndex].append((player as AnyObject).value)
                    }
                
                    self.myGroupTeams.leave()
                
                    self.myGroupTeams.notify(queue: DispatchQueue.main, execute: {
                        self.teamsArrWithPlayers = tempTeamArrWithPlayers
                    })
                
                })
            
            }
            
        })
        
    }
    // This func isn't in use -> it's iterate data from firebase: teams->positions->players
    //In future try to present players in tbl section of position
    private func iterationInFirebase(){
    
        refSelection.observeSingleEvent(of: .value, with: { (snapshot) in
            // get into teams
            for team in snapshot.children {
                self.refSelection.child((team as AnyObject).key).observeSingleEvent(of: .value, with: { (snapshot) in
                    // get into positions
                    for position in snapshot.children {
                        self.refSelection.child((team as AnyObject).key).child((position as AnyObject).key).observeSingleEvent(of: .value, with: { (snapshot) in
                            // get into players
                            for player in snapshot.children {
                                //GET PALYER TO POSITION IN HIS TEAM
                                print("Form Each Player Iterate And Print\((player as AnyObject).key!):\(((player as AnyObject).value) as String)")
                            }
    
                        })
                    }
                })
            }
    
        })
    
    }
    
    private func changesOnTeamBtnClicked(indexTeam:Int){
        lblTeamName.text = teamsNameArr[indexTeam]
        currentTeamName = teamsNameArr[indexTeam]
        currentTeamWithPlayers = teamsArrWithPlayers[indexTeam]
        tblPlayers.reloadData()
    }
    
    private func hideAllTeamsButtons(){
        firstTeamBtn.isHidden = true
        secondTeamBtn.isHidden = true
        thirdTeamBtn.isHidden = true
        fourthTeamBtn.isHidden = true
        tblPlayers.isHidden = true
    }
    

}




