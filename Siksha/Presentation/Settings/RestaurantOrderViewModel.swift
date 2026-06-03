//
//  RestaurantOrderViewModel.swift
//  Siksha
//
//  Created by 박정헌 on 2023/06/25.
//

//
//  SettingsViewModel.swift
//  Siksha
//
//  Created by 박종석 on 2021/02/01.
//

import Foundation

class RestaurantOrderViewModel: ObservableObject {
    private let fetchPersonalRestaurantsUseCase: FetchPersonalRestaurantsUseCase
    private let updateRestaurantPreferenceUseCase: UpdateRestaurantPreferenceUseCase
    private let setRestaurantOrderUseCase: SetRestaurantOrderUseCase
    
    @Published var personalRestaurants = [PersonalRestaurantModel]()
    @Published var networkStatus: NetworkStatus = .idle
    @Published var toastMessage: String = ""
    @Published var isToastVisible: Bool = false

    private var updatingLikeRestaurantIds = Set<Int>()
    private var updatingVisibleRestaurantIds = Set<Int>()
    private var toastWorkItem: DispatchWorkItem?

    init(
        fetchPersonalRestaurantsUseCase: FetchPersonalRestaurantsUseCase = DefaultFetchPersonalRestaurantsUseCase(
            repository: RestaurantRepositoryImpl()
        ),
        updateRestaurantPreferenceUseCase: UpdateRestaurantPreferenceUseCase = DefaultUpdateRestaurantPreferenceUseCase(
            repository: RestaurantRepositoryImpl()
        ),
        setRestaurantOrderUseCase: SetRestaurantOrderUseCase = DefaultSetRestaurantOrderUseCase(
            repository: RestaurantRepositoryImpl()
        )
    ) {
        self.fetchPersonalRestaurantsUseCase = fetchPersonalRestaurantsUseCase
        self.updateRestaurantPreferenceUseCase = updateRestaurantPreferenceUseCase
        self.setRestaurantOrderUseCase = setRestaurantOrderUseCase
    }

    @MainActor
    func loadPersonalRestaurants() async {
        networkStatus = .loading

        do {
            personalRestaurants = try await fetchPersonalRestaurantsUseCase.execute()
            networkStatus = .succeeded
        } catch {
            networkStatus = .failed
        }
    }

    @MainActor
    func movePersonalRestaurant(from source: IndexSet, to destination: Int) {
        let previousRestaurants = personalRestaurants
        personalRestaurants.move(fromOffsets: source, toOffset: destination)

        Task { [weak self] in
            await self?.savePersonalRestaurantOrder(previousRestaurants: previousRestaurants)
        }
    }

    @MainActor
    func togglePersonalRestaurantLike(restaurantId: Int) async {
        guard !updatingLikeRestaurantIds.contains(restaurantId),
              !updatingVisibleRestaurantIds.contains(restaurantId) else {
            showToast(message: "즐겨찾기 변경을 처리 중입니다.")
            return
        }

        guard let index = personalRestaurants.firstIndex(where: { $0.id == restaurantId }) else {
            return
        }

        let restaurant = personalRestaurants[index]
        let nextLiked = !restaurant.liked
        updatingLikeRestaurantIds.insert(restaurantId)
        if nextLiked, !restaurant.visible {
            updatingVisibleRestaurantIds.insert(restaurantId)
        }
        defer {
            updatingLikeRestaurantIds.remove(restaurantId)
            updatingVisibleRestaurantIds.remove(restaurantId)
        }

        do {
            let status = try await updateRestaurantPreferenceUseCase.setLiked(
                restaurant: restaurant,
                liked: nextLiked
            )
            updatePersonalRestaurant(
                restaurantId: status.id,
                liked: status.liked,
                visible: status.visible
            )
        } catch {
            await refreshPersonalRestaurantsSilently()
            showToast(message: "즐겨찾기 변경에 실패했습니다.")
        }
    }

    @MainActor
    func togglePersonalRestaurantVisibility(restaurantId: Int) async {
        guard !updatingVisibleRestaurantIds.contains(restaurantId),
              !updatingLikeRestaurantIds.contains(restaurantId) else {
            showToast(message: "보이기 설정 변경을 처리 중입니다.")
            return
        }

        guard let index = personalRestaurants.firstIndex(where: { $0.id == restaurantId }) else {
            return
        }

        let restaurant = personalRestaurants[index]
        let nextVisible = !restaurant.visible
        updatingVisibleRestaurantIds.insert(restaurantId)
        if !nextVisible, restaurant.liked {
            updatingLikeRestaurantIds.insert(restaurantId)
        }
        defer {
            updatingVisibleRestaurantIds.remove(restaurantId)
            updatingLikeRestaurantIds.remove(restaurantId)
        }

        do {
            let status = try await updateRestaurantPreferenceUseCase.setVisible(
                restaurant: restaurant,
                visible: nextVisible
            )
            updatePersonalRestaurant(
                restaurantId: status.id,
                liked: status.liked,
                visible: status.visible
            )
        } catch {
            await refreshPersonalRestaurantsSilently()
            showToast(message: "보이기 설정 변경에 실패했습니다.")
        }
    }

    @MainActor
    private func refreshPersonalRestaurantsSilently() async {
        do {
            personalRestaurants = try await fetchPersonalRestaurantsUseCase.execute()
            networkStatus = .succeeded
        } catch {
            return
        }
    }

    @MainActor
    private func savePersonalRestaurantOrder(previousRestaurants: [PersonalRestaurantModel]) async {
        do {
            _ = try await setRestaurantOrderUseCase.execute(order: personalRestaurants.map(\.id))
        } catch {
            personalRestaurants = previousRestaurants
        }
    }

    @MainActor
    private func updatePersonalRestaurant(
        restaurantId: Int,
        liked: Bool? = nil,
        visible: Bool? = nil
    ) {
        guard let index = personalRestaurants.firstIndex(where: { $0.id == restaurantId }) else {
            return
        }

        let restaurant = personalRestaurants[index]
        personalRestaurants[index] = PersonalRestaurantModel(
            id: restaurant.id,
            code: restaurant.code,
            nameKr: restaurant.nameKr,
            nameEn: restaurant.nameEn,
            address: restaurant.address,
            coordinate: restaurant.coordinate,
            liked: liked ?? restaurant.liked,
            visible: visible ?? restaurant.visible,
            operatingHours: restaurant.operatingHours
        )
    }

    @MainActor
    private func showToast(message: String) {
        toastWorkItem?.cancel()
        toastMessage = message
        isToastVisible = true

        let workItem = DispatchWorkItem { [weak self] in
            self?.isToastVisible = false
        }
        toastWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: workItem)
    }
}
