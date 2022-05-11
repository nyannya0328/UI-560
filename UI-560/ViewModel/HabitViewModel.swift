//
//  HabitViewModel.swift
//  UI-560
//
//  Created by nyannyan0328 on 2022/05/11.
//

import SwiftUI
import CoreData
import UserNotifications

class HabitViewModel: ObservableObject {
    
    @Published var addNewHabit : Bool = false
    
    @Published var title: String = ""
    @Published var habitColor: String = "Card-1"
    @Published var weekDays: [String] = []
    @Published var isRemainderOn: Bool = false
    @Published var remainderText: String = ""
    @Published var remainderDate: Date = Date()
    
    @Published var showPicker : Bool = false
    
    @Published var edtiHabit : Habit?
    
    @Published var notificationAcces : Bool = false
    
    func resetData(){
        
        
        title = ""
        habitColor = "Card-1"
        weekDays = []
        isRemainderOn = false
        remainderText = ""
        remainderDate = Date()
        edtiHabit = nil
        
        
    }
    
    init() {
        
        requestNotificationAccess()
        
    }
    
    func requestNotificationAccess(){
        
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.sound,.alert]) { status, _ in
            
            
            DispatchQueue.main.async {
                
                self.notificationAcces = status
            }
        }
        
    }
    
    func deleteHabit(context : NSManagedObjectContext)->Bool{
        
        if let edtiHabit = edtiHabit {
            
            if edtiHabit.isRemaindaerOn{
                
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: edtiHabit.notificationIDs ?? [])
            }
            context.delete(edtiHabit)
            
            if let _ = try? context.save(){
                
                return true
            }
            
        }
        return false
    }
    
    func restoreDate(){
        
        
        if let edtiHabit = edtiHabit {
            
            title = edtiHabit.title ?? ""
            habitColor = edtiHabit.color ?? "Card-1"
            weekDays = edtiHabit.weekDays ?? []
            isRemainderOn = edtiHabit.isRemaindaerOn
            remainderText = edtiHabit.reaminderText ?? ""
            remainderDate = edtiHabit.notificationDate ?? Date()
           
            
        }
    }
    
    func addHabit(context : NSManagedObjectContext)async->Bool{
        
        var habit : Habit!
        
        if let edtiHabit = edtiHabit {
            
            habit = edtiHabit
            
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: edtiHabit.notificationIDs ?? [])
        }
        
        else{
            
            habit = Habit(context: context)
        }
        
        habit.title = title
        habit.reaminderText = remainderText
        habit.notificationIDs = []
        habit.color = habitColor
        habit.dateAdded = remainderDate
        habit.weekDays = weekDays
        habit.notificationDate = remainderDate
        habit.isRemaindaerOn = isRemainderOn
        
        if isRemainderOn{
            
            if let ids = try? await schedultNotification(){
                
                habit.notificationIDs = ids
                
                if let _ = try? context.save(){
                    
                    return true
                }
                
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ids)
                
                
            }
            
            
        }
        
        else{
            
            
            if let _ = try? context.save(){
                
                return true
            }
            
        }
        
        return false
        
        
        
        
    }
    
    func schedultNotification()async throws -> [String]{
        
        let content = UNMutableNotificationContent()
        content.title = "Habit Remaidar"
        content.subtitle = remainderText
        content.sound = UNNotificationSound.default
        
        var notifficationIDS : [String] = []
        
        let calendar = Calendar.current
        let weekSymbols : [String] = calendar.weekdaySymbols
        
        for weekDay in weekDays{
            
            let id = UUID().uuidString
            let hour = calendar.component(.hour, from: remainderDate)
            let min = calendar.component(.minute, from: remainderDate)
            
            let day = weekSymbols.firstIndex { currentDay in
                
                return currentDay == weekDay
            } ?? -1
            
            if day != -1{
                
                var components = DateComponents()
                components.hour = hour
                components.minute = min
                components.weekday = day + 1
                
                let triger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
                let request = UNNotificationRequest(identifier: id, content: content, trigger: triger)
                
                
                notifficationIDS.append(id)
                
                try await UNUserNotificationCenter.current().add(request)
            }
            
        }
        
        return notifficationIDS
        
        
        
    }
    
    func doneStatus()->Bool{
        
        let remaindarStatus = isRemainderOn ? remainderText == "" : false
        
        if title == "" || weekDays.isEmpty || remaindarStatus{
            
            return false
        }
        
        return true
        
    }
}

