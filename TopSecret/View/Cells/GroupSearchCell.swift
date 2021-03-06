//
//  GroupSearchCell.swift
//  TopSecret
//
//  Created by Bruce Blake on 2/7/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct GroupSearchCell: View {
    var group : Group
    var body: some View {
        VStack(alignment: .leading){
            HStack(alignment: .center){
                WebImage(url: URL(string: group.groupProfileImage ?? ""))
                    .resizable()
                    .scaledToFill()
                    .frame(width:48,height:48)
                    .clipShape(Circle())
                    
                
                VStack(alignment: .leading){
                    
                    Text("\(group.groupName)").foregroundColor(Color("Foreground"))
                    Text("\(group.users?.count ?? 0) \(group.users?.count ?? 0 > 1 ? "members" : "member")").foregroundColor(.gray)
                    

                }
                Spacer()
            }.padding([.leading,.vertical])
            Divider()
        }
    .edgesIgnoringSafeArea(.all)
    }
}

//struct GroupSearchCell_Previews: PreviewProvider {
//    static var previews: some View {
//        GroupSearchCell()
//    }
//}
