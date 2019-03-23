//
//  PaceBrain.swift
//  PaceCalc 3
//
//  Created by Remington Breeze on 11/3/17.
//  Copyright © 2017 Remington Breeze. All rights reserved.
//

import Foundation

class PaceBrain {
    func timeDecimalToString(_ timeDouble: Double) -> String {
        var minutes = timeDouble == 0.0 || timeDouble.isNaN || timeDouble.isInfinite ? 0 : Int(floor(timeDouble))
        var seconds = timeDouble.isInfinite || timeDouble.isNaN || timeDouble == 0 ? 0 : Int(round((timeDouble-Double(minutes)) * 60))
        
        if seconds >= 60 {
            seconds = 0
            minutes += 1
        }
        
        let result = seconds > 9 ? "\(minutes):\(seconds)" : "\(minutes):0\(seconds)"
        return result
    }
    
    func timeStringToMinutesAndSeconds(_ timeString: String?) -> (minutes: Double, seconds: Double) {
        let timeRegEx = "((\\d?\\d?\\d):)?([0-5]?\\d?)?"
        let timeTest = NSPredicate(format: "SELF MATCHES %@", timeRegEx)
        
        var minutes:Double = 0
        var seconds:Double = 0
        
        let timeText = timeString == nil || timeString == "" ? "0:00" : timeString!
        
        if timeTest.evaluate(with: timeText) == true {
            let minutesRegEx = "(\\d)?:([0-5]\\d)?"
            var minuteShift: Int
            if NSPredicate(format: "SELF MATCHES %@", minutesRegEx).evaluate(with: timeText) {
                minuteShift = 1
            } else {
                let noSecondsRegEx = "\\d?\\d?"
                if NSPredicate(format: "SELF MATCHES %@", noSecondsRegEx).evaluate(with: timeText) {
                    minuteShift = 0
                } else {
                    let tripleRegEx = "\\d\\d\\d:([0-5]\\d)?"
                    if NSPredicate(format: "SELF MATCHES %@", tripleRegEx).evaluate(with: timeText) {
                        minuteShift = 3
                    } else {
                        minuteShift = 2
                    }
                }
            }
            if let _ = timeString {
                let timeValue = timeText
                if minuteShift != 0 {
                    let minutesRange = (timeValue.startIndex ..< timeValue.characters.index(timeValue.startIndex, offsetBy: minuteShift))
                    minutes = Double(timeValue.substring(with: minutesRange))!
                    let secondsRange = (timeValue.characters.index(timeValue.startIndex, offsetBy: minuteShift+1) ..< timeValue.characters.index(timeValue.startIndex, offsetBy: minuteShift+3))
                    seconds = Double(timeValue.substring(with: secondsRange))!
                } else {
                    minutes = Double(timeValue)!
                    seconds = 0
                }
            }
        }
        
        return (minutes, seconds)
        
    }
    
    func convert(_ data: Double, fromUnit: String, toUnit: String) -> Double? {
        var conversionFactor: Double
        
        switch toUnit {
        case "Kilometers":
            conversionFactor = 1.60934
            break
        case "Miles":
            conversionFactor = 0.621371
            break
        default:
            conversionFactor = 1
            break
        }
        
        if toUnit == fromUnit {
            conversionFactor = 1
            return nil
        }
        
        return data * conversionFactor
    }
    
    func findMissing(distance: Double?, time: Double?, pace: Double?, mode: String) -> (distance: Double?, time: Double?, pace: Double?, error: Bool) {
        
        var resultDistance, resultTime, resultPace:Double?
        
        resultDistance = distance
        resultTime = time
        resultPace = pace
        
        if pace != nil && distance != nil && time != nil {
            switch mode {
            case "Distance":
                resultDistance = nil
                break
            case "Time":
                resultTime = nil
                break
            case "Pace":
                fallthrough
            default:
                resultPace = nil
                break
            }
        }
        
        if resultDistance == nil && resultTime != nil && resultPace != nil {
            resultDistance = time! / pace!
        } else if resultTime == nil && resultDistance != nil && resultPace != nil {
            resultTime = pace! * distance!
        } else if resultPace == nil && resultDistance != nil && resultTime != nil {
            resultPace = time! / distance!
        } else {
            return (distance, time, pace, true)
        }
        
        if (resultDistance != nil) {
            resultDistance = roundToHundredths(resultDistance!)
        }
        return (resultDistance, resultTime, resultPace, false)
    }
    
    func getProjection(_ lapDistance: Double, lapTime: Double, projectedDistance: Double) -> String {
        let projectedDouble = (projectedDistance / lapDistance) * lapTime
        return timeDecimalToString(projectedDouble / 60)
    }
    
    func minutesAndSecondsToDouble(_ minutes: Double, seconds: Double) -> Double {
        return minutes + (seconds/60)
    }
    
    func timeStringtoDouble(_ timeString: String?) -> Double {
        let minutesAndSeconds = timeStringToMinutesAndSeconds(timeString)
        return minutesAndSecondsToDouble(minutesAndSeconds.minutes, seconds: minutesAndSeconds.seconds)
    }
    
    func roundToHundredths(_ number: Double) -> Double {
        return round(number * 100) / 100
    }
    
    func formatDecimal(_ decimal: Double, mode: String) -> String {
        switch mode {
        case "Pace", "Time":
            return timeDecimalToString(decimal)
        case "Timer":
            var precision = Int(round((decimal - floor(decimal)) * 10))
            precision = precision == 10 ? 0 : precision
            return timeDecimalToString(decimal/60) + ".\(precision)"
        case "Distance":
            fallthrough
        default:
            return "\(roundToHundredths(decimal))"
        }
    }

}

