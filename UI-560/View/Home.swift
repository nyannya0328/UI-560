//
//  Home.swift
//  UI-560
//
//  Created by nyannyan0328 on 2022/05/11.
//

import SwiftUI

struct Home: View {
    
    @StateObject var model : HabitViewModel = .init()
    @FetchRequest(entity: Habit.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Habit.dateAdded, ascending: false)], predicate: nil, animation: .easeInOut) var habits : FetchedResults<Habit>
    
    var body: some View {
        VStack{
            
            
                
                Text("Habit")
                    .font(.title2.weight(.semibold))
                    .lCenter()
                    .overlay(alignment: .trailing) {
                        
                        Button {
                            
                        } label: {
                            
                            Image(systemName: "gearshape")
                                .font(.title3)
                                .foregroundColor(.white)
                        }

                    }
                
                
                ScrollView(habits.isEmpty ? .init() : .vertical, showsIndicators: false) {
                    
                    
                    ForEach(habits){habit in
                        
                        HabitCardView(habit: habit)
                    }
                    
                    VStack(spacing:15){
                        
                        
                        Button {
                            
                            withAnimation{
                                
                                model.addNewHabit.toggle()
                            }
                            
                        } label: {
                            
                            Label {
                                Text("New Habit")
                                
                            } icon: {
                            Image(systemName: "plus.circle.fill")
                            }
                            .foregroundColor(.white)

                        }
                        .padding(.top,13)
                        .maxHW()

                        
                        
                    }
                }
                
                
            
            
            
        }
        .maxHWTop()
        .preferredColorScheme(.dark)
        .sheet(isPresented: $model.addNewHabit) {
            
            model.resetData()
            
        } content: {
            
            AddNewHabit()
                .environmentObject(model)
            
        }


    }
    
    @ViewBuilder
    func HabitCardView(habit : Habit)->some View{
        
        VStack(spacing:0){
            
            HStack{
                
                Text(habit.title ?? "")
                    .font(.callout.weight(.semibold))
                    .lineLimit(1)
                
                Image(systemName: "bell.circle.fill")
                    .font(.title2)
                    .foregroundColor(Color(habit.color ?? "Card-1"))
                    .scaleEffect(0.5)
                    .opacity(habit.isRemaindaerOn ? 1 : 0)
                
                
                Spacer()
                
                
                let count = (habit.weekDays?.count ?? 0)
                
                Text(count == 7 ? "EveyDay" : "\(count) times a week")
                    .font(.caption)
                    .foregroundColor(.gray)
                
            }
            .padding(.horizontal,10)
            
            
            let calendar = Calendar.current
            
            let currentWeek = calendar.dateInterval(of: .weekOfMonth, for: Date())
            
            let symbols = calendar.weekdaySymbols
            
            let startDate = currentWeek?.start ?? Date()
            
            let activeWeekDays = habit.weekDays ?? []
            
            let activePlot = symbols.indices.compactMap { index ->(String,Date) in
                
                let currentDate = calendar.date(byAdding: .day, value: index, to: startDate)
                
                return (symbols[index],currentDate!)
                
            }
            
            
            HStack(spacing:0){
                
                
                ForEach(activePlot.indices,id:\.self){index in
                    let item = activePlot[index]
                    
                    
                    VStack(spacing:6){
                        
                        
                        Text(item.0.prefix(3))
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        
                        let status = activeWeekDays.contains { day in
                            
                            return day == item.0
                        }
                        
                        Text(getDate(date:item.1))
                            .font(.system(size: 12, weight: .semibold))
                            .padding(10)
                            .background{
                                
                                Circle()
                                    .fill(Color(habit.color ?? "Card-1"))
                                    .opacity(status ? 1 : 0)
                            }
                        
                        
                        
                        
                    }
                    .lCenter()
                    
                    
                }
            }
           
            
            
            
        }
        .padding(.vertical)
        .padding(.horizontal)
        .background{
            
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color("TFBG").opacity(0.8))
            
        }
        .onTapGesture {
            
            model.edtiHabit = habit
            model.restoreDate()
            model.addNewHabit.toggle()

            
        }
        
        
    }
    
    func getDate(date : Date)->String{
        
        let formater = DateFormatter()
        formater.dateFormat = "dd"
        
        return formater.string(from: date)
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

extension View{

    func getRect()->CGRect{


        return UIScreen.main.bounds
    }

    func lLeading()->some View{

        self
            .frame(maxWidth:.infinity,alignment: .leading)
    }
    func lTreading()->some View{

        self
            .frame(maxWidth:.infinity,alignment: .trailing)
    }
    func lCenter()->some View{

        self
            .frame(maxWidth:.infinity,alignment: .center)
    }

    func maxHW()->some View{

        self
            .frame(maxWidth:.infinity,maxHeight: .infinity)


    }

 func maxHWTop() -> some View{


        self
            .frame(maxWidth:.infinity,maxHeight: .infinity,alignment: .top)

    }

 func maxBottom()-> some View{

        self
            .frame(maxHeight:.infinity,alignment: .bottom)
    }

    func maxTop()-> some View{

           self
               .frame(maxHeight:.infinity,alignment: .top)
       }

  func maxTopLeading()->some View{

        self
            .frame(maxWidth:.infinity,maxHeight: .infinity,alignment: .topLeading)

    }
}
