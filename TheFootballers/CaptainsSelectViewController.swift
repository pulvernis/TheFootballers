import UIKit

class CaptainsSelectViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    fileprivate var allPlayersByPosition:[String:[String]] = [:]
    fileprivate var allPlayersNames:[String] = []
    fileprivate var position:[String] = [];
    fileprivate var numOfTeamsInSlider:Int=2 // <- default in slider is 2
    fileprivate var choosenCaptains:[String]=[]
    fileprivate var choosenCaptainsByPosition:[String:[String]]=[:]
    
    @IBOutlet var allPlayersTbl: UITableView!
    @IBOutlet var teamsNumTitle: UILabel!
    @IBOutlet var teamsNumSlider: UISlider!
    @IBOutlet var teamsNumLabel: UILabel!
    @IBOutlet var teamsNumTitleChange: UILabel!
    @IBOutlet var selectCaptainsLabel: UILabel!
    @IBOutlet var confirmNumTeamsBtn: UIButton!
    @IBOutlet var nextBarBtn: UIBarButtonItem!
    
    
    fileprivate var lastY:CGFloat!;
    fileprivate var colors = [UIColor.blue, UIColor.green, UIColor.orange, UIColor.brown]
    fileprivate var numInColorsArray = 0
    fileprivate let prefs = UserDefaults.standard;
    
    fileprivate var groupNameStr: String?
    
    override func viewDidLoad() {
        
        allPlayersTbl.allowsSelection = false
        
        let rotationTransform = CATransform3DTranslate(CATransform3DIdentity, 120, 40, 0)
        UIView.animate(withDuration: 1.5, animations: {() -> Void in
            self.allPlayersTbl.layer.transform = rotationTransform
        })
        
        // width and height for imageViewBackground:
        let width = view.frame.width*0.2
        let height = view.frame.height*0.2
        
        let imageViewBackground = UIImageView(frame: CGRect(x: view.frame.width*0.7, y: view.frame.height*0.6, width: width, height: height))
        imageViewBackground.image = UIImage(named: "capitan.png")
        
        // you can change the content mode:
        imageViewBackground.contentMode = UIViewContentMode.scaleAspectFill
        
        self.view.addSubview(imageViewBackground)
        self.view.sendSubview(toBack: imageViewBackground)
        
        allPlayersTbl.layer.cornerRadius = 10
        
        lastY = view.frame.size.height*0.3;//starting height position for first label of captain name
        nextBarBtn.isEnabled = false;
        
        if(prefs.value(forKey: "allPlayersNames") != nil){
            let allPlayersNamesPreviousSave = prefs.value(forKey: "allPlayersNames")! as! [String]
            //UIAlert - ask user if he want to save the new added players in NSUserDefaults or stay with the previous players
            if allPlayersNames != allPlayersNamesPreviousSave{ // <- show alert only if there is changes in adding players
                let dialog = UIAlertController(title: "Save the added players for next time?", message: "YES -> for saving, NO -> stay with the previous players saved", preferredStyle: .alert);
                
                //Add Positive handler
                func okHandler(_ t:UIAlertAction){
                    //Add to userDefault
                    prefs.setValue(allPlayersByPosition, forKey: "allPlayersDivideByPosition")
                    prefs.setValue(self.allPlayersNames, forKey: "allPlayersNames")
                    
                }
                dialog.addAction(UIAlertAction(title: "YES", style: .cancel, handler: okHandler));
                dialog.addAction(UIAlertAction(title: "NO", style: .default, handler: nil));
                present(dialog, animated: true, completion: nil);
            }
        }
        
    }
    
    func setMsg(_ allPlayersByPosition:[String:[String]], position:[String], allPlayersNames:[String], groupName:String){
        // initialiaze variables by allPlayersDivideByPosition array and position array from class AddAllPlayersViewController
        self.allPlayersByPosition = allPlayersByPosition;
        self.position = position;
        self.choosenCaptainsByPosition = [position[0]:[], position[1]:[], position[2]:[], position[3]:[]]
        self.allPlayersNames = allPlayersNames
        self.groupNameStr = groupName
    }
    
    // show number of teams from slider to label
    @IBAction func teamsNumChangerSlider(_ sender: UISlider) {
        self.numOfTeamsInSlider = Int(sender.value);
        teamsNumLabel.text = "\(numOfTeamsInSlider)";
        //teamsNumLabel.text = String(stringInterpolationSegment: numOfTeamsInSlider) <- second option
    }
    
    @IBAction func teamsNumConfirmBtn(_ sender: UIButton) {
        teamsNumSlider.isHidden = true;
        teamsNumLabel.isHidden = true;
        teamsNumTitle.isHidden = true;
        confirmNumTeamsBtn.isHidden = true;
        allPlayersTbl.allowsSelection = true
        teamsNumTitleChange.isHidden = false;
        teamsNumTitleChange.text = "\(numOfTeamsInSlider) Teams";
        teamsNumTitleChange.textColor = UIColor.brown;
        selectCaptainsLabel.isHidden = false;
    }
    
    //methods for data in tableView:
    //how many sub-lists
    func numberOfSections(in tableView: UITableView) -> Int {
        return position.count;
    }
    
    //every section has header
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return tableView.headerRanDesigned(viewForHeaderInSection: section, position: position)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    //how many rows in each sub list
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allPlayersByPosition[position[section]]!.count;
    }
    //what will each row view show
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) ->    UITableViewCell {
        return allPlayersTbl.cellRanDesigned(allPlayersByPosition, position: position, cellForRowAtIndexPath: indexPath) // from ExtensionUIView.swift
    }
    
    //when user select item
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if choosenCaptains.count<numOfTeamsInSlider{
            //add selected captain in row from table to choosenCaptains array
            choosenCaptains.append(allPlayersByPosition[position[indexPath.section]]![indexPath.row]);
            //create labels with captains as numberOfTeamsInSlider
            var ttl:UILabel;
            let point = CGPoint(x: tableView.frame.size.width, y: lastY)
            let size = CGSize(width: tableView.frame.size.width*0.9, height: view.frame.size.height*0.05)
            let rect = CGRect(origin: point, size: size)
            ttl = UILabel(frame: rect)
            ttl.text = allPlayersByPosition[position[indexPath.section]]![indexPath.row];
            ttl.textAlignment = .center;
            ttl.textColor = colors[numInColorsArray];
            ttl.font = UIFont(name: "Futura", size: 15)
            view.addSubview(ttl);
            self.lastY=lastY+ttl.frame.size.height*1.2; //lastY grow
            self.numInColorsArray += 1;
            
            //delete choosen captains from array and from tableView and add him to choosenCaptainsByPosition Array
            var playersTemp:[String:[String]] = [position[0]:[], position[1]:[], position[2]:[], position[3]:[]];
            for p in position{
                for player in allPlayersByPosition[p]!{
                    if player != allPlayersByPosition[position[indexPath.section]]![indexPath.row]{
                        playersTemp[p]?.append(player);
                    }else{
                        choosenCaptainsByPosition[p]?.append(player);
                    }
                }
            }
            self.allPlayersByPosition = playersTemp;
            tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.fade)
        }
        //Add confirm button when user choose all captains .. show proceed button
        if choosenCaptains.count == numOfTeamsInSlider{
            nextBarBtn.isEnabled = true;
        }
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        
    }
    
    @IBAction func infoBtn(_ sender: UIButton) {
        //build in Alert Dialog with UIAlertController object
        let dialog = UIAlertController(title: "Choose Captains", message: "First.. choose by the slider the number of teams participate and press confirm\nNow the players table is clickable,\nChoose player and he will remove from table to the right side (under the Captain Selected title)/n after selecting number of captains as number of teams participate, 'Next' button, on the top right screen, will became blue.. press it to move on", preferredStyle: .alert);
        //add default button to dialog
        let btnAction=UIAlertAction(title: "OK", style: .cancel, handler: nil);
        dialog.addAction(btnAction);
        //show the dialog
        present(dialog, animated: true, completion: nil);
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toSelectPlayers"{
            let nextScr = segue.destination as! SelectPlayersViewController
            nextScr.setMsg(self.allPlayersByPosition, position: self.position, choosenCaptainsByPosition: self.choosenCaptainsByPosition, numOfTeams: self.numOfTeamsInSlider, captainsName: self.choosenCaptains, groupName: groupNameStr!);
        }
    }
    
}
