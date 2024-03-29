//
//  ContentView.swift
//  SafetyCard
//
//  Created by Sarah Mautsch on 09.03.20.
//  Copyright © 2020 Sarah Mautsch. All rights reserved.
//

import SwiftUI

struct SafetyCard: View {
    
    @State var showingPrivacyPolicy : Bool = false
    @State var showingEULA : Bool = false
    @Binding var isPresented : Bool
    
    
    var body: some View {
        VStack (spacing: 0) {
            Header(isPresented: $isPresented)
                .zIndex(1)
            ScrollView{
                Headline()
                VStack(alignment: .leading){
                    VStack(alignment: .leading) {
                        ChapterHeadline(icon: "umbrella", name: "How we treat your data", subline: "Designed to be used offline.")
                        How(showingPrivacyPolicy: $showingPrivacyPolicy)
                    }
                    .padding(.vertical, 24)
                    
                    VStack(alignment: .leading) {
                        ChapterHeadline(icon: "eyeglasses", name: "Anonymisation", subline: "On-device machine learning.")
                        Anonymisation()
                    }
                    .padding(.vertical, 24)
                    
                    VStack(alignment: .leading) {
                        ChapterHeadline(icon: "questionmark.circle", name: "Frequently Asked", subline: "")
                        FAQ()
                    }
                    .padding(.vertical, 24)

                    
                    VStack(alignment: .leading) {
                        ChapterHeadline(icon: "info.circle", name: "Want to learn more?", subline: "")
                        LearnMore(showingPrivacyPolicy: $showingPrivacyPolicy, showingEULA: $showingEULA)
                    }
                    .padding(.vertical, 24)
                }
            }
            .background(
                Color("background")
                    .edgesIgnoringSafeArea(.bottom)
            )
        }
        .background(
            Color("highlight")
            .edgesIgnoringSafeArea(.top)
        )
    }
}


struct Header: View {
    
    @Binding var isPresented : Bool
        
    var body: some View {
        HStack (alignment: .top) {
            HStack(spacing: 8) {
                Image("AnonymousCamera")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 36, height: 36)
                .foregroundColor(Color("text"))
                .accessibility(hidden: true)
                
                Text("Safety & Privacy")
                    .font(Font.system(size: 16, weight: .semibold))
                    .foregroundColor(Color("text"))
                    
            }
            .padding(.leading, 16)
            .padding(.vertical, 16)
            
            Spacer()
            
            ZStack(alignment: .center) {
                  Circle()
                  .frame(width: 30, height: 30)
                  .foregroundColor(Color("systemlightgrey").opacity(0.9))
                  Image(systemName: "xmark")
                  .font(Font.system(size: 14, weight: .semibold))
                  .foregroundColor(Color("systemdarkgrey").opacity(0.9))
                 
                .onTapGesture {
                     self.isPresented.toggle()
                  }
                
              }
              .padding(.trailing, 14)
              .padding(.top, 18)
            
        }
        .background(
            Color(UIColor.tertiarySystemBackground)
            .edgesIgnoringSafeArea(.top)
        )
            .shadow(color: Color.black.opacity(0.12), radius: 24, x: 0, y: 0)
    }
}

struct Headline: View {
    var body: some View {
        HStack{
            VStack(alignment: .leading){
                Spacer()
                
                VStack(alignment: .leading, spacing: 16) {
                    
                    Text("Let’s talk \nabout data.")
                        .font(Font.system(size: 48, weight: .semibold))
                        .foregroundColor(Color("ignoredarkmode"))
                 
                    HStack {
                        HStack {
                            Text("tl;dr")
                                .font(Font.system(size: 21, weight: .semibold))
                                .foregroundColor(Color("ignoredarkmode").opacity(0.5))
                                
                                .frame(width: 60, height: 30)
                                .background(Color("ignoredarkmode").opacity(0.2))
                            .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                        }
                        
                        
                        Text("It’s none of our business.")
                            .font(Font.system(size: 21, weight: .semibold))
                        .foregroundColor(Color("ignoredarkmode").opacity(0.4))
                            .multilineTextAlignment(.leading)
                    }
                }
            }
            .frame(height: 375)
          
        }
        .padding(.bottom, 16)
        .frame(maxWidth: .infinity)
        .background(
            Color("highlight")
            .edgesIgnoringSafeArea(.top)
        )
    }
}

struct How: View {
    @Binding var showingPrivacyPolicy : Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 32){
            
            VStack(alignment: .leading, spacing: 12){
                DataBulletpoint(content: "All processing is done on device.")
                DataBulletpoint(content: "We never upload to the cloud.")
                DataBulletpoint(content: "We retain data locally in the app for a short time for processing.")
            }
            .padding(.horizontal, 16)
  
            
            VStack {
                HStack {
                    Image("FlightMode")
                        .accessibility(label: Text("active flight mode"))
                    VStack(alignment: .leading, spacing: 8){
                        Text("Try us!".uppercased())
                        .font(Font.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(Color("lightblue"))
                        Text("Designed to be used offline.")
                        .font(Font.system(size: 21, weight: .regular))
                        .foregroundColor(Color("text").opacity(0.8))
                    }
                }
                .padding(.vertical, 16)
                .frame(maxWidth: .infinity)
                .background(Color("lightblue").opacity(0.02))
            }
            
            
            VStack (alignment: .leading, spacing: 12) {
                HStack {
                    Text("Learn More".uppercased())
                        .font(Font.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(Color("lightblue"))
                }.padding(.horizontal, 32)
                
                Button(action: {
                    self.showingPrivacyPolicy.toggle()
                }) {
                    DocumentButton(title: "Privacy Policy", icon: "doc.text.fill", readingtime: "12 min read")
                }
                .sheet(isPresented: $showingPrivacyPolicy) {
                    PrivacyPolicyView(isPresented: self.$showingPrivacyPolicy)
                }
                
                //DocumentButton(title: "Privacy Policy", icon: "doc.text.fill", readingtime: "30 min read")
            }
          
            
        }
    }
}








struct Anonymisation: View {
    var body: some View {
        ScrollView (.horizontal, showsIndicators: false) {
                HStack {
                    AnonymisationCard(title: "Quality of Anonymisation", image: "1Quality", description: "Anonymous Camera attempts to recognise faces and full bodies locally on device. Keep in mind that there’s always a possibility that a face is not recognised, so always make sure to double-check.")
                        .padding(.leading, 32)
                        .padding(.trailing, 8)
                    
                    AnonymisationCard(title: "Adverserial Attacks", image: "2Reversibility", description: "Keep in mind that bad actors might always have way to reverse anonymisation to some degree. In critical circumstances, always select “Solid” over “Blur” as it destroys, rather than transform image data.")
                        .padding(.leading, 8)
                        .padding(.trailing, 8)
                    
                    AnonymisationCard(title: "Retention of Data", image: "3Retention", description: "Buffers persist only for the milliseconds they are presented and used for. Anonymous Camera stores images for only a fraction of a second on device to apply the filter. All data removed immediately once it’s processed.")
                        .padding(.leading, 8)
                        .padding(.trailing, 32)

                }
        }
        .background(Color.clear)
        .shadow(color: Color.black.opacity(0.12), radius: 12, x: 0, y: 0)

    }
}

struct FAQ: View {
    var body: some View {
        VStack {
            FAQitem(no: "01", title: "How does it work?", description: "Using proprietary software, Anonymous Camera is able to blur or mask subjects’ faces such that no biometric information can be captured or stored. The blur function performs during subject movement and under harsh lighting conditions. Any files saved by the user will have time, location and other identifiable data removed.")
            FAQitem(no: "02", title: "What is happening with the pre-blurred information gathered?", description: "We store images for a matter of milliseconds on the user’s device to apply the filter. They are then removed and not stored anywhere else. The biometric information of the blurred subjects is not saved prior to blurring, ensuring a secure means of anonymization.")
            FAQitem(no: "03", title: "Is the app foolproof?", description: "No. Even with a hidden face, other metadata within the image could potentially identify someone. A location, certain traits, even the way a person moves. Users should be aware of these factors as well and exercise caution about recording someone if they deem the risk to be too high. Our body detection feature - which can blur a subject’s entire person - can help mitigate some of that risk.")
            FAQitem(no: "04", title: "Who is Playground?", description: "We are a product company that builds data capture products with users’ privacy at the forefront of everything we do. We focus on creating ethical data and AI products in an era when our data and privacy has never been more at risk.")
            FAQitem(no: "05", title: "Why did you build Anonymous Camera?", description: "Our app seeks to provide an answer to the growing reality of facial recognition - supplying users with an alternative to standard applications that capture so much more than just a photo. \n\nWhile we believe anyone can make use of the app, our target consumer is investigative journalists and NGOs who interact daily with sensitive information and with people in need of protection.")
            FAQitem(no: "06", title: "How do you make money?", description: "The app is free to download. We charge a small fee for our pro features and to remove our watermark from the video files you capture.")
            FAQitem(no: "07", title: "Is the code accessible and open source?", description: "The code is currently not open source, but we are working to make it so. User trust and confidence is important to us, and we believe that making our code open source is a good way to earn it.")
        }
    }
}


struct LearnMore: View {
    
    @Binding var showingPrivacyPolicy : Bool
    @Binding var showingEULA : Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button(action: {
                self.showingPrivacyPolicy.toggle()
            }) {
                DocumentButton(title: "Privacy Policy", icon: "doc.text.fill", readingtime: "12 min read")
            }
            .sheet(isPresented: $showingPrivacyPolicy) {
                PrivacyPolicyView(isPresented: self.$showingPrivacyPolicy)
            }
            
            
            Button(action: {
                self.showingEULA.toggle()
            }) {
                DocumentButton(title: "Terms of Use", icon: "checkmark.seal.fill", readingtime: "15 min read")
            }
            .sheet(isPresented: $showingEULA) {
                EULAView(isPresented: self.$showingEULA)
            }
        }
    }
}

struct DataBulletpoint: View {
    var content: String
    
    var body: some View {
        HStack(alignment: .center){
            Image(systemName: "checkmark.circle.fill")
                .frame(width: 32, height: 32)
                .font(Font.system(size: 21, weight: .medium, design: .rounded))
                .foregroundColor(Color("lightblue"))
            
            Text(content)
                .font(Font.system(size: 21, weight: .regular))
                .lineSpacing(1.5)
                .foregroundColor(Color("text").opacity(0.8))
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

struct ChapterHeadline: View {
    var icon: String
    var name: String
    var subline: String
    
    var body: some View {
        HStack(alignment: .center, spacing: 12){
            
            Rectangle()
            .frame(width: 6, height: 56, alignment: .center)
            .foregroundColor(Color("highlight"))
            
            Image(systemName: icon)
            .foregroundColor(Color("lightblue"))
            .font(Font.system(size: 21, weight: .semibold))
            
            VStack(alignment: .leading, spacing: 6) {
                Text(name)
                    .font(Font.system(size: 21, weight: .semibold))
                    .foregroundColor(Color("text"))
          
                if subline != "" {
                    Text(subline)
                        .font(Font.system(size: 16, weight: .semibold))
                        .foregroundColor(Color("lightblue"))
                }
            }
        }
    }
}

struct DocumentButton: View {
    var title: String
    var icon: String
    var readingtime: String
    
    var body: some View {
        HStack {
            
            HStack {
                HStack(spacing: 12) {
                    Image(systemName: icon)
                    Text(title)
                }.foregroundColor(Color("darkblue"))
                    .font(Font.system(size: 18, weight: .medium))
                Spacer()
                HStack {
                    Text(readingtime.uppercased())
                        .font(Font.system(size: 14, weight: .semibold))
                    Image(systemName: "chevron.right")
                        .font(Font.system(size: 15, weight: .semibold))
                }.foregroundColor(Color("darkblue").opacity(0.5))
                
            }
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(Color("lightblue").opacity(0.08))
            .cornerRadius(12)
        }
        .padding(.horizontal, 16)
    }
}

struct Blur: UIViewRepresentable {
    var style: UIBlurEffect.Style = .systemMaterial
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: style))
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: style)
    }
}

struct AnonymisationCard: View {
    var title: String
    var image: String
    var description: String
    
    var body: some View {
        VStack {
            VStack(alignment: .leading){
                HStack(alignment: .firstTextBaseline){
                    Text(title)
                    .font(Font.system(size: 16, weight: .semibold, design: .rounded))
                    .kerning(0.3)
                    .foregroundColor(Color("darkblue").opacity(0.9))
                    .frame(maxWidth: .infinity, alignment: .leading)
                   // Spacer()
                }
                .padding(.bottom, 16)
            }
            ZStack(alignment: .bottom) {
                Image(image)
                .accessibility(hidden: true)
            }
            Spacer()
            VStack(alignment: .leading){
                HStack(alignment: .bottom){
                    Text(description)
                    .font(Font.system(size: 15, weight: .regular, design: .serif))
                    .foregroundColor(Color("text"))
                    //.frame(maxWidth: .infinity, alignment: .leading)
                    .lineSpacing(7)
                }
            }
        }
        .padding(32)
        .frame(maxWidth: 300)
        .frame(height: 450)
        .background(Color("cardbackground"))
        .cornerRadius(24)
    }
}

struct FAQitem: View {
    var no: String
    var title: String
    var description: String
   
    @State var isOpen : Bool = false
    
    var body: some View {
        VStack {
            HStack(alignment: .firstTextBaseline) {
                Text(no)
                    .font(Font.system(size: 16, weight: .regular, design: .monospaced))
                    .foregroundColor(Color("lightblue").opacity(0.8))
                Text(title)
                    .font(Font.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(isOpen ? "darkblue" : "lightblue"))
                    .lineSpacing(6)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer()
                Image(systemName: isOpen ? "minus.circle" : "plus.circle")
                    .font(Font.system(size: 16, weight: .semibold))
                    .foregroundColor(Color("darkblue"))
            }
        
            if isOpen{
                    Text(description)
                        .font(Font.system(size: 16, weight: .regular))
                        .foregroundColor(Color("text"))
                        .lineSpacing(6)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, 12)
            }
           
                
        }

        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity)
        .clipped()
        .overlay(
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .stroke(lineWidth: 1)
                .foregroundColor(Color("lightblue").opacity(0.2))
        )
        .padding(.horizontal, 16)
        
        
        .onTapGesture {
            withAnimation(Animation.spring()) {
                   self.isOpen.toggle()
            }
        }
        .transition(.opacity)
        .animation(Animation.easeInOut)

    }
}
