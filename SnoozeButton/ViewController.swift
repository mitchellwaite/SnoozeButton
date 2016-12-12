//
//  ViewController.swift
//  SnoozeButton
//
//  Created by Mitchell Waite on 2016-12-12.
//  Copyright © 2016 Mitchell Waite. All rights reserved.
//
import Foundation
import UIKit
import AVFoundation

class ViewController: UIViewController {

    @IBOutlet var MainTimePicker: UIDatePicker!
    @IBOutlet var TimeRemainingLabel: UILabel!
    
    var timeLeft:TimeInterval = 0;
    var swiftTimer:Timer = Timer();
    
    var timerHasEnded = false;
    
    var audioPlayer:AVAudioPlayer = AVAudioPlayer();
    
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        if motion == .motionShake
        {
            if(timerHasEnded)
            {
                print("Add 10 minutes!");
                timerHasEnded = false;
                var currentCalendar = Calendar(identifier: .gregorian);
                currentCalendar.locale = Locale(identifier: "en_US");
                var newDate = Date();
                newDate.addTimeInterval(600);
                self.TimeRemainingLabel.textColor = UIColor.white;
                
                //Timer has ended. Add 10 minutes because i'm lazy
                swiftTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true, block: { (timer) in
                    self.timeLeft = newDate.timeIntervalSince(Date());
                    if(self.timeLeft <= 0)
                    {
                        print("Out of time!");
                        self.timeLeft = 0;
                        timer.invalidate();
                        self.timerHasEnded = true;
                        self.TimeRemainingLabel.text! = self.stringFromTimeInterval(interval: self.timeLeft);
                        self.TimeRemainingLabel.textColor = UIColor.red;
                        self.audioPlayer.play();
                    }
                    else
                    {
                        self.TimeRemainingLabel.text! = self.stringFromTimeInterval(interval: self.timeLeft);
                        
                    }
                })
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        do
        {
            audioPlayer = try AVAudioPlayer(contentsOf: URL(string: "/System/Library/Audio/UISounds/ReceivedMessage.caf")!);
            audioPlayer.numberOfLoops = 99999;
        }
        catch
        {
            
        }
        
        MainTimePicker.setValue(UIColor.black, forKey: "backgroundColor");
        MainTimePicker.setValue(UIColor.orange, forKey: "textColor");

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func stringFromTimeInterval(interval: TimeInterval) -> String {
        let interval = Int(interval)
        let seconds = interval % 60
        let minutes = (interval / 60) % 60
        let hours = (interval / 3600)
        return String(format: "%02dh %02dm %02ds", hours, minutes, seconds)
    }
    
    @IBAction func setAlarm_TouchUpInside(_ sender: Any) {
        var currentCalendar = Calendar(identifier: .gregorian);
        currentCalendar.locale = Locale(identifier: "en_US");
        var curComponents = currentCalendar.dateComponents([.year,.month,.day,.hour,.minute], from: Date());
        var mtpComponents = currentCalendar.dateComponents([.hour,.minute], from: MainTimePicker.date);
        var newComponents = DateComponents();
        
        let formatter = DateFormatter();
        formatter.timeStyle = .medium;
        formatter.dateStyle = .medium;
        
        newComponents.year = curComponents.year;
        newComponents.month = curComponents.month;
        newComponents.day = curComponents.day;
        
        newComponents.hour = mtpComponents.hour;
        newComponents.minute = mtpComponents.minute;
        newComponents.second = 0;
        
        var newDate = currentCalendar.date(from: newComponents)!;
        
        if(mtpComponents.hour! < curComponents.hour! || (mtpComponents.hour! == curComponents.hour! && mtpComponents.minute! < curComponents.minute!) )
        {
            newDate.addTimeInterval(86400);
        }
        
        let alertCtrl = UIAlertController(title: "Timer is set", message: "Time that the timer will fire:\n\n" + formatter.string(from: newDate), preferredStyle: .alert);
        alertCtrl.addAction(UIAlertAction(title: "OK", style: .default, handler: nil));
        
        self.present(alertCtrl, animated: true, completion: nil);
        
        print("Timer Set!");
        swiftTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true, block: { (timer) in
            self.timeLeft = newDate.timeIntervalSince(Date());
            if(self.timeLeft <= 0)
            {
                print("Out of time!");
                self.timeLeft = 0;
                timer.invalidate();
                self.timerHasEnded = true;
                self.TimeRemainingLabel.text! = self.stringFromTimeInterval(interval: self.timeLeft);
                self.TimeRemainingLabel.textColor = UIColor.red;
                self.audioPlayer.play();
            }
            else
            {
                self.TimeRemainingLabel.text! = self.stringFromTimeInterval(interval: self.timeLeft);

            }
        })
        
        
    }

    @IBAction func cancelAlarm_TouchUpInside(_ sender: Any) {
        print("Cancel Timer!");
        audioPlayer.stop();
        swiftTimer.invalidate();
        timerHasEnded = false;
        TimeRemainingLabel.text! = "00h 00m 00s";
        self.TimeRemainingLabel.textColor = UIColor.white;
        
    }
    
    
}

