//
//  ButterflyRouter.swift
//  Butterfly
//
//  Created by Achref Marzouki on 24/02/2021.
//

import Alamofire

enum ButterflyRouter: Routable {
    
    static var baseUrl: String = "https://my-json-server.typicode.com/butterfly-systems/sample-data"
    
    case orders
    
    var method: HTTPMethod {
        return .get
    }
    
    var path: String {
        return "/purchase_orders"
    }
    
    var params: Parameters? {
        return nil
    }
    
    var headers: HTTPHeaders? {
        return nil
    }
    
    var token: String? {
        return nil
    }
}
