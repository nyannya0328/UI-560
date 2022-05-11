//
//  AddNewHabit.swift
//  UI-560
//
//  Created by nyannyan0328 on 2022/05/11.
//

import SwiftUI

struct AddNewHabit: View {
    @Environment(\.self) var env
    @EnvironmentObject var  model : HabitViewModel
    var body: some View {
        NavigationView{
            
            VStack(spacing:15){
                
                
                TextField("Title", text: $model.title)
                    .padding(.vertical,10)
                    .padding(.horizontal)
                
                
                    .background{
                        
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(Color("TFBG"))
                    }
                
                HStack(spacing:0){
                    
                    ForEach(1...7,id:\.self){index in
                        
                        let color = "Card-\(index)"
                        
                        Circle()
                            .fill(Color(color))
                            .frame(width: 35, height: 35)
                            .lCenter()
                            .overlay {
                                
                                if color == model.habitColor{
                                    
                                    
                                    Image(systemName: "checkmark")
                                        .font(.caption)
                                        
                                }
                                
                                
                            }
                            .onTapGesture {
                                
                                withAnimation{
                                    
                                    model.habitColor = color
                                }
                                
                                
                                
                                
                            }
                    }
                }
                .padding(.vertical)
                
                
                VStack(alignment: .leading, spacing: 15) {
                    
                    Text("FreeQuency")
                        .font(.callout.weight(.semibold))
                    
                    HStack(spacing:15){
                        
                        
                        let weekDays = Calendar.current.weekdaySymbols
                        
                        ForEach(weekDays,id:\.self){day in
                            
                            let index = model.weekDays.firstIndex { value in
                                
                                return value == day
                            } ?? -1
                            
                            Text(day.prefix(2))
                                .lCenter()
                                .padding(.vertical,8)
                                .background{
                                    
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .fill(index != -1 ? Color(model.habitColor) : Color("TFBG").opacity(0.4))
                                    
                                }
                                .onTapGesture {
                                    
                                    if index != -1{
                                        
                                        model.weekDays.remove(at: index)
                                        
                                    }
                                    else{
                                        
                                        model.weekDays.append(day)
                                    }
                                    
                                    
                                }
                                
                        }
                    }
                        
                }
                .lLeading()
                
                
                HStack{
                    
                    VStack(alignment: .leading, spacing: 15) {
                        
                        
                        Text("Remaider")
                            .font(.title.weight(.semibold))
                        
                        Text("Roki Notification")
                            .font(.caption.weight(.semibold))
                            .foregroundColor(.gray)
                    }
                    .lLeading()
                    
                    
                    Toggle(isOn: $model.isRemainderOn) {}
                    .labelsHidden()
                }
            
                .padding(.vertical,20)
                
                HStack{
                    
                    Label {
                        
                        Text(model.remainderDate.formatted(date: .omitted, time: .shortened))
                        
                        
                    } icon: {
                        
                        Image(systemName: "clock")
                        
                    }
                    .foregroundColor(.white)
                    .padding(.vertical,13)
                    .padding(.horizontal)
                    .background(
                    
                        Color("TFBG").opacity(0.4),in:RoundedRectangle(cornerRadius: 10, style: .continuous)
                    
                    )
                    .onTapGesture {
                        
                        withAnimation{
                            
                            model.showPicker.toggle()
                        }
                    }
                    
                    TextField("Title", text: $model.remainderText)
                        .padding(.vertical,13)
                        .padding(.horizontal)
                        .background(
                        
                            Color("TFBG").opacity(0.4),in:RoundedRectangle(cornerRadius: 10, style: .continuous)
                        
                        )
                    
                    
                   
                    
                    
                    


                }
                .frame(height: model.isRemainderOn ? nil : 0)
               .opacity(model.isRemainderOn ? 1 : 0)
             .opacity(model.notificationAcces ? 1 : 0)
              
                
                
                
            }
            .padding()
            .animation(.easeInOut, value: model.isRemainderOn)
            .maxTop()
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarTitle(model.edtiHabit != nil ? "Edit Habit" : "Add Habit")
            .toolbar {
                
                
                ToolbarItem(placement: .navigationBarLeading) {
                    
                    Button {
                        env.dismiss()
                        
                    } label: {
                        
                        Image(systemName: "xmark.circle.fill")
                            .font(.title3)
                            .foregroundColor(.white)
                    }

                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    
                    Button {
                        
                        if model.deleteHabit(context: env.managedObjectContext){
                            
                            env.dismiss()
                        }
                   
                        
                    } label: {
                        
                        Image(systemName: "trash")
                            .font(.title3)
                            .foregroundColor(.red)
                    }

                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    
                    Button("Done"){
                        
                        Task{
                            
                            if await model.addHabit(context: env.managedObjectContext){
                                
                                env.dismiss()
                            }
                        }
                        
                    }
                    .tint(.white)
                    .disabled(!model.doneStatus())
                    .opacity(model.doneStatus() ? 1 : 0.5)

                }
                
                
                
                
                
            }
            .overlay {
                
                ZStack{
                    
                    if model.showPicker{
                        
                        Rectangle()
                            .fill(.ultraThinMaterial)
                            .onTapGesture {
                                model.showPicker.toggle()
                            }
                        
                        DatePicker.init("", selection: $model.remainderDate,displayedComponents: [.hourAndMinute])
                            .datePickerStyle(.wheel)
                            .labelsHidden()
                            .padding()
                            .background{
                                
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color("TFBG"))
                            }
                            .padding()
                    }
                }
                .ignoresSafeArea()
                
            }
            
            
            
        }
    }
    
    
}

struct AddNewHabit_Previews: PreviewProvider {
    static var previews: some View {
        AddNewHabit()
            .preferredColorScheme(.dark)
            .environmentObject(HabitViewModel())
           
    }
}
