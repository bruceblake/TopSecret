////
////  AddPollView.swift
////  TopSecret
////
////  Created by Bruce Blake on 10/6/21.
////
//
//import SwiftUI
//import SDWebImageSwiftUI
//
//
//struct AddPollView: View {
//    @Environment(\.presentationMode) var presentationMode
//    @StateObject var pollVM : PollViewModel
//    @EnvironmentObject var userVM: UserViewModel
//    @State var question = ""
//    @State var selectedGroup : Group = Group()
//    @State var pollTypeChoice : Int = 0
//    @State var completionTypeChoice: Int = 0
//    @State var selectedDay = 1
//    @State var selectedHour = 0
//    @State var selectedMinute = 0
//    @State var selectedVisibility: Int = 0
//    @State var showPicker: Bool = false
//    @State var groupUsers : [User] = []
//    @State var selectedUsers : [User] = []
//    @State var selectedUsersIDS : [String] = []
//    @State var choice1: String = ""
//    @State var choice2: String = ""
//    @State var choice3: String = ""
//    @State var choice4: String = ""
//
//    var pollTypes = ["Two Choices","Three Choices","Four Choices","Free Response"]
//    var completionType = ["All Users Voted","Countdown"]
//    var visibleToType = ["All","Select"]
//    var groups: [Group]
//    var creator: String
//    
//    
//    func placeChoices(choiceOption: Int, choices: [String]) -> [String]{
//        var ans : [String] = []
//        if choiceOption == 0{
//            ans = [choices[0],choices[1]]
//        }else if choiceOption == 1{
//            ans = [choices[0],choices[1],choices[2]]
//        }else if choiceOption == 2{
//            ans = [choices[0],choices[1],choices[2],choices[3]]
//        }
//        
//        return ans
//    }
//    
//    func fetchUser(userID: String, completion: @escaping (User) -> ()) -> (){
//        COLLECTION_USER.document(userID).getDocument { (snapshot, err) in
//            if err != nil {
//                print("ERROR")
//                return
//            }
//           
//            
//            let data = snapshot!.data()
//            
//            return completion(User(dictionary: data ?? [:]))
//        }
//    }
//
//    
//    func getText(day: Int, hour: Int, minute: Int) -> String{
//        var result: String = ""
//        var showDay: Bool = false
//        var showHour: Bool = false
//        var showMinute: Bool = false
//        
//        if(day != 0){
//            showDay = true
//        }
//        if (hour != 0){
//            showHour = true
//        }
//        if (minute != 0) {
//            showMinute = true
//        }
//        
//        if(showDay && showHour && showMinute){
//            result = "\(day) days, \(hour) hr, \(minute) minutes"
//        }else if (showDay && showHour && !showMinute){
//            result = "\(day) days, \(hour) hr"
//        }
//        else if (showDay && !showHour && !showMinute){
//            result = "\(day) days"
//        }else if (!showDay && showHour && showMinute){
//            result = "\(hour) hr, \(minute) minutes"
//        }else if(!showDay && !showHour && showMinute){
//            result = " \(minute) minutes"
//        }
//        else if(showDay && !showHour && showMinute){
//            result = "\(day) days, \(minute) minutes"
//        }else if(!showDay && showHour && !showMinute){
//            result = "\(hour) hr"
//        }
//        
//        return result
//        
//    }
//    
//    var body: some View {
//        ZStack(alignment: .topLeading){
//            Color("Background")
//            
//            VStack{
//                
//                HStack{
//                    Spacer(minLength: 0)
//                }.padding(.top,70)
//                
//                //Poll Picker
//                VStack(alignment: .leading){
//                    
//                    HStack{
//                        Text("Poll Type:").bold()
//                        Spacer()
//                        HStack{
//                            Button(action:{
//                                pollTypeChoice -= 1
//                            },label:{
//                                Image(systemName: "chevron.left")
//                            }).disabled(pollTypeChoice == 0).font(.title3)
//                            
//                            Text("\(pollTypes[pollTypeChoice])").bold()
//                            
//                            
//                            Button(action:{
//                                pollTypeChoice += 1
//                            },label:{
//                                Image(systemName: "chevron.right")
//                            }).disabled(pollTypeChoice == 3).font(.title3)
//                        }.padding(.trailing)
//                    }.padding(.leading,5)
//                    
//                    //poll cell types
//                    switch pollTypeChoice {
//                    case 0:
//                        PollCellTwoChoices(question: $question, choice1: $choice1, choice2: $choice2)
//                    case 1:
//                        PollCellThreeChoices(question: $question, choice1: $choice1, choice2: $choice2, choice3: $choice3)
//                    case 2:
//                        PollCellFourChoices(question: $question, choice1: $choice1, choice2: $choice2, choice3: $choice3, choice4: $choice4)
//                    case 3:
//                        PollCellFreeResponse()
//                    default:
//                        Text("Hello World!")
//                    }
//                }.padding().padding(.top,40)
//                
//                
//                //Completion Type
//                HStack{
//                    Text("Completion Type:").bold().padding(.leading)
//                    
//                    Spacer()
//                    
//                    HStack{
//                        Button(action:{
//                            withAnimation(.easeIn) {
//                                self.completionTypeChoice -= 1
//                            }
//                        },label:{
//                            Image(systemName: "chevron.left")
//                        }).disabled(self.completionTypeChoice == 0)
//                        
//                        Text("\(completionType[completionTypeChoice])")
//                        
//                        Button(action:{
//                            withAnimation(.easeIn) {
//                                self.completionTypeChoice += 1
//                            }
//                            
//                        },label:{
//                            Image(systemName: "chevron.right")
//                        }).disabled(self.completionTypeChoice == 1)
//                    }.padding(.trailing)
//                    
//                }
//                
//                if self.completionTypeChoice == 1 {
//                    VStack(){
//                        HStack{
//                            
//                            Text("Poll Duration: ").bold().padding(.leading)
//                            Spacer()
//                            Text(
//                                "\(self.getText(day: selectedDay, hour: selectedHour, minute: selectedMinute))")
//                            Button(action:{
//                                withAnimation(.easeIn){
//                                    self.showPicker.toggle()
//                                }
//                            },label:{
//                                Image(systemName: self.showPicker ? "chevron.up" : "chevron.down")
//                            }).padding(.trailing)
//                            
//                        }
//                        
//                        if self.showPicker{
////                            CountDownPicker(selectedHour: $selectedHour, selectedMinute: $selectedMinute, selectedDay: $selectedDay).padding(.top,30)
//                            HStack(spacing: 40){
//                                
//                                HStack(spacing: 5){
//                                    Text("Days")
//                                    TextField("", value: $selectedDay, formatter: NumberFormatter()).keyboardType(.decimalPad).frame(width: 15, height: 25).background(Color("Color"))
//                                }
//                               
//                                HStack(spacing: 5){
//                                    Text("Hours")
//                                    TextField("", value: $selectedHour, formatter: NumberFormatter()).keyboardType(.decimalPad).frame(width: 15, height: 25).background(Color("Color"))
//                                }
//                               
//                                HStack(spacing: 5){
//                                    Text("Minutes")
//                                    TextField("", value: $selectedMinute, formatter: NumberFormatter()).keyboardType(.decimalPad).background(Color("Color")).frame(width: 15, height: 25)
//                                }
//                               
//                            }
//                        }
//                        
//                    }
//                }
//                
//                
//                //Group
//                HStack{
//                    Text("Group:").bold()
//                    ScrollView(.horizontal, showsIndicators: false){
//                        if !groups.isEmpty{
//                        HStack{
//                            
//                            ForEach(groups, id: \.id){ group in
//                                
//                                
//                                
//                                Button(action:{
//                                    if self.selectedGroup.id != group.id {
//                                        withAnimation(.easeOut){
//                                            selectedGroup = group
//                                        }
//                                        groupUsers = []
//                                        selectedUsersIDS = []
//                                        for userID in selectedGroup.users ?? []{
//                                            self.fetchUser(userID: userID ){ user in
//                                                groupUsers.append(user)
//                                                selectedUsersIDS.append(user.id ?? "")
//                                            }
//                                        }
//                                    }
//                                },label:{
//                                    Text(group.groupName).foregroundColor(selectedGroup.id == group.id ? .red : .white)
//                                }).padding(.horizontal,10).padding(.vertical,5).foregroundColor(FOREGROUNDCOLOR)
//                                .background(RoundedRectangle(cornerRadius: 15).fill(Color("AccentColor")))
//                                
//                            }
//                        }
//                    }else{
//                        Text("No Groups")
//                    }
//                    }
//                }.padding(.leading)
//                
//                
//                VStack{
//                    if selectedGroup.memberAmount != 0 {
//                        
//                        HStack{
//                            Text("Who can see:").foregroundColor(FOREGROUNDCOLOR).bold()
//                            Picker("Options",selection: $selectedVisibility){
//                                ForEach(0..<visibleToType.count){ index in
//                                    Text(self.visibleToType[index]).tag(index)
//                                }
//                            }.pickerStyle(SegmentedPickerStyle())
//                        }.padding(.leading)
//                        
//                    }
//                    
//                    
//                    
//                    //starts off with initalized group
//                    if selectedVisibility != 0 {
//                        ScrollView(.horizontal, showsIndicators: false){
//                            HStack{
//                                ForEach(groupUsers, id: \.self){ user in
//                                    Button(action:{
//                                        if selectedUsers.contains(user){
//                                            selectedUsers.removeAll(where: {$0 == user})
//                                            selectedUsersIDS.removeAll(where: {$0 == user.id})
//                                        }else{
//                                            selectedUsers.append(user)
//                                            selectedUsersIDS.append(user.id ?? "")
//                                        }
//                                    },label:{
//                                        VStack(alignment: .leading){
//                                            HStack{
//                                                
//                                                WebImage(url: URL(string: user.profilePicture ?? ""))
//                                                    .resizable()
//                                                    .scaledToFill()
//                                                    .frame(width:48,height:48)
//                                                    .clipShape(Circle())
//                                                
//                                                Text("\(user.username ?? "")").foregroundColor(FOREGROUNDCOLOR)
//                                                
//                                                Spacer()
//                                                
//                                                Image(systemName: selectedUsersIDS.contains(user.id ?? "") ? "checkmark.circle.fill" : "circle").font(.title)
//                                                
//                                            }.padding(10)
//                                        }
//                                })
//                                }
//                                    
//                            }.background(Color("Color")).cornerRadius(16)
//                        }.padding(.horizontal)
//                    }
//                }.animation(.easeOut, value: selectedVisibility)
//                
//                
//                
//                Button(action: {
//                    //TODO
//                    let id = UUID().uuidString
//                    pollVM.createPoll(creator: creator, question: question, group: selectedGroup, pollType: pollTypes[pollTypeChoice], days: selectedDay, hours: selectedHour, minutes: selectedMinute, choices: self.placeChoices(choiceOption: pollTypeChoice, choices: [choice1,choice2,choice3,choice4]), completionType: completionType[completionTypeChoice], users: selectedUsersIDS, id: id)
//                  
//                  
//                }, label: {
//                    Text("Create Poll")   .foregroundColor(Color("Foreground"))
//                        .padding(.vertical)
//                        .frame(width: UIScreen.main.bounds.width/1.5).background(Color("AccentColor")).cornerRadius(15)
//                }).padding()
//                
//                
//                
//                
//                
//                
//                //end main vstack
//            }
//            
//            HStack{
//                Button(action:{
//                    presentationMode.wrappedValue.dismiss()
//                },label:{
//                    Image(systemName: "chevron.left")
//                })
//                
//                Spacer()
//                
//                Text("Create Poll").font(.title3)
//                
//                Spacer()
//            }.padding(.top,70).padding(.leading,10)
//            
//        }
//           
//        .edgesIgnoringSafeArea(.all).navigationBarHidden(true).onAppear{
//           
//        }
//    }
//}
//
//
//struct PollCellTwoChoices : View {
//    @Binding var question: String
//    @Binding var choice1: String
//    @Binding var choice2: String
//    var body: some View {
//        VStack(spacing: 0){
//            
//            VStack{
//                TextField("Question", text: $question).padding()
//                Divider()
//            }
//            
//            
//            
//            HStack(alignment: .center, spacing: 0){
//                TextField("", text: $choice1).padding(.leading).placeholder(when: choice1.isEmpty, placeholder: { Text("CHOICE ONE").padding().foregroundColor(Color.red)
//                }).foregroundColor(Color.red).padding(.leading,30)
//                Divider()
//                TextField("", text: $choice2).padding(.leading).placeholder(when: choice2.isEmpty, placeholder: { Text("CHOICE TWO").padding().foregroundColor(Color.green)
//                }).foregroundColor(Color.green).padding(.leading,20)
//            }
//        }.frame(height: 200).background(Color("Color")).cornerRadius(16)
//    }
//}
//
//struct PollCellThreeChoices : View {
//    @Binding var question: String
//    @Binding var choice1: String
//    @Binding var choice2: String
//    @Binding var choice3: String
//    var body: some View {
//        VStack{
//            TextField("Question", text: $question).padding(.leading)
//            Divider()
//            VStack(alignment: .leading){
//                TextField("", text: $choice1).padding(.leading).placeholder(when: choice1.isEmpty, placeholder: { Text("CHOICE ONE").padding(5).foregroundColor(Color.red)
//                }).foregroundColor(Color.red)
//                Divider()
//                TextField("", text: $choice2).padding(.leading).placeholder(when: choice2.isEmpty, placeholder: { Text("CHOICE TWO").padding(5).foregroundColor(Color.green)
//                }).foregroundColor(Color.green)
//                Divider()
//                TextField("", text: $choice3).padding(.leading).placeholder(when: choice3.isEmpty, placeholder: { Text("CHOICE THREE").padding(5).foregroundColor(Color.blue)
//                }).foregroundColor(Color.blue)
//            }
//        }.frame(height: 200).background(Color("Color")).cornerRadius(16)
//    }
//}
//
//struct PollCellFourChoices : View {
//    @Binding var question: String
//    @Binding var choice1: String
//    @Binding var choice2: String
//    @Binding var choice3: String
//    @Binding var choice4: String
//    var body: some View {
//        VStack(spacing: 0){
//            
//            
//            TextField("Question", text: $question)
//                .padding()
//            
//            Divider()
//            
//            VStack(spacing: 0){
//                HStack(alignment: .center, spacing: 0){
//                    
//                    
//                    
//                    
//                    TextField("", text: $choice1).placeholder(when: choice1.isEmpty, placeholder: { Text("CHOICE ONE").foregroundColor(Color.red)
//                    }).foregroundColor(Color.red).padding(.leading,40)
//                    
//                    
//                    
//                    Divider().frame(maxHeight: .infinity)
//                    
//                    TextField("", text: $choice2).placeholder(when: choice2.isEmpty, placeholder: { Text("CHOICE TWO").foregroundColor(Color.green)
//                    }).foregroundColor(Color.green).padding(.leading,40)
//                    
//                    
//                }
//                
//                Divider().frame(maxWidth: .infinity)
//                
//                HStack(alignment: .center, spacing: 0){
//                    
//                    TextField("", text: $choice3).placeholder(when: choice3.isEmpty, placeholder: { Text("CHOICE THREE").foregroundColor(Color.blue)
//                    }).foregroundColor(Color.blue).padding(.leading,40)
//                    
//                    
//                    
//                    Divider().frame(maxHeight: .infinity)
//                    
//                    TextField("", text: $choice4).placeholder(when: choice4.isEmpty, placeholder: { Text("CHOICE FOUR").foregroundColor(Color.orange)
//                    }).foregroundColor(Color.orange).padding(.leading,40)
//                    
//                    
//                }
//            }
//            
//        }.frame(height: 200).background(Color("Color")).cornerRadius(16)
//    }
//}
//
//struct PollCellFreeResponse : View {
//    @State var question: String = ""
//    var body: some View {
//        VStack{
//            TextField("Question", text: $question).padding()
//            Divider()
//            Spacer()
//            Text("Response").padding()
//            Spacer()
//        }.frame(height: 200).background(Color("Color")).cornerRadius(16)
//    }
//}
//
//
//
////struct AddPollView_Previews: PreviewProvider {
////    static var previews: some View {
////        AddPollView(pollVM:  PollViewModel(), pollTypeChoice: 2).environmentObject(UserViewModel()).colorScheme(.dark)
////    }
////}
//
//
//
//extension View {
//    func placeholder<Content: View>(
//        when shouldShow: Bool,
//        alignment: Alignment = .leading,
//        @ViewBuilder placeholder: () -> Content
//    ) -> some View {
//        ZStack(alignment: alignment){
//            placeholder().opacity(shouldShow ? 1 : 0)
//            self
//        }
//    }
//}
