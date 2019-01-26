//
//  GameScene.swift
//  TileMapTest
//
//  Created by Tom Shiflet on 1/23/19.
//  Copyright © 2019 Tom Shiflet. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    let map=SKNode()
    
    var moveLeft=false
    var moveRight=false
    var moveUp=false
    var moveDown=false
    var zoomOut=false
    var zoomIn=false
    let moveSpeed:CGFloat=30
    let cam=SKCameraNode()
    var mapTex=SKSpriteNode()
    
    var colorOffset:CGFloat=0.0
    var topLayer=SKTileMapNode()
    
    override func didMove(to view: SKView) {
        
        self.camera=cam
        addChild(cam)
        
        addChild(map)

        let tileSet = SKTileSet(named: "Serengeti Tiles")!
        let tileSize = CGSize(width: 128, height: 128)
        let columns = 256
        let rows = 256
        let waterTiles = tileSet.tileGroups.first { $0.name == "mud01" }
        let grassTiles = tileSet.tileGroups.first { $0.name == "grass02"}
        let deadGrass = tileSet.tileGroups.first { $0.name == "deadGrass"}
        let grass01Tiles = tileSet.tileGroups.first { $0.name == "grass01"}
        
        let bottomLayer = SKTileMapNode(tileSet: tileSet, columns: columns, rows: rows, tileSize: tileSize)
        bottomLayer.fill(with: waterTiles)
        map.addChild(bottomLayer)
        
        // create the noise map
        let noiseMap = makeNoiseMap(columns: columns, rows: rows)
        let mapT=SKTexture(noiseMap: noiseMap)
        mapTex=SKSpriteNode(texture: mapT)
        mapTex.setScale(2.0)
        mapTex.alpha=0.7
        mapTex.yScale *= -1
        mapTex.zRotation=CGFloat.pi/2
        cam.addChild(mapTex)
        
        mapTex.position.x=size.width/2-mapTex.size.width/2
        mapTex.position.y=size.height/2-mapTex.size.height/2
        
        // create our grass/water layer
        topLayer = SKTileMapNode(tileSet: tileSet, columns: columns, rows: rows, tileSize: tileSize)
        

        // make SpriteKit do the work of placing specific tiles
        topLayer.enableAutomapping = true
        
        // add the grass/water layer to our main map node
        map.addChild(topLayer)
        
        for column in 0 ..< columns {
            for row in 0 ..< rows {
                let location = vector2(Int32(row), Int32(column))
                let terrainHeight = noiseMap.value(at: location)
               
                if terrainHeight < -0.5 {
                    topLayer.setTileGroup(deadGrass, forColumn: column, row: row)
                } else if terrainHeight < 0.5{
                    topLayer.setTileGroup(grassTiles, forColumn: column, row: row)
                }
                else
                {
                    topLayer.setTileGroup(grass01Tiles, forColumn: column, row: row)
                }
            }
        }
        // return animated tiles in a single layer

    }
    
    func makeNoiseMap(columns: Int, rows: Int) -> GKNoiseMap {
        
        let seed=Int32(random(min: 1, max: 50000))
        //let source = GKBillowNoiseSource(frequency: 0.015, octaveCount: 2, persistence: 0.2, lacunarity: 0.005, seed: seed)
        let source=GKPerlinNoiseSource()
        source.persistence = 0.8
        
        let noise = GKNoise(source)
        let sizeRange=random(min: 3.5, max: 6.0)
        let size = vector2(Double(sizeRange), Double(sizeRange))
        let origin = vector2(0.0, 0.0)
        let sampleCount = vector2(Int32(columns), Int32(rows))
        
        return GKNoiseMap(noise, size: size, origin: origin, sampleCount: sampleCount, seamless: true)
    }
    
    func touchDown(atPoint pos : CGPoint) {

    }
    
    func touchMoved(toPoint pos : CGPoint) {

    }
    
    func touchUp(atPoint pos : CGPoint) {

    }
    
    override func mouseDown(with event: NSEvent) {
        self.touchDown(atPoint: event.location(in: self))
    }
    
    override func mouseDragged(with event: NSEvent) {
        self.touchMoved(toPoint: event.location(in: self))
    }
    
    override func mouseUp(with event: NSEvent) {
        self.touchUp(atPoint: event.location(in: self))
    }
    
    override func keyDown(with event: NSEvent) {
        switch event.keyCode {

        case 0:
            moveLeft=true
            
        case 1:
            moveDown=true
        case 2:
            moveRight=true
            
        case 13:
            moveUp=true
            
        case 24:
            zoomOut=true
            
        case 27:
            zoomIn=true
        case 46:
            if mapTex.isHidden
            {
                mapTex.isHidden=false
            }
            else
            {
                mapTex.isHidden=true
            }
        case 49:
            colorOffset += 0.1
            if colorOffset > 1
            {
                colorOffset=0
            }
            print(colorOffset)
            
        default:
            print("keyDown: \(event.characters!) keyCode: \(event.keyCode)")
        }
    }
    
    override func keyUp(with event: NSEvent) {
        switch event.keyCode {
            
        case 0:
            moveLeft=false
            
        case 1:
            moveDown=false
        case 2:
            moveRight=false
            
        case 13:
            moveUp=false
        case 24:
            zoomOut=false
            
        case 27:
            zoomIn=false
        default:
            break
        }
    }
    
    
    func checkKeys()
    {
        if moveUp
        {
            cam.position.y += moveSpeed
        }
        
        if moveDown
        {
            cam.position.y -= moveSpeed
        }
        
        if moveLeft
        {
            cam.position.x -= moveSpeed
        }
        
        if moveRight
        {
            cam.position.x += moveSpeed
        }
        
        if zoomOut
        {
            cam.setScale(cam.xScale-0.01)
        }
        if zoomIn
        {
            cam.setScale(cam.xScale+0.01)
        }
    }
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        map.isPaused=true
        checkKeys()
        topLayer.color=NSColor(calibratedRed: 1.0-colorOffset, green: 1.0-colorOffset, blue: 1.0-colorOffset, alpha: 1.0)
    }
}
