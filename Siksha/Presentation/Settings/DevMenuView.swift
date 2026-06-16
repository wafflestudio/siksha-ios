//
//  DevMenuView.swift
//  Siksha
//
//  Created by Jihyeon on 2/25/26.
//

import SwiftUI
import Alamofire

struct DevMenuView: View {
    @StateObject private var viewModel = DevMenuViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                inputSection

                apiCard(for: .dailyMenus) {
                    apiButton(for: .dailyMenus, title: "호출") {
                        Task { await viewModel.fetchDailyMenus() }
                    }
                }

                apiCard(for: .personalRestaurants) {
                    apiButton(for: .personalRestaurants, title: "호출") {
                        Task { await viewModel.fetchPersonalRestaurants() }
                    }
                }

                apiCard(for: .restaurantLike) {
                    Toggle("liked", isOn: $viewModel.restaurantLikeValue)
                    apiButton(for: .restaurantLike, title: "liked 적용") {
                        Task { await viewModel.setRestaurantLike() }
                    }
                }

                apiCard(for: .restaurantVisible) {
                    Toggle("visible", isOn: $viewModel.restaurantVisibleValue)
                    apiButton(for: .restaurantVisible, title: "visible 적용") {
                        Task { await viewModel.setRestaurantVisible() }
                    }
                }

                apiCard(for: .restaurantOrder) {
                    HStack(spacing: 8) {
                        apiButton(for: .restaurantOrder, title: "현재 순서 조회") {
                            Task { await viewModel.fetchRestaurantOrder() }
                        }
                        apiButton(for: .restaurantOrder, title: "순서 적용") {
                            Task { await viewModel.setRestaurantOrder() }
                        }
                    }
                }
            }
            .padding(20)
        }
    }

    private var inputSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("공통 테스트 입력")
                .customFont(font: .text13(weight: .Bold))
                .foregroundColor(Color.gray800)

            labeledTextField(
                title: "restaurantId",
                placeholder: "178",
                text: $viewModel.restaurantIdInput,
                keyboardType: .numberPad
            )

            labeledTextField(
                title: "order",
                placeholder: "178, 1, 173",
                text: $viewModel.restaurantOrderInput,
                keyboardType: .numbersAndPunctuation
            )

            Text("GET /restaurant/order 성공 시 order 입력값이 자동으로 채워집니다.")
                .customFont(font: .text13(weight: .Regular))
                .foregroundColor(Color.gray600)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.gray100)
    }

    private func labeledTextField(
        title: String,
        placeholder: String,
        text: Binding<String>,
        keyboardType: UIKeyboardType
    ) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .customFont(font: .text13(weight: .Bold))
                .foregroundColor(Color.gray700)
            TextField(placeholder, text: text)
                .keyboardType(keyboardType)
                .textFieldStyle(.roundedBorder)
        }
    }

    private func apiCard<Content: View>(
        for test: DevAPITest,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            VStack(alignment: .leading, spacing: 4) {
                Text(test.title)
                    .customFont(font: .text13(weight: .Bold))
                    .foregroundColor(Color.gray800)
                Text(test.endpointLabel)
                    .customFont(font: .text13(weight: .Regular))
                    .foregroundColor(Color.gray600)
            }

            content()
            resultBlock(viewModel.result(for: test))
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.gray100)
    }

    private func apiButton(for test: DevAPITest, title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            apiButtonLabel(for: test, title: title)
        }
        .buttonStyle(.borderedProminent)
        .disabled(viewModel.result(for: test).isLoading)
    }

    private func apiButtonLabel(for test: DevAPITest, title: String) -> some View {
        HStack(spacing: 8) {
            if viewModel.result(for: test).isLoading {
                ProgressView()
            }
            Text(title)
        }
    }

    private func resultBlock(_ result: DevAPIResult) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(result.state.title)
                .customFont(font: .text13(weight: .Bold))
                .foregroundColor(result.state.foregroundColor)
            Text(result.message)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
    }
}

@MainActor
private final class DevMenuViewModel: ObservableObject {
    @Published var restaurantIdInput: String = ""
    @Published var restaurantLikeValue: Bool = true
    @Published var restaurantVisibleValue: Bool = true
    @Published var restaurantOrderInput: String = ""

    @Published private var results: [DevAPITest: DevAPIResult] = DevAPITest.defaultResults

    private let menuRepository: MenuRepositoryProtocol
    private let restaurantRemoteDataSource: RestaurantRemoteDataSource

    init(
        menuRepository: MenuRepositoryProtocol = MenuRepositoryImpl(),
        restaurantRemoteDataSource: RestaurantRemoteDataSource = RestaurantRemoteDataSourceImpl()
    ) {
        self.menuRepository = menuRepository
        self.restaurantRemoteDataSource = restaurantRemoteDataSource
    }

    func result(for test: DevAPITest) -> DevAPIResult {
        results[test] ?? DevAPIResult(state: .idle, message: DevAPIText.notRequested)
    }

    func fetchDailyMenus() async {
        await run(.dailyMenus) {
            let menus = try await menuRepository.getMenus(from: Date().yyyyMMdd, to: Date().yyyyMMdd)
            return DevMenuFormatter.dailyMenus(menus)
        }
    }

    func fetchPersonalRestaurants() async {
        await run(.personalRestaurants) {
            let restaurants = try await restaurantRemoteDataSource.fetchPersonalRestaurants()
            return DevMenuFormatter.personalRestaurants(restaurants)
        }
    }

    func setRestaurantLike() async {
        guard let restaurantId = restaurantId else {
            update(.restaurantLike, state: .failure, message: DevAPIText.invalidRestaurantId)
            return
        }

        let like = restaurantLikeValue
        await run(.restaurantLike) {
            let response = try await restaurantRemoteDataSource.setRestaurantLike(restaurantId: restaurantId, like: like)
            return DevMenuFormatter.restaurantLike(response)
        }
    }

    func setRestaurantVisible() async {
        guard let restaurantId = restaurantId else {
            update(.restaurantVisible, state: .failure, message: DevAPIText.invalidRestaurantId)
            return
        }

        let visible = restaurantVisibleValue
        await run(.restaurantVisible) {
            let response = try await restaurantRemoteDataSource.setRestaurantVisible(restaurantId: restaurantId, visible: visible)
            return DevMenuFormatter.restaurantVisible(response)
        }
    }

    func fetchRestaurantOrder() async {
        await run(.restaurantOrder) {
            let response = try await restaurantRemoteDataSource.fetchRestaurantOrder()
            restaurantOrderInput = DevMenuFormatter.orderInput(response.order)
            return DevMenuFormatter.restaurantOrder(response)
        }
    }

    func setRestaurantOrder() async {
        guard let order = restaurantOrderInput.restaurantOrderIds else {
            update(.restaurantOrder, state: .failure, message: DevAPIText.invalidRestaurantOrder)
            return
        }

        await run(.restaurantOrder) {
            let response = try await restaurantRemoteDataSource.setRestaurantOrder(order: order)
            return DevMenuFormatter.restaurantOrder(response)
        }
    }

    private var restaurantId: Int? {
        Int(restaurantIdInput.trimmingCharacters(in: .whitespacesAndNewlines))
    }

    private func run(_ test: DevAPITest, operation: () async throws -> String) async {
        update(test, state: .loading, message: DevAPIText.loading)

        do {
            let message = try await operation()
            update(test, state: .success, message: message)
        } catch {
            update(test, state: .failure, message: DevMenuFormatter.error(error))
        }
    }

    private func update(_ test: DevAPITest, state: DevAPIState, message: String) {
        results[test] = DevAPIResult(state: state, message: message)
    }
}

private struct DevAPIResult {
    let state: DevAPIState
    let message: String

    var isLoading: Bool {
        state == .loading
    }
}

private enum DevAPIState {
    case idle
    case loading
    case success
    case failure

    var title: String {
        switch self {
        case .idle:
            return "Idle"
        case .loading:
            return "Loading"
        case .success:
            return "Success"
        case .failure:
            return "Failure"
        }
    }

    var foregroundColor: Color {
        switch self {
        case .idle, .loading:
            return Color.gray800
        case .success:
            return Color.green
        case .failure:
            return Color.red
        }
    }
}

private enum DevAPITest: CaseIterable, Hashable, Identifiable {
    case dailyMenus
    case personalRestaurants
    case restaurantLike
    case restaurantVisible
    case restaurantOrder

    var id: Self {
        self
    }

    var title: String {
        switch self {
        case .dailyMenus:
            return "Daily Menus"
        case .personalRestaurants:
            return "Personal Restaurants"
        case .restaurantLike:
            return "Restaurant Like"
        case .restaurantVisible:
            return "Restaurant Visible"
        case .restaurantOrder:
            return "Restaurant Order"
        }
    }

    var endpointLabel: String {
        switch self {
        case .dailyMenus:
            return "GET /menus"
        case .personalRestaurants:
            return "GET /restaurants/personal"
        case .restaurantLike:
            return "PATCH /restaurants/like/{restaurantId}"
        case .restaurantVisible:
            return "PATCH /restaurants/visible/{restaurantId}"
        case .restaurantOrder:
            return "GET, PATCH /restaurant/order"
        }
    }

    static var defaultResults: [DevAPITest: DevAPIResult] {
        Dictionary(uniqueKeysWithValues: allCases.map { test in
            (test, DevAPIResult(state: .idle, message: DevAPIText.notRequested))
        })
    }
}

private enum DevAPIText {
    static let notRequested = "아직 호출 전"
    static let loading = "호출 중..."
    static let invalidRestaurantId = "restaurantId를 숫자로 입력하세요."
    static let invalidRestaurantOrder = "order는 숫자를 콤마 또는 공백으로 구분해 입력하세요."
}

private enum DevMenuFormatter {
    static func error(_ error: Error) -> String {
        let statusCode = (error as? AFError)?.responseCode ?? 0
        return "status: \(statusCode)\nerror: \(error.localizedDescription)"
    }

    static func dailyMenus(_ menus: [DailyMenuModel]) -> String {
        guard let menu = menus.first else {
            return "메뉴 없음"
        }
        return menu.devDescription
    }

    static func personalRestaurants(_ response: PersonalRestaurantsResponseDTO) -> String {
        var desc = "count: \(response.count)\nresult count: \(response.result.count)"
        if let first = response.result.first {
            desc += "\n\nfirst\n\(first.devDescription)"
        }
        return desc
    }

    static func restaurantLike(_ response: RestaurantLikeResponseDTO) -> String {
        """
        id: \(response.id)
        liked: \(response.liked)
        """
    }

    static func restaurantVisible(_ response: RestaurantVisibleResponseDTO) -> String {
        """
        id: \(response.id)
        visible: \(response.visible)
        """
    }

    static func restaurantOrder(_ response: RestaurantOrderResponseDTO) -> String {
        "order: \(orderInput(response.order))"
    }

    static func orderInput(_ order: [Int]) -> String {
        order.map(String.init).joined(separator: ", ")
    }
}

private extension PersonalRestaurantDTO {
    var devDescription: String {
        """
        id: \(id)
        code: \(code)
        nameKr: \(nameKr ?? "nil")
        liked: \(liked)
        visible: \(visible)
        """
    }
}

private extension String {
    var restaurantOrderIds: [Int]? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return []
        }

        let values = split(omittingEmptySubsequences: false) { character in
            character == "," || character == " " || character == "\n" || character == "\t"
        }
        let ids = values.map { Int($0) }
        return ids.contains(nil) ? nil : ids.compactMap { $0 }
    }
}

private extension DailyMenuModel {
    var devDescription: String {
        var desc = "\(date)\n"

        desc += "아침\n"
        for restaurant in breakfast {
            desc.append(restaurant.devDescription)
        }

        desc += "점심\n"
        for restaurant in lunch {
            desc.append(restaurant.devDescription)
        }

        desc += "저녁\n"
        for restaurant in dinner {
            desc.append(restaurant.devDescription)
        }
        return desc
    }
}

private extension RestaurantModel {
    var devDescription: String {
        var desc = "\(nameKr ?? "unknown") 메뉴\n"

        for menu in menus {
            desc.append(menu.devDescription + "\n")
        }
        return desc
    }
}

private extension MenuModel {
    var devDescription: String {
        "\(nameKr): \(price)원"
    }
}

#Preview {
    DevMenuView()
}
