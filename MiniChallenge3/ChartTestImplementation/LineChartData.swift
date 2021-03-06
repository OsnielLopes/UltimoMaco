//
//  LineChartData.swift
//  ChartTestImplementation
//
//  Created by Guilherme Paciulli on 06/06/17.
//  Copyright © 2017 Guilherme Paciulli, Osniel Teixeira. All rights reserved.
//

import Foundation
import CoreData

class LineChartData {
    
    var totalDays: Int = 0
    
    var points: [ChartPoint] = []
    
    var lastValidPoint: ChartPoint = ChartPoint(Date())
    
    init() {
        points = getChartPointsFromDatabase().sorted(by: { ($0.day as Date) < ($1.day as Date) })
        self.totalDays = points.count-1
        lastValidPoint = points.filter({ $0.cigarettes != -1 }).last!
    }
    
    func getLastValidPointIndex() -> Int {
        return points.index(where: { $0.day == lastValidPoint.day && $0.cigarettes == lastValidPoint.cigarettes })!
    }
    
    func getFormatedDate(_ index: Int) -> String{
        return points[index].getFormattedDate()
    }
    
    func getMaxCigarettes() -> Int{
        var max = 0
        for p in points{
            if p.cigarettes > max {
                max = p.cigarettes
            }
        }
        return max
    }
    
    func getChartPointsFromDatabase() -> [ChartPoint]{
        var entries: [CigaretteEntry] = []
        do {
            entries = try DatabaseController.persistentContainer.viewContext.fetch(NSFetchRequest(entityName: "CigaretteEntry")) as! [CigaretteEntry]
        } catch _ as NSError {
            print("Error")
        }
        var chartPoints: [ChartPoint] = []
        for p in entries{
            if p.cigaretteNumber != -1{
                chartPoints.append(ChartPoint(p.date! as Date, Int(p.cigaretteNumber)))
            }else{
                chartPoints.append(ChartPoint(p.date! as Date))
            }
        }
        
        return chartPoints
    }
    
    func updateSomePoint(_ date: String,_ cigarettNumber: Int){
        //Pega todas as entradas
        var entries: [CigaretteEntry] = []
        do {
            entries = try DatabaseController.persistentContainer.viewContext.fetch(NSFetchRequest(entityName: "CigaretteEntry"))
        } catch _ as NSError {
            print("Error")
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        dateFormatter.locale = Locale(identifier: "pt_BR")
        for entrie in entries{
            var dateFormated = dateFormatter.string(from: entrie.date! as Date)
            let index = dateFormated.index(dateFormated.startIndex, offsetBy: 5)
            dateFormated = dateFormated.substring(to: index)
            if date == dateFormated{
                entrie.cigaretteNumber = Int32(cigarettNumber)
                break
            }
        }
        DatabaseController.saveContext()
    }
    
    func updateSomePoint(_ date: Date,_ cigarettNumber: Int){
        //Pega todas as entradas
        var entries: [CigaretteEntry] = []
        do {
            entries = try DatabaseController.persistentContainer.viewContext.fetch(NSFetchRequest(entityName: "CigaretteEntry"))
        } catch _ as NSError {
            print("Error")
        }
        for entrie in entries{
            if Calendar.current.dateComponents([.month,.day], from: date) == Calendar.current.dateComponents([.month,.day], from: entrie.date! as Date){
                entrie.cigaretteNumber = Int32(cigarettNumber)
                break
            }
        }
        
        DatabaseController.saveContext()
    }
    
    func getCigarettesOfSomeDay(_ date: Date) -> Int{
        var entries: [CigaretteEntry] = []
        do {
            entries = try DatabaseController.persistentContainer.viewContext.fetch(NSFetchRequest(entityName: "CigaretteEntry"))
        } catch _ as NSError {
            print("Error")
        }
        for entrie in entries{
            if Calendar.current.dateComponents([.month,.day], from: date) == Calendar.current.dateComponents([.month,.day], from: entrie.date! as Date){
                return Int(entrie.cigaretteNumber)
            }
        }
        return -1
    }
    
    func getTargetOfConsumption(_ date: Date) -> Int{
        for i in 1..<points.count{
            if Calendar.current.dateComponents([.month,.day], from: date) == Calendar.current.dateComponents([.month,.day], from: points[i].day as Date){
                if i != points.count-1 {
                    return -(Int(Double(points[0].cigarettes)/Double(totalDays) * Double(i))) + points[0].cigarettes
                }else{
                    return 0
                }
            }
        }
        return -1
    }
    
    func getDaysUntilTheZeroPoint() -> Int{
        for i in 1..<points.count{
            if Calendar.current.dateComponents([.month,.day], from: Date()) == Calendar.current.dateComponents([.month,.day], from: points[i].day as Date){
                return points.count-i
            }
        }
        return -1
    }
    
}
