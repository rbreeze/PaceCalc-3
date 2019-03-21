//
//  ViewController.swift
//  PaceCalc 3
//
//  Created by Remington Breeze on 11/2/17.
//  Copyright © 2019 Remington Breeze. All rights reserved.
//

import UIKit
import AudioToolbox

class ViewController: UIViewController {
    
    var brain = PaceBrain()
    
    var isTypingNumber = false
    
    // data structrue to keep track of unit mode
    enum unitMode: String {
        case Kilometers
        case Miles
        
        init() {
            self = .Miles
        }
    }
    
    // data structure to keep track of input mode
    enum inputMode: String {
        case Distance
        case Time
        case Pace
        case Timer
        case ProjectedDistance
        case LapDistance
    }
    
    // Color definitions
    let mainPink = UIColor(red:1.00, green:0.30, blue:0.44, alpha:1.0)
    let darkPink = UIColor(red:0.79, green:0.24, blue:0.35, alpha:1.0)
    let labelGrey = UIColor(red:0.80, green:0.80, blue:0.80, alpha:1.0)
    let numPadGrey = UIColor(red:0.24, green:0.24, blue:0.24, alpha:1.0)
    let mainBrown = UIColor(red:0.96, green:0.93, blue:0.92, alpha:1.0)
    let darkBrown = UIColor(red: 0.92, green: 0.88, blue:0.86, alpha:1.0)
    
    // input data structure
    struct input {
        var data: [String:Double?]
        var splitData: [String: Double?]
        var Mode: inputMode
        
        init() {
            data = [
                "Distance" : nil,
                "Time" : nil,
                "Pace" : nil,
                "Timer" : nil,
                "LapDistance" : nil,
                "ProjectedDistance" : nil
            ]
            splitData = [
                "Distance" : nil,
                "Time" : nil
            ]
            Mode = inputMode.Distance
        }
    }
    
    // initialize instances of data structures
    var calcUnitMode = unitMode()
    var calcInput = input()
    var splitMode:Bool = false
    var alt:Bool = false
    var overloaded:Bool = false
    
    var timer = Timer()
    var startTime: Double = 0.00
    var elapsed: Double = 0.00
    var counter = Double(0.00)
    var counting = false
    var laps = [Double]()
    let formatter = NumberFormatter()
    
    /* IBOutlets */
    
    @IBOutlet weak var splitButton: PinkCalcButton!
    
    @IBOutlet weak var timeButton: PinkCalcButton!
    
    @IBOutlet weak var distanceButton: PinkCalcButton!
    
    @IBOutlet weak var paceButton: PinkCalcButton!
    
    @IBOutlet weak var calculatorDisplay: UILabel!
    
    @IBOutlet weak var unitLabel: UILabel!
    
    @IBOutlet var functionButtons: [UIButton]!
    
    @IBOutlet var numButtons: [UIButton]!
    
    @IBOutlet weak var unitModeLabel: UILabel!
    
    @IBOutlet weak var altButton: BrownCalcButton!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var distanceLabel: UILabel!
    
    @IBOutlet weak var paceLabel: UILabel!
    
    @IBOutlet weak var splitModeIndicator: UILabel!
    
    @IBOutlet weak var seperatorButton: BrownCalcButton!
    
    @IBOutlet weak var staticTimeLabel: UILabel!
    
    @IBOutlet weak var staticPaceLabel: UILabel!
    
    @IBOutlet weak var staticDistanceLabel: UILabel!
    
    /* Button Actions */
    
    // AC Button action
    @IBAction func clearAll(_ sender: AnyObject) {
        AudioServicesPlaySystemSound(1104)
        overloaded = false
        laps = [Double]()
        updateNumPad()
        calculatorDisplay.text = brain.formatDecimal(0, mode: calcInput.Mode.rawValue)
        calcInput.data = [
            "Distance" : nil,
            "Time" : nil,
            "Pace" : nil,
            "Timer" : nil,
            "LapDistance" : nil,
            "ProjectedDistance" : nil
        ]
        calcInput.splitData = [
            "Distance" : nil,
            "Time" : nil
        ]
        timeLabel.text = "0:00"
        paceLabel.text = "0:00"
        distanceLabel.text = "0.0"
        
        timerClear()
    }
    
    // C Button action
    @IBAction func clearDisplay(_ sender: AnyObject) {
        AudioServicesPlaySystemSound(1104)
        overloaded = false
        updateNumPad()
        calculatorDisplay.text = brain.formatDecimal(0, mode: calcInput.Mode.rawValue)
        if (splitMode) {
            calcInput.splitData[calcInput.Mode.rawValue] = nil
            updateSplitDisplay()
        } else {
            calcInput.data[calcInput.Mode.rawValue] = nil
            modeToLabel(mode: calcInput.Mode).text = brain.formatDecimal(0, mode: calcInput.Mode.rawValue)
        }
        
        isTypingNumber = false
        
        timerClear()
    }
    
    //timer clear function
    func timerClear() {
        timer.invalidate()
        counter = 0
        startTime = 0
        elapsed = 0
    }

    @IBAction func altTapped(sender: UIButton) {
        
        if (splitMode && !alt) {
            splitButtonTapped(sender: splitButton)
        }
        
        alt = !alt
        sender.backgroundColor = alt ? darkBrown : mainBrown
        
        let titleA = alt ? " LAP DIST" : "SPLIT"
        let titleB = alt ? "PROJ\n DIST" : "TIME"
        let titleC = alt ? "TIMER" : "DIST"
        let titleD = alt ? "START" : "PACE"
        
        splitButton.setTitle(titleA, for: [])
        timeButton.setTitle(titleB, for: [])
        distanceButton.setTitle(titleC, for: [])
        paceButton.setTitle(titleD, for: [])
        
        var btnToSend: UIButton?
        switch calcInput.Mode {
        case .Distance, .Timer:
            btnToSend = distanceButton
            break
        case .Pace:
            btnToSend = paceButton
            break
        case .Time, .ProjectedDistance:
            btnToSend = timeButton
            break
        default:
            break
        }
        
        resetSeperatorFont()
        
        btnToSend?.isSelected = false
        if (btnToSend != nil) {
            functionTapped(sender: btnToSend!)
        }
    
    }
    
    @IBAction func numberTapped(sender: AnyObject) {
        AudioServicesPlaySystemSound(1104)
        
        // if in timer mode, display relevant lap
        if (calcInput.Mode == .Timer) {
            let number = Int(sender.titleLabel!.text!)!
            let lapTime = number > 1 ? laps[number-1] - laps[number-2] : laps[number-1]
            calculatorDisplay.text = String(format: "%.2f", lapTime)
            unitLabel.text = "LAP \(number)"
            return
        }
        
        let number = sender.currentTitle
        if isTypingNumber {
            calculatorDisplay.text = calculatorDisplay.text! + number!!
        } else {
            calculatorDisplay.text = number!
            isTypingNumber = true
        }
        modeToLabel(mode: calcInput.Mode).text = calculatorDisplay.text
        overloaded = calculatorDisplay.text!.characters.count >= 6 ? true : false
        updateNumPad()
    }
    
    @IBAction func seperatorTapped(_ sender: AnyObject) {
        if (calcInput.Mode == .Timer) {
            lapTimer()
            return
        }
        AudioServicesPlaySystemSound(1104)
        let seperator = sender.currentTitle
        if isTypingNumber {
            calculatorDisplay.text = calculatorDisplay.text! + seperator!!
        } else {
            calculatorDisplay.text = seperator!
            isTypingNumber = true
        }
        modeToLabel(mode: calcInput.Mode).text = calculatorDisplay.text
        overloaded = calculatorDisplay.text!.characters.count >= 6 ? true : false
        updateNumPad()
    }
    
    //timer helper
    @objc func timerAction() {
        counter = Date().timeIntervalSinceReferenceDate - startTime
        
        let timerText = formatter.string(from: NSNumber(value: counter))
        
        calculatorDisplay.text = timerText
        timeLabel.text = timerText
    }
    
    //lap function
    func lapTimer() {
        if (!counting) {
            return
        } else {
            laps.append(counter)
            updateNumLaps()
            return
        }
    }
    
    @IBAction func splitButtonTapped(sender: UIButton) {
        
        if (calcInput.Mode == .Pace && !splitMode || calcInput.Mode == .LapDistance) {
            return
        } else if (alt) {
            lapDistanceButtonTapped(sender: sender)
            return
        }
        
        AudioServicesPlaySystemSound(1104)

        splitModeIndicator.isHidden = !splitModeIndicator.isHidden
        splitMode = !splitMode
        
        let currentStaticLabel = getCurrentStaticLabel()
        
        if sender.isSelected {
            sender.isSelected = false
            sender.backgroundColor = mainPink
            unfill(label: currentStaticLabel)
            
            if (calcInput.Mode == .Distance) {
                calcInput.splitData["Distance"] = Double(calculatorDisplay.text!) ?? 0
            }
            
            paceButton.setTitleColor(UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), for: UIControl.State.normal)
            
            updateDisplay()
            
        } else {
            getAndSaveDisplay()
            updateData()
            
            sender.isSelected = true
            sender.backgroundColor = darkPink
            fillIn(label: currentStaticLabel, color: mainPink)
            paceButton.setTitleColor(UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5), for: UIControl.State.normal)
            
            updateSplitDisplay()
            
        }
        
        updateNumPad()
        
    }
    
    func lapDistanceButtonTapped(sender: UIButton) {
        if (calcInput.Mode == .LapDistance) {
            return
        }
        
        AudioServicesPlaySystemSound(1104)
        
        getAndSaveDisplay()
        
        isTypingNumber = false
        calcInput.Mode = .LapDistance
        
        resetSeperatorFont()
        seperatorButton.setTitle(".", for: [])
        
        for button in functionButtons {
            button.backgroundColor = mainPink
            button.isSelected = false
        }
        
        sender.isSelected = true
        sender.backgroundColor = darkPink
        
        updateUnitLabel()
        updateNumPad()
        updateDisplay()
        
        return
    }
    
    @IBAction func functionTapped(sender: UIButton) {
        if !sender.isSelected && !(sender == paceButton && splitMode) {
            
            AudioServicesPlaySystemSound(1104)
            
            isTypingNumber = false
            
            if (splitMode && calcInput.Mode == .Distance) {
                calcInput.splitData["Distance"] = Double(calculatorDisplay.text!) ?? 0
            } else if (splitMode && calcInput.Mode == .Time) {
                calcInput.splitData["Time"] = brain.timeStringtoDouble(calculatorDisplay.text)
            } else {
                getAndSaveDisplay()
            }
            
            unfill(label: getCurrentStaticLabel())
            
            if (!alt && sender != paceButton && sender != distanceButton) {
                resetSeperatorFont()
            }
            
            splitButton.setTitleColor(UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), for: UIControl.State.normal)
            paceButton.setTitleColor(UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), for: UIControl.State.normal)
            
            // switch mode to whatever button was pressed
            switch sender {
            case timeButton:
                if (alt) {
                    resetSeperatorFont()
                    calcInput.Mode = inputMode.ProjectedDistance
                    seperatorButton.setTitle(".", for: [])
                    paceButton.setTitleColor(UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5), for: UIControl.State.normal)
                } else {
                    calcInput.Mode = inputMode.Time
                    splitMode ? fillIn(label: staticTimeLabel, color: mainPink) : unfill(label: staticTimeLabel)
                    seperatorButton.setTitle(":", for: UIControl.State.normal)
                }
                break
            case distanceButton:
                if (alt) {
                    calcInput.Mode = inputMode.Timer
                    seperatorButton.setTitle("", for: [])
                    seperatorButton.titleLabel?.font = UIFont.systemFont(ofSize: 25.0)
                    seperatorButton.setTitle("LAP", for: [])
                    paceButton.setTitleColor(UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), for: UIControl.State.normal)
                } else {
                    calcInput.Mode = inputMode.Distance
                    splitMode ? fillIn(label: staticDistanceLabel, color: mainPink) : unfill(label: staticDistanceLabel)
                    seperatorButton.setTitle(".", for: UIControl.State.normal)
                }
                break
            case paceButton:
                if (calcInput.Mode == .Timer && alt) {
                    timer.invalidate()
                    counting = !counting
                    let title = counting ? "STOP" : "START"
                    paceButton.setTitle(title, for: [])
                    // if timer was just started
                    if (counting) {
                        startTime = Date().timeIntervalSinceReferenceDate - elapsed
                        timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(ViewController.timerAction), userInfo: nil, repeats: true)
                    } else { // if timer was just stopped
                        elapsed = Date().timeIntervalSinceReferenceDate - startTime
                        timer.invalidate()
                    }
                } else {
                    calcInput.Mode = inputMode.Pace
                    splitButton.setTitleColor(UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5), for: UIControl.State.normal)
                    seperatorButton.setTitle(":", for: UIControl.State.normal)
                }
                break
            default:
                break
            }
            
            splitMode ? updateSplitDisplay() : updateDisplay()
            
            updateNumPad()

            // deselect all buttons
            for button in functionButtons {
                button.backgroundColor = mainPink
                button.isSelected = false
            }
            
            if (alt || !splitMode) {
                splitButton.backgroundColor = mainPink
                splitButton.isSelected = false
            }
            
            // style and select the button that the user selected
            if (alt && sender == paceButton) {
                distanceButton.isSelected = true
                distanceButton.backgroundColor = darkPink
            } else {
                sender.isSelected = true
                sender.backgroundColor = darkPink
            }
        } else {
            return
        }
    }

    @IBAction func toggleMode(_ sender: UIButton) {
        AudioServicesPlaySystemSound(1104)
        let originalUnit = calcUnitMode
        if calcUnitMode == .Miles {
            calcUnitMode = .Kilometers
            unitModeLabel.text = "KM"
        } else {
            calcUnitMode = .Miles
            unitModeLabel.text = "MILES"
        }
        
        splitMode ? getAndSaveSplitDisplay() : getAndSaveDisplay()
        
        let currentDistance = calcInput.data["Distance"] ?? nil
        let currentPace = calcInput.data["Pace"] ?? nil
        let currentSplitDistance = calcInput.splitData["Distance"] ?? nil
        
        if (currentDistance != nil) {
            let convertedDistance = brain.convert(currentDistance!, fromUnit: originalUnit.rawValue, toUnit: calcUnitMode.rawValue) ?? 0
            calcInput.data["Distance"] = brain.roundToHundredths(convertedDistance)
        }
        
        if (currentPace != nil){
            let convertedPace = brain.convert(1 / currentPace!, fromUnit: originalUnit.rawValue, toUnit: calcUnitMode.rawValue) ?? 0
            calcInput.data["Pace"] = brain.roundToHundredths(1 / convertedPace)
        }
        
        if (currentSplitDistance != nil){
            let convertedSplitDistance = brain.convert(currentSplitDistance!, fromUnit: originalUnit.rawValue, toUnit: calcUnitMode.rawValue) ?? 0
            calcInput.splitData["Distance"] = brain.roundToHundredths(convertedSplitDistance)
        }
        
        updateData()
        splitMode ? updateSplitDisplay() : updateDisplay()

    }
    
    /* Helper functions */
    
    func getAndSaveDisplay() {
        var currentInput: Double
        // convert the input on the calculator's display to a double
        if (calcInput.Mode == inputMode.Pace || calcInput.Mode == inputMode.Time) {
            currentInput = brain.timeStringtoDouble(calculatorDisplay.text)
        } else {
            currentInput = Double(calculatorDisplay.text!) ?? 0
        }
        
        // if it's 0, save it as nil, otherwise, save in appropriate slot
        calcInput.data[calcInput.Mode.rawValue] = currentInput == 0 ? nil : currentInput
        print(calcInput.Mode)
        print(calcInput.data)
    }
    
    func getAndSaveSplitDisplay() {
        var currentInput: Double = 0
        if (calcInput.Mode == .Distance) {
            currentInput = Double(calculatorDisplay.text!) ?? 0
        } else if (calcInput.Mode == .Time) {
            currentInput = brain.timeStringtoDouble(calculatorDisplay.text)
        }
        
        if (currentInput == 0) {
            calcInput.splitData[calcInput.Mode.rawValue] = nil
        } else {
            calcInput.splitData[calcInput.Mode.rawValue] = currentInput
        }
    }
    
    func updateSplitTime() {
        let pace = (calcInput.data["Pace"] ?? 0) ?? 0
        let distance = (calcInput.splitData["Distance"] ?? 0) ?? 0
        let result = pace == 0 || distance == 0 ? nil : pace * distance
        calcInput.splitData["Time"] = result
    }
    
    func updateNumPad() {
        // deactivate and style numpad buttons if in Time mode and Split mode
        let currentNumPadColor = (splitMode && calcInput.Mode == .Time) || overloaded || calcInput.Mode == .Timer ? UIColor(red:0.24, green:0.24, blue:0.24, alpha:0.5) : numPadGrey
        
        let numPadState = (splitMode && calcInput.Mode == .Time) || overloaded || calcInput.Mode == .Timer ? false : true
        
        for button in numButtons {
            button.setTitleColor(currentNumPadColor, for: UIControl.State.normal)
            button.isEnabled = numPadState
        }
        
        if (calcInput.Mode == .Timer) {
            updateNumLaps()
        }
    }
    
    func updateNumLaps() {
        var i = 0
        while i < laps.count && i < 9 {
            numButtons[i].setTitleColor(numPadGrey, for: UIControl.State.normal)
            numButtons[i].isEnabled = true
            i += 1
        }
    }
    
    func updateSplitDisplay() {
        updateSplitTime()
        
        let currentValue = (calcInput.splitData[calcInput.Mode.rawValue] ?? 0) ?? 0
        calculatorDisplay.text = brain.formatDecimal(currentValue, mode: calcInput.Mode.rawValue)
        
        updateUnitLabel()
        updateSmallLabels()
    }
    
    func updateData() {
        let calculatedResults = brain.findMissing(distance: calcInput.data["Distance"] ?? nil, time: calcInput.data["Time"] ?? nil, pace: calcInput.data["Pace"] ?? nil, mode: calcInput.Mode.rawValue)
        if (!calculatedResults.error) {
            calcInput.data["Distance"] = calculatedResults.distance
            calcInput.data["Time"] = calculatedResults.time
            calcInput.data["Pace"] = calculatedResults.pace
        }
        updateSplitTime()
    }
    
    func updateDisplay() {
        
        // calculate missing data
        
        updateData()
        
        updateSmallLabels()
        
        // get the new current value to display on screen
        let currentValue = (calcInput.data[calcInput.Mode.rawValue] ?? 0) ?? 0
        calculatorDisplay.text = brain.formatDecimal(currentValue, mode: calcInput.Mode.rawValue)
        
        updateUnitLabel()
        
    }
    
    func updateSmallLabels() {
        // update small labels
        let currentDataSet = splitMode ? calcInput.splitData : calcInput.data
        timeLabel.text = alt ? timeLabel.text :  brain.timeDecimalToString((currentDataSet["Time"] ?? 0) ?? 0)
        paceLabel.text =  brain.timeDecimalToString((calcInput.data["Pace"] ?? 0) ?? 0)
        
        var distanceText:String
        if (calcInput.Mode == .LapDistance) {
            distanceText = "\((currentDataSet["LapDistance"] ?? 0) ?? 0)"
        } else if (calcInput.Mode == .ProjectedDistance) {
            distanceText = "\((currentDataSet["ProjectedDistance"] ?? 0) ?? 0)"
        } else {
            distanceText = "\((currentDataSet["Distance"] ?? 0) ?? 0)"
        }
        distanceLabel.text = distanceText
    }
    
    func updateUnitLabel() {
        var label = "MI"
        var unitText:String
        
        if (calcUnitMode == .Kilometers) {
            label = "KM"
        }
        
        switch (calcInput.Mode) {
        case .Distance, .LapDistance, .ProjectedDistance:
            unitText = label
            break
        case .Time:
            unitText = "MIN"
            break
        case .Pace:
            unitText = "MIN / " + label
            break
        case .Timer:
            unitText = "SEC ELAPSED"
            break
        default:
            unitText = ""
        }
        
        unitLabel.text = unitText
    }
    
    func getCurrentStaticLabel() -> UILabel {
        var currentStaticLabel:UILabel
        
        switch calcInput.Mode {
        case .Distance:
            currentStaticLabel = staticDistanceLabel
            break
        case .Time:
            currentStaticLabel = staticTimeLabel
            break
        case .Pace:
            currentStaticLabel = staticPaceLabel
            break
        default:
            currentStaticLabel = staticDistanceLabel
        }
        
        return currentStaticLabel
    }
    
    func modeToLabel(mode: inputMode) -> UILabel {
        switch mode {
        case .Distance, .LapDistance:
            return distanceLabel
        case .Pace:
            return paceLabel
        case .Time:
            return timeLabel
        case .ProjectedDistance:
            return distanceLabel
        default:
            return distanceLabel
        }
    }
    
    func addBorderRadius(label: UILabel) {
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 5.0
    }
    
    func fillIn(label: UILabel, color: UIColor) {
        label.backgroundColor = color
        addBorderRadius(label: label)
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 20.0, weight: UIFont.Weight.semibold)
    }
    
    func unfill(label: UILabel) {
        label.backgroundColor = UIColor.clear
        label.textColor = labelGrey
        label.font = UIFont.systemFont(ofSize: 20.0, weight: UIFont.Weight.regular)
    }
    
    func resetSeperatorFont() {
        let prevTitle = seperatorButton.currentTitle
        seperatorButton.setTitle("", for: [])
        seperatorButton.titleLabel?.font = UIFont.systemFont(ofSize: 40.0)
        seperatorButton.setTitle(prevTitle, for: [])
    }
    
    // App functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        distanceButton.isSelected = true
        splitModeIndicator.isHidden = true
        addBorderRadius(label: splitModeIndicator)
        addBorderRadius(label: unitModeLabel)
        
        timer.invalidate()
        
        calculatorDisplay.font = UIFont.monospacedDigitSystemFont(ofSize: 70.0, weight: UIFont.Weight.regular)
        
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.minimumIntegerDigits = 1
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        let defaults = UserDefaults.standard
        let date = Date()
        defaults.set(date, forKey: "startDate")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let defaults = UserDefaults.standard
        if let startDate = defaults.object(forKey: "startDate") as? Date {
            let newDate = Date()
            let elapsed = newDate.timeIntervalSince(startDate)
            counter = Double(elapsed)
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

