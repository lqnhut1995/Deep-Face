import Foundation
import Alamofire
import AlamofireObjectMapper

class WebServices {

    static func uploadImage(downloadString:String, param: [String: Any], complete: @escaping (String?) -> ()){
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            multipartFormData.append((param["name"] as! String).data(using: .utf8)!, withName: "name")
            for item in param["files"] as! [UIImage]{
                multipartFormData.append(UIImageJPEGRepresentation(item, 1)!, withName: "files", fileName: "image", mimeType: "image/jpeg")
            }
        }, usingThreshold: UInt64.init(), to: downloadString, method: .post, headers: ["Content-type": "multipart/form-data"]) { (result) in
            switch result{
            case .success( _, _, _):
                complete("200")
            case .failure(let error):
                if let err = error as? URLError, err.code == URLError.Code.notConnectedToInternet{
                    DispatchQueue.main.async
                        {
                            
                    }
                } else {
                    // other failures
                }
                complete(nil)
            }
        }
    }
}
