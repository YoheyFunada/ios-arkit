//
//  ViewController.swift
//  ARver1
//
//  Created by youhei-funada on 2018/04/10.
//  Copyright © 2018年 youhei-funada. All rights reserved.
//


//現実空間の物体の位置を点座標の集合で取得できる
//秒間数百以上の座標を取得できる
//セッション開始から2,3秒程度で検出


//現実の平面を3D空間上の平面として取得できる
//取得できるのは机や床などの平面のみ
//（垂直面も取得可能）
//ARKit 起動後3〜4秒程度で検出
//平面情報は矩形のみ
//複数の平面を認識、カメラのアングルを変えても維持が可能
//同一と判断された複数の平面は自動的に結合される


/*
 参考記事
 http://appleengine.hatenablog.com/entry/2018/01/30/171518
 */

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    //view用のメンバ変数
    //ARSCNViewはUIViewのサブクラスで、端末のカメラで写された景色をレンダリングするためのViewのことです。
    var sceneView:ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //viewを追加
        self.sceneView = ARSCNView(frame: self.view.frame)
        self.view.addSubview(self.sceneView)
        
        //ARSCNViewクラスのインスタンスであるsceneViewのdelegateプロパティにViewControllerのインスタンスを渡している
        sceneView.delegate = self
        
        //下部ナビゲーションの表示(フレームレートなどの情報)
        sceneView.showsStatistics = true
        
//      .showFeaturePointsはARKitがデバイス位置を追跡するためにscene解析した中間結果を示す点群をARSCNView上に描画するオプション(sceneView内の黄色い点群)(特徴点の表示)
//      .showWorldOriginはARKitで表現されるARSCNView内の世界の座標軸(X,Y,Z)を視覚的に表現するベクトルを描画するオプション(赤・青・緑の棒)
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
        
        //新規シーンの追加
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //AR機能(session)が開始した際に、端末のモーショントラッキングとカメラの画像処理を行うための設定クラス
        let ar_conf = ARWorldTrackingConfiguration()
        
        //平面認識設定の追加（垂直,水平の平面を認識）
        ar_conf.planeDetection = [.vertical, .horizontal]
        
        //セッションの実行（設定クラスのインスタンスをrun）
        sceneView.session.run(ar_conf)
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    // Override to create and configure nodes for anchors added to the view's session.
    // ARKit のデリゲート didUpdate でトラッキングが変更されるたび処理する命令を書く
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        
        // DispatchQueue 内で処理をかく（非同期）
        DispatchQueue.main.async {
            // ARPlaneAnchor からアンカーを取得したり平面のノードを調べる
            //if平面だったら
            if let planeAnchor = anchor as? ARPlaneAnchor {
                // Metal のデフォルトデバイスを設定する（Metalは、OpenGLみたいな感じ[グラフィックスAPI]）
                let device: MTLDevice = MTLCreateSystemDefaultDevice()!
                // ARSCNPlaneGeometry でジオメトリを初期化
                let plane = ARSCNPlaneGeometry.init(device: device)
                // アンカーから認識した領域のジオメトリ情報を取得し ARSCNPlaneGeometry の update に処理を渡す
                plane?.update(from: planeAnchor.geometry)
                
                // 60% 半透明の赤でマテリアルを着色
                plane?.firstMaterial?.diffuse.contents = UIColor.init(red: 1.0, green: 0.0, blue: 0.0, alpha: 0.6)
                
                // 設置しているノードへ処理したジオメトリを渡し描画する
                node.geometry = plane
            }
        }
        
    }
    
}


