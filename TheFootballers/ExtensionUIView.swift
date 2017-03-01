//
//  ExtensionUIView.swift
//  TheFootballers
//
//  Created by Ran Pulvernis on 23/08/2016.
//  Copyright © 2016 RanPulvernis. All rights reserved.
//

import UIKit

extension UIView {
    func addBackground(_ name:String) {
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.image = UIImage(named: name)
        self.insertSubview(backgroundImage, at: 0)
    }
    
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false // <- make touches event in view available (such as rows in tbl, buttons and etc)
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension UITableView{
    func cellDecoration(_ playersArr:[String], cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell{
        let cell = UITableViewCell();
        cell.textLabel!.text = playersArr[indexPath.row];
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.font = UIFont(name: "Futura", size: 15)
        if(indexPath.row % 2 == 0){
            cell.backgroundColor = UIColor(red: 153/255, green: 102/255, blue: 0/255, alpha: 1)
            cell.textLabel?.textColor = UIColor(red: 255/255, green: 255/255, blue: 204/255, alpha: 1)
        }else{
            cell.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 204/255, alpha: 1)
            cell.textLabel?.textColor = UIColor(red: 153/255, green: 102/255, blue: 0/255, alpha: 1)
        }
        
        return cell;
    }
    //overload method
    func cellRanDesigned(_ playersArr:[String:[String]], position:[String], cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell{
        let cell = UITableViewCell();
        cell.textLabel!.text = playersArr[position[indexPath.section]]![indexPath.row];
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.font = UIFont(name: "Futura", size: 15)
        cell.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 204/255, alpha: 1)
        cell.textLabel?.textColor = UIColor(red: 153/255, green: 102/255, blue: 0/255, alpha: 1)
        return cell;
    }
    func headerRanDesigned(viewForHeaderInSection section: Int, position:[String]) -> UIView? {
        let title = UILabel()
        
        title.text = position[section]
        title.textAlignment = .center
        title.textColor = UIColor(red: 0.0, green: 0.54, blue: 0.0, alpha: 0.8)
        title.backgroundColor = UIColor(red: 153/255, green: 153/255, blue: 255/255, alpha: 0.5)
        title.font = UIFont.boldSystemFont(ofSize: 15)
        
        return title
    }
}
extension UIPickerView{
    func pickerViewCellRanDesigned(viewForRow row: Int, reusingView view: UIView?, strArr:[String], makeTextColors:Bool) -> UIView {
        
        var label = view as! UILabel!
        if label == nil {
            label = UILabel()
        }
        
        let data = strArr[row]
        let title = NSAttributedString(string: data, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 16.0, weight: UIFontWeightRegular)])
        
        label?.attributedText = title
        label?.textAlignment = .center
        
        if makeTextColors == true{
            var colors = [UIColor.blue, UIColor.green, UIColor.orange, UIColor.brown]
            label?.textColor = colors[row]
        }else{
            label?.textColor = UIColor(red: 180/255, green: 45/255, blue: 45/255, alpha: 1)
        }
        
        label?.layer.borderColor = UIColor(red: 55/255, green: 75/255, blue: 105/255, alpha:1).cgColor
        label?.layer.borderWidth = 2
        label?.layer.backgroundColor = UIColor(red: 229/255, green: 242/255, blue: 255/255, alpha:1).cgColor
        
        return label!
        
    }
}

extension UIButton{
    func buttonRanDesigned(){
        self.titleLabel!.minimumScaleFactor = 0.1
        self.titleLabel!.numberOfLines = 1;
        self.titleLabel!.adjustsFontSizeToFitWidth = true;
    }
}


