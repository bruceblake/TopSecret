//
//  CreatePollView.swift
//  Top Secret
//
//  Created by Bruce Blake on 8/1/22.
//

import SwiftUI

struct CreatePollView: View {
    
    
    @Environment(\.presentationMode) var presentationMode
    @StateObject var createPollVM = CreatePollViewModel()
    @EnvironmentObject var userVM : UserViewModel
    @State var optionsCount = 0
    @State var options : [PollOptionModel] = []
    @State var question = ""
    @State var choice1 = ""
    @State var choice2 = ""
    @State var choice3 = ""
    @State var choice4 = ""
    @EnvironmentObject var groupVM : SelectedGroupViewModel
    var body: some View {
        ZStack{
            Color("Background")
            VStack{
                HStack{
                    Button(action:{
                        presentationMode.wrappedValue.dismiss()
                    },label:{
                        ZStack{
                            Circle().foregroundColor(Color("Color")).frame(width: 40, height: 40)
                            Image(systemName: "chevron.left").foregroundColor(FOREGROUNDCOLOR)
                        }.padding(.leading)
                        
                        
                        Spacer()
                        
                        Text("Create A Poll").foregroundColor(FOREGROUNDCOLOR).font(.title2).bold()
                        
                        Spacer()
                        
                        Circle().foregroundColor(Color.clear).frame(width: 40, height: 40)
                    })
                }.padding(.top,50)
                
                
                VStack(spacing: 20){
                    VStack(alignment: .leading){
                        Text("Question").foregroundColor(FOREGROUNDCOLOR).fontWeight(.bold)
                        VStack{
                            CustomTextField(text: $question, placeholder: "Group Name", isPassword: false, isSecure: false, hasSymbol: false ,symbol: "")
                        }
                    }.padding(.horizontal)
                    
                    VStack(alignment: .leading){
                        Text("Options").foregroundColor(FOREGROUNDCOLOR).fontWeight(.bold)
                        ScrollView{
                            VStack(spacing: 10){
                                
                            CustomTextField(text: $choice1, placeholder: "Option 1")
                            CustomTextField(text: $choice2, placeholder: "Option 2")
                            CustomTextField(text: $choice3, placeholder: "Option 3")
                            CustomTextField(text: $choice4, placeholder: "Option 4")
                          
                            }
                        }
                      
                    }.padding(.horizontal)
                    
                    Spacer()
                     
                    
                    Button(action:{
                        createPollVM.createPoll(creatorID: userVM.user?.id ?? " ", pollOptions: [PollOptionModel(dictionary: ["id":UUID().uuidString,"choice":choice1,"pickedUsers":[]]),
                            PollOptionModel(dictionary: ["id":UUID().uuidString,"choice":choice2,"pickedUsers":[]]),
                            PollOptionModel(dictionary: ["id":UUID().uuidString,"choice":choice3,"pickedUsers":[]]),
                                                                                                 PollOptionModel(dictionary: ["id":UUID().uuidString,"choice":choice4,"pickedUsers":[]])                                                       ], groupID: groupVM.group.id ?? " ", question: question, usersVisibleToID: groupVM.group.users ?? [])
                        presentationMode.wrappedValue.dismiss()
                    },label:{
                        Text("Create Poll").foregroundColor(Color("Foreground"))
                            .padding(.vertical)
                            .frame(width: UIScreen.main.bounds.width/1.5).background(Color("AccentColor")).cornerRadius(15)
                    }).padding(.bottom,30)
                  
                    
                }
                
                
                
                
                
            }
        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true)
    }
}





