//
//  ActivityView.swift
//  Top Secret
//
//  Created by Bruce Blake on 4/16/22.
//

import SwiftUI

struct ActivityView: View {
    
    @EnvironmentObject var userVM : UserViewModel
    var body: some View {
        ZStack{
            Color("Background")
            VStack{
                
                VStack{
                    Text("Members").foregroundColor(FOREGROUNDCOLOR)
                    ScrollView(.horizontal, showsIndicators: false){
                        HStack{
                            ForEach(userVM.userSelectedGroup.users ?? [], id: \.self){ userID in
                                Button(action:{
                                    
                                },label:{
                                    Text(userID).foregroundColor(FOREGROUNDCOLOR)
                                })
                            }
                        }
                    }
                }
                
             
            }
        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true)
    }
}

struct ActivityView_Previews: PreviewProvider {
    static var previews: some View {
        ActivityView().environmentObject(UserViewModel()).colorScheme(.dark)
    }
}
