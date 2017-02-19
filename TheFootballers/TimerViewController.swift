
import UIKit

class TimerViewController: UIViewController {
    var timer = Timer()
    var counter = 0
    var timeAfterPause:Int = 0
    var counterSmallSecond = 0
    var counterBigSecond = 0
    var counterSmallMinute = 0
    var counterBigMinute = 0
    var counterHour = 0
    
    @IBOutlet var hourLbl: UILabel!
    @IBOutlet var countingLabel: UILabel!
    @IBOutlet var bigMinuteLbl: UILabel!
    @IBOutlet var smallMinuteLbl: UILabel!
    @IBOutlet var bigSecongLbl: UILabel!
    @IBOutlet var smallSecondLbl: UILabel!
    @IBOutlet var viewNumbers: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        countingLabel.isHidden = true
        self.viewNumbers.layer.cornerRadius = 10
        self.viewNumbers.backgroundColor = UIColor(red: 0/255, green: 102/255, blue: 0/255, alpha: 1)
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.image = UIImage(named: "footballpng2.png")
        self.view.insertSubview(backgroundImage, at: 0)
        
        
    }
    
    @IBAction func startBtn(_ sender: UIBarButtonItem) {
        if (counter == 0 || counter == timeAfterPause){ //make sure that when the timer already start clicking on the button will do nothing
            timer = Timer.scheduledTimer(timeInterval: 1, target:self, selector: #selector(TimerViewController.updateCounter), userInfo: nil, repeats: true)
        }
    }
    
    @IBAction func pauseBtn(_ sender: UIBarButtonItem) {
        timeAfterPause = counter
        timer.invalidate()
        
    }
    
    @IBAction func clearBtn(_ sender: UIBarButtonItem) {
        eraseTime()
    }
    
    func eraseTime(){
        timer.invalidate()
        counter = 0
        countingLabel.text = String(counter)
        
        counterSmallSecond = 0
        counterBigSecond = 0
        counterSmallMinute = 0
        counterBigMinute = 0
        counterHour = 0
        
        smallSecondLbl.text = String(counterSmallSecond)
        bigSecongLbl.text = String(counterBigSecond)
        smallMinuteLbl.text = String(counterSmallMinute)
        bigMinuteLbl.text = String(counterBigMinute)
        hourLbl.text = String(counterHour)
    }
    
    func updateCounter() {
        counter += 1
        countingLabel.text = String(counter)
        
        counterSmallSecond += 1
        if counterSmallSecond == 10 {
            counterSmallSecond = 0
            counterBigSecond += 1
            if counterBigSecond == 6{
                counterBigSecond = 0
                counterSmallMinute += 1
                if counterSmallMinute == 10{
                    counterSmallMinute = 0
                    counterBigMinute += 1
                    if counterBigMinute == 6{
                        counterBigMinute = 0
                        counterHour += 1
                        if counterHour == 3{
                            eraseTime()
                            
                        }
                    }
                }
            }
        }
        smallSecondLbl.text = String(counterSmallSecond)
        bigSecongLbl.text = String(counterBigSecond)
        smallMinuteLbl.text = String(counterSmallMinute)
        bigMinuteLbl.text = String(counterBigMinute)
        hourLbl.text = String(counterHour)
        
    }
    
}
