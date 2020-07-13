
import UIKit
import RxSwift

class BaseCoordinator<ResultType> {
    typealias CoordinatorResult = ResultType
    
    let disposeBag = DisposeBag()
    
    private var childCoordinators = [UUID: Any]()
    
    private let identifier = UUID()
    
    private func store<T>(coordinator: BaseCoordinator<T>) {
        childCoordinators[coordinator.identifier] = coordinator
    }
    
    private func free<T>(coordinator: BaseCoordinator<T>) {
        childCoordinators[coordinator.identifier] = nil
    }
    
    func start() -> Observable<ResultType> {
        fatalError("Start method should be implemented.")
    }
    
    func coordinator<T>(to coordinator: BaseCoordinator<T>) -> Observable<T> {
        store(coordinator: coordinator)
        return coordinator.start()
            .do(onNext: { [weak self] _ in self?.free(coordinator: coordinator) })
    }
}
