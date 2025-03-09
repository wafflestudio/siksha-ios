//
//  FavoriteView.swift
//  Siksha
//
//  Created by 박종석 on 2021/02/06.
//

import SwiftUI

private extension FavoriteView {
    func typeButton(type: TypeInfo) -> some View {
        Button(action: {
            viewModel.selectedPage = type.id
        }) {
            VStack {
                Image(type.icon)
                    .renderingMode(.template)
                    .resizable()
                    .frame(width: type.width, height: type.height)
                    .foregroundColor(viewModel.selectedPage == type.id ? orangeColor : lightGrayColor)
                    .padding(.leading, type.id == 2 ? 3 : 0)
                    .padding(.bottom, type.id == 1 ? 0 : 2)
                Text(type.name)
                    .font(.custom(viewModel.selectedPage == type.id ? "NanumSquareOTFB" : "NanumSquareOTFR", size: 10))
                    .foregroundColor(viewModel.selectedPage == type.id ? orangeColor : lightGrayColor)
            }
        }
    }
    
    var dayPageTab: some View {
        HStack(alignment: .center) {
            Button(action: {
                viewModel.selectedDate = viewModel.prevDate
            }, label: {
                Image(viewModel.showCalendar ? "PrevDate-disabled" : "PrevDate")
                    .resizable()
                    .frame(width: 10, height: 16)
            })
            .disabled(viewModel.showCalendar)
            .padding(.leading, 16)
            
            Spacer()
            
            Button(action: {
                viewModel.showCalendar.toggle()
            }, label: {
                HStack(alignment: .center, spacing: 0) {
                    Image("Calendar")
                        .renderingMode(.original)
                        .frame(width: 20, height: 22)
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 2, trailing: 4))
                    Text(viewModel.selectedFormatted)
                        .font(.custom("NanumSquareOTFEB", size: 15))
                        .foregroundColor(orangeColor)
                }
            })
            
            Spacer()
            
            Button(action: {
                viewModel.selectedDate = viewModel.nextDate
            }, label: {
                Image(viewModel.showCalendar ? "NextDate-disabled" : "NextDate")
                    .resizable()
                    .frame(width: 10, height: 16)
            })
            .disabled(viewModel.showCalendar)
            .padding(.trailing, 16)
        }
        .frame(height: 50)
    }
    struct CustomSwitchStyle:ToggleStyle{
        func makeBody(configuration: Configuration) -> some View {
            RoundedRectangle(cornerSize: CGSize(width: 9.69, height: 9.69))
                .fill(configuration.isOn ? Color("MainThemeColor") : Color("ReviewLowColor"))
                .frame(width:45,height:19)
                .overlay(
                    Circle()
                        .fill(Color.white)
                        .frame(width:17,height: 17,alignment: .leading)
                        .offset(x: configuration.isOn ? 26.19 : 1.6,y:0)
                    ,alignment: .leading
                )
                .overlay(
                    Text("축제")
                        .foregroundColor(Color.white)
                        .font(.custom("NanumSquareOTFB", size: 9))
                        .offset(x: configuration.isOn ? 6.5 : 21.83,y:0)
                    ,alignment: .leading
                            
                )
                .onTapGesture {
                    withAnimation{
                        configuration.$isOn.wrappedValue.toggle()
                    }
                }
        }
        
    }

    var menuList: some View {
        // Menus
        
        VStack(alignment: .center) {
            if viewModel.getMenuStatus == .loading {
                VStack {
                    Spacer()
                    ActivityIndicator(isAnimating: .constant(true), style: .large)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
            } else {
                if viewModel.restaurantsLists.count > 0 {
                    if viewModel.isFestivalAvailable{
                       ZStack{
                           HStack(alignment: .bottom, spacing: 28) {
                               ForEach(typeInfos) { type in
                                   typeButton(type: type)
                               }
                           }.padding(.top, 8)
                               .frame(alignment: .center)
                           VStack(alignment:   .trailing){
                               Toggle(isOn: $viewModel.isFestival) {
                                  
                               }
                               .toggleStyle(CustomSwitchStyle())
                               .padding(EdgeInsets(top: 5.56, leading: 0, bottom: 0, trailing: 17))

                               
                           }.frame(maxWidth: .infinity,alignment:.trailing)
                           
                       }.frame(maxWidth: .infinity)
                   }
                   else{
                       HStack(alignment: .bottom, spacing: 28) {
                           ForEach(typeInfos) { type in
                               typeButton(type: type)
                           }
                       }.padding(.top, 8)
                       ScrollView(.horizontal,showsIndicators: false){
                    
                    if #available(iOS 15, *) {
                        TabView(selection: $viewModel.selectedPage) {
                            RestaurantsView(viewModel.restaurantsLists[0])
                                .environment(\.favoriteViewModel, viewModel)
                                .tag(0)
                            RestaurantsView(viewModel.restaurantsLists[1])
                                .environment(\.favoriteViewModel, viewModel)
                                .tag(1)
                            RestaurantsView(viewModel.restaurantsLists[2])
                                .environment(\.favoriteViewModel, viewModel)
                                .tag(2)
                        }
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    } else {
                        PageView(
                            currentPage: $viewModel.selectedPage,
                            needReload: $viewModel.pageViewReload,
                            viewModel.restaurantsLists.map { RestaurantsView($0).environment(\.favoriteViewModel, viewModel) })
                    }
                } else {
                    VStack {
                        Spacer()
                        Text("불러온 식단이 없습니다")
                            .font(.custom("NanumSquareOTFB", size: 15))
                            .foregroundColor(fontColor)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    .background(Color.init("AppBackgroundColor"))
                }
            }
        }
        .background(Color.init("AppBackgroundColor"))
    }
}

// MARK: - Favorite View

struct FavoriteView: View {
    @ObservedObject var viewModel = FavoriteViewModel()
    
    private let lightGrayColor = Color.init("LightGrayColor")
    private let orangeColor = Color.init("main")
    private let fontColor = Color("DefaultFontColor")
    
    var typeInfos: [TypeInfo] = [
        TypeInfo(type: .breakfast),
        TypeInfo(type: .lunch),
        TypeInfo(type: .dinner)
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            if(viewModel.isFestivalAvailable){
                            Link(destination: URL(string:"https://www.instagram.com/snufestival/")!){
                                Image("FestivalBanner")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxWidth:.infinity)
                                
                                    
                                
                            }
                        }
            if viewModel.noFavorites {
                Spacer()
                Text("즐겨찾기에 추가된 식당이 없습니다.\n식당 탭에서 별을 눌러 추가해보세요.")
                    .font(.custom("NanumSquareOTFB", size: 14))
                    .foregroundColor(lightGrayColor)
                Spacer()
            } else {
                dayPageTab
                
                ZStack(alignment: .top) {
                    menuList
                    
                    if viewModel.showCalendar {
                        Color.init(.sRGB, white: 0, opacity: 0.6)
                            .onTapGesture {
                                viewModel.showCalendar = false
                            }
                            .transition(.opacity.animation(.easeInOut(duration: 0.3)))
                            .zIndex(1)
                        
                        CalendarView(selectedDate: $viewModel.selectedDate)
                            .frame(height: 300)
                            .padding(EdgeInsets(top: 4, leading: 10, bottom: 15, trailing: 10))
                            .background(Color.white)
                            .transition(.opacity.animation(.easeInOut(duration: 0.3)))
                            .zIndex(2)
                    }
                }
            }
        }
        .customNavigationBar(title: "icon")
        .alert(isPresented: $viewModel.showNetworkAlert, content: {
            Alert(title: Text("식단"), message: Text("식단을 받아오지 못했습니다. 이전에 불러왔던 식단으로 대신 표시합니다."), dismissButton: .default(Text("확인")))
        })
        .onAppear {
            if viewModel.reloadOnAppear {
                viewModel.getMenu(date: viewModel.selectedDate)
            } else {
                viewModel.reloadOnAppear = true
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            viewModel.getMenu(date: viewModel.selectedDate)
        }
    }
}

// MARK: - Preview

struct FavoriteView_Previews: PreviewProvider {
    static var previews: some View {
        FavoriteView()
    }
}
