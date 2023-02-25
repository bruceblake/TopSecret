//
//  GroupPostCommentCell.swift
//  Top Secret
//
//  Created by Bruce Blake on 12/15/22.
//

import SwiftUI
import Firebase
import SDWebImageSwiftUI

struct GroupPostCommentCell: View {
    var comment: GroupPostCommentModel
    var body: some View {
        VStack(alignment: .leading){
            HStack(spacing: 10){
                WebImage(url: URL(string: comment.creator?.profilePicture ?? ""))
                    .resizable()
                    .scaledToFill()
                    .frame(width:40,height:40)
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 8){
                    Text("\(comment.creator?.username ?? "")").font(.subheadline).bold()
                    Text("\(comment.text ?? "")").font(.subheadline)
                }
                Spacer()
                
                
                Text("\(comment.timeStamp?.dateValue() ?? Date(), style: .time)").foregroundColor(Color.gray).font(.caption)
            }
            
        }.padding(.horizontal,10)
      
    }
}

