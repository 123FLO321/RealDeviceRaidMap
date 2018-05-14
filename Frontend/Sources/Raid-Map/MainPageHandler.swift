//
//  IndexHandler.swift
//  PT-Wworld
//
//  Created  on 19.04.18.
//

import PerfectLib
import PerfectHTTP
import PerfectMustache
import PerfectSession

struct MainPageHandler: MustachePageHandler {
    
    private var page: MainRequestHandler.Page
    private var data: MustacheEvaluationContext.MapType
    
    public init(
        page: MainRequestHandler.Page!=MainRequestHandler.Page.home,
        data: MustacheEvaluationContext.MapType!=MustacheEvaluationContext.MapType()
        ) {
        self.page = page
        self.data = data
    }
    
    public func extendValuesForResponse(context contxt: MustacheWebEvaluationContext, collector: MustacheEvaluationOutputCollector) {
                
        var values = data
        
        values["title"] = ProcessInfo.processInfo.environment["SERVER_NAME"] ?? "RaidMapHelper"
        
        contxt.extendValues(with: values)

        do {
            try contxt.requestCompleted(withCollector: collector)
        } catch {
            let response = contxt.webResponse
            response.status = .internalServerError
            response.appendBody(string: "\(error)")
            response.completed()
        }
    }
    
}

