//
//  BridgingFile.swift
//  E-book
//
//  Created by 小王 on 2017/4/10.
//  Copyright © 2017年 小王. All rights reserved.
//

import UIKit
/*
 如果Swift类想要被OC发现，必须继承自NSObject并且使用public标记，并且该类中想要被OC访问的方法也必须使用public标记，具体知识可以去看Swift的访问控制
 原因：Swift的代码对于OC来说是作为一个module存在的
 
 当然全局的Swift函数，我还没发现怎么在OC中访问，如果哪位清楚还请告诉一下，谢谢！
 */
class BridgingFile: NSObject {

    public func log() {
        print("这是Swift的方法")
    }
}
public func globalLog() {
    print("这是Swift全局的log方法")
}
