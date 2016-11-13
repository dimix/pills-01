import UIKit
import PlaygroundSupport

class Request {
	static func url(url:URL, completion:@escaping (_ data:Data?, _ error:Error?)->())
	{
		let session:URLSession = URLSession(configuration: URLSessionConfiguration.default)
		let dataTask = session.dataTask(with: url, completionHandler: {
			data, response, error in
			
			completion(data, error)
			
		})
		dataTask.resume()
	}
}

class RemoteConfiguration {
    static let sharedInstance = RemoteConfiguration()
    
    var baseURL:URL?
    
    private var configurationDictionary:[String:AnyObject]?
    
    func configuration(handler: @escaping (_ dictionary:[String:AnyObject]?)->())
    {
        guard let baseURL = baseURL else { assertionFailure("BaseURL cannot be nil"); return }
        
        if let configuration = configurationDictionary
        {
            handler(configuration)
        }
        else
        {
			Request.url(url: baseURL, completion: {
				data, error in
				
				if let data = data, error == nil
				{
					if let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:AnyObject]
					{
						handler(json)
						return
					}
				}
				
				handler(nil)
				
			})
        }
    }
}

let rc = RemoteConfiguration.sharedInstance
rc.baseURL = URL(string: "http://localhost/pills/p-01/remote-config.json")
rc.configuration { configuration in
	if let configuration = configuration
	{
		debugPrint(configuration)
	}
}

PlaygroundPage.current.needsIndefiniteExecution = true
