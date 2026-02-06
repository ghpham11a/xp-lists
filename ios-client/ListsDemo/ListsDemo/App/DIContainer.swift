//
//  DIContainer.swift
//  ListsDemo
//

import Swinject

final class DIContainer {

    static let shared = DIContainer()

    let container: Container

    private init() {
        container = Container()
        container.register(PostRepository.self) { _ in
            APIPostRepository()
        }
        container.register(ImageCache.self) { _ in
            ImageCache()
        }.inObjectScope(.container)
    }

    func resolve<T>(_ type: T.Type) -> T {
        container.resolve(type)!
    }
}
