//
//  ManageFile.swift
//  Sing N Sketch
//
//  Created by Kevin A Miller on 9/18/15.
//  Copyright (c) 2015 BGSU. All rights reserved.
//

import Foundation
import UIkit

class ManageFile {
    
    @IBAction func saveButton (){
        
        let documents = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        let path = documents.stringByAppendingPathComponent("test.png")
        let data = UIImagePNGRepresentation(image)
        var error: NSError?
        if !data.writeToFile(path, options: .DataWritingAtomic, error: &error) {
            println("writeToFile error: \(error)")
    }
    
        
    func openFile (){
        
        var paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        var getImagePath = paths.stringByAppendingPathComponent("filename")
        myImageView.image = UIImage(contentsOfFile: getImagePath)
        
    }
}