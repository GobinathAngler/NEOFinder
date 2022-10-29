//
//  neoAPIManager.swift
//  NEOFinder
//
//  Created by Gobinath on 29/10/22.
//

import Foundation

protocol neoManagerDelegate {
    func didUpdateNEO(_ NEOManager: neoAPIManager, neoObj: NEOResponse)

    // Error handling.
    func didFailWithError(error: Error)
}

struct neoAPIManager{
    
    let neoURL = "https://api.nasa.gov/neo/rest/v1/feed?"
    
/*https://api.nasa.gov/neo/rest/v1/feed?start_date=2022-10-19&end_date=2022-10-26&api_key=ygzQQ2EeSnHn2k4411qG37ps4IIIcuFQUrcWSUOj*/
    
    var delegate: neoManagerDelegate?
    
    func fetchNEOs(startDate: String, endDate:String) {
            let urlString = "\(neoURL)&start_date=\(startDate)&end_date=\(endDate)&api_key=ygzQQ2EeSnHn2k4411qG37ps4IIIcuFQUrcWSUOj"
            performRequest(with: urlString)
    }
    
    func performRequest(with urlString: String) {
        
        // Create a URL with URL initializer.
        if let url = URL(string: urlString) {
            
            // Create a URLSession (object that performs networking).
            let session = URLSession(configuration: .default)
            
            // Give session a task.
            // .dataTask returns a URLSessionDataTask.
            
            let task = session.dataTask(with: url) { data, response, error in
                
                if error != nil {
                    delegate?.didFailWithError(error: error!)
                    return
                }
          
                if let safeData = data {
                    if let neoData = self.parseJSON(safeData) {
                        // Send data to delegate
                        self.delegate?.didUpdateNEO(self, neoObj: neoData)
                    }
            
                }
            }
            // Start task.
            task.resume()
        }
    }
    
    func parseJSON(_ NEODataRes: Data) -> NEOResponse? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(NEOResponse.self, from: NEODataRes)
            return decodedData
        }catch {
           
            self.delegate?.didFailWithError(error: error)
            return nil
        }
   
    }
}
