//
//  AddContentView.swift
//  TopSecret
//
//  Created by Bruce Blake on 2/21/22.
//

import SwiftUI

struct AddContentView: View {
    
    @Binding var showAddContentView: Bool
    @Binding var group: Group
    @EnvironmentObject var selectedGroupVM : SelectedGroupViewModel
    
    var texts : [String] = ["Create Countdown", "Create Poll","Create Event","Add to Group Story","Send Group Invitation to Friend"]
     
    
    var body: some View {
        ZStack(alignment: .top){
            Color("Color")
            VStack(){
                
                ForEach(texts, id: \.self){ text in
                    NavigationLink {
                        switch(text){
                        case "Create Countdown":
                            CreateCountdownView(group: $group)
                        case "Create Event":
                            GeometryReader{ reader in
                                CreateEventView().frame(width: reader.size.width, height: reader.size.height).environmentObject(selectedGroupVM)
                            }
                        case "Add to Group Story":
                            CreateStoryPostView()
                            
                        case "Send Group Invitation to Friend":
                            InviteUserToGroup(group: $group)
                        default:
                            EmptyView()
                        }
                    } label: {
                        Text(texts[texts.firstIndex(of: text) ?? 0]).fontWeight(.bold).foregroundColor(Color("AccentColor")).padding(.vertical,10).frame(width: UIScreen.main.bounds.width/1.2).background(Color("Background")).cornerRadius(15)
                    }.padding(.vertical,5).padding(.top,5)

                }
               

            }
        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true)
        
    }
}


struct JoinGroup : View {
    
    @Environment(\.presentationMode) var presentationMode
    @State var userID : String = ""
    
    var body: some View {
        ZStack{
            Color("Color")
            
            VStack{
                
                HStack{
                    Button(action:{
                        presentationMode.wrappedValue.dismiss()
                    },label:{
                        Text("Back")
                    })
                    Spacer()
                }
                
                
                Spacer()
                
                SearchView()
                
                TextField("User ID", text: $userID)
            }
        }
    }
    
}

//struct AddContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        AddContentView()
//    }
//}
