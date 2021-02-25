//
//  ApiManager.swift
//  Butterfly
//
//  Created by Achref Marzouki on 24/02/2021.
//

import MobileCoreServices
import Alamofire

public typealias AlamofireResponse = AFDataResponse<Any>

/// A class that handle and manage WebService calls
open class ApiManager: NSObject {
    
    // MARK: - Shared instance
    
    public static let shared = ApiManager()
    
    // MARK: - Properties
    
    public var currentTask: DataRequest?
    
    // MARK: - Initializers
    
    private override init() {
        super.init()
    }
    
    // MARK: - Request
    
    /// Make a  request and call completion handler with an optional Json. If the response is invalid (Alamofire validation)
    /// the compltion arg will be nil.
    ///
    /// - Parameters:
    ///   - url: A type that can be used to construct an url request.
    ///   - completion: Completion handler.
    open func request(url: URLRequestConvertible, completion: @escaping (AlamofireResponse?) -> ()) {
        
        currentTask = AF.request(url).validate().responseJSON { (response) in
            // completion
            let hasError = self.responseHasError(response: response)
            completion(hasError ? nil : response)
        }
    }
    
    @discardableResult
    func responseHasError(response: AlamofireResponse) -> Bool {
        switch response.result {
        case .success: return false
        case .failure(let error):
            print(error)
            return true
        }
    }
}
