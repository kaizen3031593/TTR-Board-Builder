//
//  GraphItem.swift
//  ConnectTheDots
//
//  Created by freund on 9/6/18.
//  Copyright Â© 2018 Stephen Freund. All rights reserved.
//

import UIKit


/**
 A Custom View to display graphs.  In this version, nodes contains
 string labels and edges and undirected and unlabelled.  Both nodes
 and edges can be highlighted.
 
 Display a graph by setting GraphView.items to a list of `GraphItem`
 enum values describing the graph.  Inspectable properties enable
 you to customize how the graph is drawn.
 
 The GraphView class supports panning, zooming, and zooming in as far
 as possible via gesture recognizers that you must wire appropriately
 in XCode.
 
 */
@IBDesignable
public class GraphView: UIView {
    
    // MARK: Public Properties to Adjust Look
    
    
    /// A background image drawn behind the graph items.
    /// This image will be placed at (0,0) in model coordinates
    /// and scaled/offset according to the model-to-view conversion.
    @IBInspectable var background : UIImage? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /// By default, edges are assumed to end at visible nodes
    /// and their arrows are shortened at both ends to ensure
    /// they don't overlap those nodes.  In some cases (eg:
    /// CampusPaths), we don't want this behavior.  Setting
    /// this property to false will turn that behavior off.
    @IBInspectable
    public var edgesWontOverlapNodes : Bool = true  {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /// Radius of each node
    @IBInspectable
    public var nodeRadius : CGFloat = 10.0  {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /// Color of node frame and edges
    @IBInspectable
    public var outlineColor : UIColor = UIColor.black  {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /// Color of highlighted node or edge
    @IBInspectable
    public var outlineHighlightColor : UIColor = UIColor.red  {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /// Color of node body
    @IBInspectable
    public var nodeColor : UIColor = UIColor.cyan  {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /// Color of node body when highlighted
    @IBInspectable
    public var nodeHighlightColor : UIColor = UIColor.yellow  {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /// Size of edges
    @IBInspectable
    public var lineWidth : CGFloat = 6.0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /// Size of labels in nodes
    @IBInspectable
    public var textSize : CGFloat = 10.0  {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /// Text color of labels in nodes
    @IBInspectable
    public var textColor : UIColor = UIColor.black  {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /// Width of highlighted edges
    @IBInspectable
    public var highlightThickness : CGFloat = 3.0  {
        didSet {
            setNeedsDisplay()
        }
    }
    
    // MARK: Public display list
    
    /// The items that are currently displayed in the view.  The order
    /// in the array reflects the order in which items are drawn.  Specifically
    /// items[0] is drawn first.
    public var items : [GraphItem] = [
//        GraphItem.node(loc: CGPoint(x: 100, y:100), name: "A", highlighted: true),
//        GraphItem.node(loc: CGPoint(x: 100, y:200), name: "B", highlighted: false),
//        GraphItem.edge(src: CGPoint(x: 100, y:100), dst: CGPoint(x:300, y:300), label: "Edge", highlighted: false),
//        GraphItem.edge(src: CGPoint(x: 300, y:100), dst: CGPoint(x:300, y:200), label: "Moo", highlighted: true)
        ] {
        didSet {
            setNeedsDisplay()
        }
    }
        
    /// The Zoom/Offset transform to convert from the graph item's model coordinates
    /// to the view's coordinates
    public var unitTransform = ModelToViewCoordinates(zoomScale: 1.0,
                                                       viewOffset: CGPoint.zero) {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /**
    
    Orders items to have edges before nodes
    
    */
    private func orderItems(){
        var nodes = [GraphItem]()
        var edges = [GraphItem]()
        for item in items{
            switch item{
            case .node:
                nodes.append(item)
            case .edge:
                edges.append(item)
            }
        }
        items = edges + nodes
    }
    
    
    /**
    
    Turns on highlight of edges
    
    - Parameter startPoint: starting point of edge
     - Parameter endPoint: ending point of edge
    */
    public func turnOnEdgeHighlight(startPoint: CGPoint, endPoint: CGPoint){
        for i in 0..<items.count{
            switch items[i] {
            case .node:
                break
            case .edge(let src, let dst, let label,_,let c,let d):
                if (startPoint == src && endPoint == dst) || (startPoint == dst && endPoint == src) {
                    let newEdge = GraphItem.edge(src: src, dst: dst, label: label, highlighted: true, color: c, duplicate: d)
                        items[i]=newEdge
                }
            }
        }
    }
    
    /**
    
    Turns off highlight of edges
    
    - Parameter startPoint: starting point of edge
     - Parameter endPoint: ending point of edge
    */
    public func turnOffEdgeHighlight(startPoint: CGPoint, endPoint: CGPoint){
        for i in 0..<items.count{
            switch items[i] {
            case .node:
                break
            case .edge(let src, let dst, let label,_,let c,let d):
                if (startPoint == src && endPoint == dst) || (startPoint == dst && endPoint == src) {
                    let newEdge = GraphItem.edge(src: src, dst: dst, label: label, highlighted: false, color: c, duplicate: d)
                        items[i]=newEdge
                }
            }
        }
    }
    
    /**
       
       Turns on highlight of nodes
       
       - Parameter loc: node
       */
    public func turnOnNodeHighlight(withLocation loc: CGPoint){
        for i in 0..<items.count{
            switch items[i] {
            case .node(let location, let name,_):
                if location == loc {
                    let newNode = GraphItem.node(loc: location, name: name, highlighted: true )
                    items[i]=newNode
                }
            case .edge:
                break
            }
        }
    }
    
    /**
       
       Turns off highlight of nodes
       
       - Parameter loc: node
       */
    public func turnOffNodeHighlight(withLocation loc: CGPoint){
        for i in 0..<items.count{
            switch items[i] {
            case .node(let location, let name,_):
                if location == loc {
                    let newNode = GraphItem.node(loc: location, name: name, highlighted: false )
                    items[i]=newNode
                }
            case .edge:
                break
            }
        }
    }
    
    // MARK: Coordinates
    
    /**
    
    Finds the center between two points
    
    - Parameter src: Start point
    - Parameter dst: End point
    - Returns: point that is in the center
    
    */
    private func findCenter(src start: CGPoint, dst end: CGPoint) -> CGPoint{
        let x = (start.x + end.x) / 2
        let y = (start.y + end.y) / 2
        let center = CGPoint(x: x, y: y)
        print(center)
        return center
    }
    
    /**
    
    Finds the center of an edge in items
    
    - Parameter point: point that was clicked in the view
    - Returns: edge if found, nil otherwise
    
    */
    public func findEdgefromCenter(centeredAt point: CGPoint) -> GraphItem?{
        for item in items {
            switch item{
            case .node: break
            case .edge(let src, let dst, _,_,_,let dup):
                switch dup{
                case .left:
                    let newPoints = leftEdgeCoordinates(src: src, dst: dst)
                    let center = findCenter(src: newPoints.0, dst: newPoints.1)
                    if pointIsInside(point, nodeCenteredAt: center){
                        return item
                    }
                case .right:
                    let newPoints = rightEdgeCoordinates(src: src, dst: dst)
                    let center = findCenter(src: newPoints.0, dst: newPoints.1)
                    if pointIsInside(point, nodeCenteredAt: center){
                        return item
                    }
                default:
                    let center = findCenter(src: src, dst: dst)
                    if pointIsInside(point, nodeCenteredAt: center){
                        return item
                    }
                }
            }
        }
        return nil
    }
    
    //gets the unit vector but I don't currently use this function
    private func unitVector(src start: CGPoint, dst end: CGPoint) -> (CGFloat, CGFloat){
        let slope = (start.y - end.y) / (start.x - end.x)
        let intercept = start.y - slope * start.x
        let vector = (0-start.x , intercept - start.y)
        let distance = sqrt((vector.0*vector.0) + (vector.1*vector.1))
        let unit_vector = (vector.0/distance, vector.1/distance)
        return unit_vector
    }
    
    /**
    
    Finds the orthogonal unit vector to a line between two points
    
    - Parameter src: Start point of the edge
    - Parameter dst: End point of the edge
    - Returns: tuple of x and y coordinates for the unit vector
    
    */
    private func orthogonalUnitVector(src start: CGPoint, dst end: CGPoint) -> (CGFloat, CGFloat){
        //original slope
        let slope = (start.y - end.y) / (start.x - end.x)
        //perpendicular slope
        let orth_slope = -1 / slope
        //y-intercept of perpendicular slope with start point
        let orth_intercept = start.y - orth_slope * start.x
        let vector = (0 - start.x, orth_intercept - start.y)
        let distance = sqrt((vector.0*vector.0) + (vector.1*vector.1))
        let unit_vector = (vector.0/distance , vector.1/distance)
        return unit_vector
    }
    
    /**
    Find the distance between two points in the view.
    
    **Effects**: None
    
    - Parameter from: the starting point
    - Parameter to: the ending point
     - Returns: the distance between the two points
    */
    public func CGPointDistance(from: CGPoint, to: CGPoint) -> CGFloat {
        return sqrt((from.x - to.x) * (from.x - to.x) + (from.y - to.y) * (from.y - to.y))
    }
    
    /**
     
     Tests whether a location in the view falls within the circle drawn for a node
     centered at the provided point.
     
     - Parameter point: View point of interest (in View Units)
     - Parameter nodeCenteredAt: The center of a node (in Model Units)
     - Returns: true iff the point is within the circle drawn for a node centered
     at the given node point.
     
     */
    public func pointIsInside(_ point: CGPoint, nodeCenteredAt centerInModelUnits: CGPoint) -> Bool {
        
        let centerInViewUnits = unitTransform.toView(modelPoint: centerInModelUnits)
        let dx = centerInViewUnits.x - point.x
        let dy = centerInViewUnits.y - point.y
        return sqrt(dx*dx + dy*dy) < nodeRadius
    }
    
    
    /**
     
     Tests whether a location in the view falls within the circle drawn for all nodes
     already in the graph.
     
     - Parameter point: View point of interest (in View Units)
     - Returns: the node if it is found, nil otherwise
     
     */
    public func findPoint(_ point: CGPoint) -> CGPoint?{
        let nodes = nodePoints()
        for node in nodes{
            if pointIsInside(point, nodeCenteredAt: node){
                return node
            }
        }
        return nil
    }
    
    /**
    
    Finds an  edge in the list of items, nil if not found
    
    - Parameter src: Start point of the edge
    - Parameter dst: End point of the edge
     - Parameter color: color of the edge
    - Returns: GraphItem.edge or nil
    
    */
    public func findEdge(src startPoint: CGPoint, dst endPoint: CGPoint, duplicate: dup) -> GraphItem?{
        for item in items{
            switch item{
                case .node(_, _, _):
                    break
                case .edge(let src, let dst, _, _, _, let dupl):
                    if src == startPoint && dst == endPoint && duplicate == dupl || src == endPoint && dst == startPoint && duplicate == dupl {
                        return item
                }
            }
        }
        return nil
    }
    
    /**
    
    Finds  edge in the list of items, nil if not found. Requires that there be only one edge from the startPoint to the endPoint
    
    - Parameter src: Start point of the edge
    - Parameter dst: End point of the edge
    - Returns: GraphItem.edge or nil
    
    */
    public func findSimilarEdge(src startPoint: CGPoint, dst endPoint: CGPoint) -> GraphItem?{
        for item in items{
            switch item{
                case .node(_, _, _):
                    break
                case .edge(let src, let dst, _, _, _, _):
                    if src == startPoint && dst == endPoint || src == endPoint && dst == startPoint {
                        return item
                }
            }
        }
        return nil
    }
    
    /**
    
     Modifies edge src and dst to offset to the left
    
    - Parameter src: Start point of the edge
    - Parameter dst: End point of the edge
    - Returns: tuple of new coordinates
    
    */
    private func leftEdgeCoordinates(src: CGPoint, dst: CGPoint) -> (CGPoint, CGPoint){
        let unit_vectorS = orthogonalUnitVector(src: src, dst: dst) //src unit vector
        //edge is offset from the center by 5 times the reciprocal of the zoom
        let scale = 5*(1/unitTransform.zoomScale)
        let new_vectorS = (unit_vectorS.0 * scale, unit_vectorS.1 * scale)
        var newSrc = src
        newSrc.x = newSrc.x + new_vectorS.0
        newSrc.y = newSrc.y + new_vectorS.1
        let unit_vectorD = orthogonalUnitVector(src: dst, dst: src) //dst unit vector
        let new_vectorD = (unit_vectorD.0 * scale, unit_vectorD.1 * scale)
        var newDst = dst
        newDst.x = newDst.x + new_vectorD.0
        newDst.y = newDst.y + new_vectorD.1
        return (newSrc, newDst)
    }
    
    /**
    
     Modifies edge src and dst to offset to the right
    
    - Parameter src: Start point of the edge
    - Parameter dst: End point of the edge
    - Returns: tuple of new coordinates
    
    */
    private func rightEdgeCoordinates(src: CGPoint, dst: CGPoint) -> (CGPoint, CGPoint){
        let unit_vectorS = orthogonalUnitVector(src: src, dst: dst) //src unit vector
        //edge is offset from the center by 5 times the reciprocal of the zoom
        let scale = 5*(1/unitTransform.zoomScale)
        let new_vectorS = (unit_vectorS.0 * scale, unit_vectorS.1 * scale)
        var newSrc = src
        newSrc.x = newSrc.x - new_vectorS.0
        newSrc.y = newSrc.y - new_vectorS.1
        let unit_vectorD = orthogonalUnitVector(src: dst, dst: src) //dst unit vector
        let new_vectorD = (unit_vectorD.0 * scale, unit_vectorD.1 * scale)
        var newDst = dst
        newDst.x = newDst.x - new_vectorD.0
        newDst.y = newDst.y - new_vectorD.1
        return (newSrc, newDst)
    }
    
    // MARK: Drawing
    /**
     
     Draw all of the items in the list of items.
     
     **Effects**: Draws all items to the view
     
     - Parameter rect: ignored for us.
     */
    override public func draw(_ rect: CGRect) {
        //moves edges to the front of nodes
        orderItems()
        background?.draw(unitTransform: unitTransform, viewBounds: bounds)
        lineWidth = max(6, min(9,6*unitTransform.zoomScale))
        for item in items {
            switch(item) {
            case .node(let loc, let name, let highlight):
                drawNode(at: loc, labelled: name, highlighted: highlight)
            case .edge(let src, let dst, let label, let highlight, let color, let duplicate):
                switch duplicate{
                case .none:
                    drawEdge(from: src, to: dst, label: label, highlighted: highlight, color: color)
                case .left:
                    let newPoints = leftEdgeCoordinates(src: src, dst: dst)
                    drawEdge(from: newPoints.0, to: newPoints.1, label: label, highlighted: highlight, color: color)
                case .right:
                    let newPoints = rightEdgeCoordinates(src: src, dst: dst)
                    drawEdge(from: newPoints.0, to: newPoints.1, label: label, highlighted: highlight, color: color)
                case .center:
                    drawEdge(from: src, to: dst, label: label, highlighted: highlight, color: color)
                }
            }
        }
    }
    
    
    /**
     Draw a node at the given location.  The node will have
     a centered label and can be highlighted if specified.
     
     **Effects: New node appears in the current drawing context
     
     - Parameter location: Model Coordinates of the node
     - Parameter label: Name of the node.
     - Parameter highlighted: Whether to draw the node's body
     in the highlight color.
     */
    private func drawNode(at location : CGPoint,
                          labelled label: String,
                          highlighted: Bool) {
        textSize = min(max(14, 14*(1/unitTransform.zoomScale)), 20)
        // Compute path for the node
        let viewLocation = unitTransform.toView(modelPoint: location)
        let boundingBox = CGRect(x: viewLocation.x - nodeRadius,
                                 y: viewLocation.y - nodeRadius,
                                 width: nodeRadius * 2,
                                 height: nodeRadius * 2)
        let path = UIBezierPath(ovalIn:boundingBox)
        
        if highlighted {
            nodeHighlightColor.setFill()
        } else {
            nodeColor.setFill()
        }
        path.fill()
        
        outlineColor.set()
        path.stroke()
        
        //drawCenteredText(at: location, text: label)
        drawRightText(at: location, text: label, textColor: outlineColor, backgroundColor: UIColor.white)
    }
    
    /**
     Draw an edge between two locations, with optional
     highlighting.
     
     **Effects**: New edge appears in the current drawing context
     
     - Parameter from: Where the edge ends, in model coordinates.
     - Parameter to: Where the edge ends, in model coordinates.
     - Parameter highlighted: Whether to draw the edge
     in the highlight color.
     */
    private func drawEdge(from srcLocation : CGPoint,
                          to dstLocation : CGPoint,
                          label : String,
                          highlighted: Bool,
                          color: UIColor) {
        
        textSize = 12
        let srcViewLocation = unitTransform.toView(modelPoint: srcLocation)
        let dstViewLocation = unitTransform.toView(modelPoint: dstLocation)
        
        let size = Int(label)! //number of blocks
        let viewDistance = CGPointDistance(from: srcViewLocation, to: dstViewLocation)
        let viewBlockSize = viewDistance/CGFloat(size) //size of blocks
        
        let  path = UIBezierPath()
        
        let  p0 = srcViewLocation
        path.move(to: p0)
        
        let  p1 = dstViewLocation
        path.addLine(to: p1)
        
        //dashes is an array of CGPoints where the elements alternate between size of dash and size of space in-between
        var dashes = [CGFloat]()
        //first element is dash; this gets removed by the phase (didn't work well with CGFloat(0))
        dashes.append(CGFloat(1))
        //start with some spacing
        dashes.append(CGFloat(0.15*Double(viewBlockSize)))
        for _ in 0..<size {
            dashes.append(CGFloat(0.7*Double(viewBlockSize))) //add dash
            dashes.append(CGFloat(0.3*Double(viewBlockSize))) //add spacing
        }
        //update last spacing to be less because we borrowed some for the start
        dashes[dashes.count-1] = CGFloat(0.15*Double(viewBlockSize))
        path.setLineDash(dashes, count: dashes.count, phase: 1.0)
        
        path.lineWidth = lineWidth
        path.lineCapStyle = .butt
        if !highlighted{
            color.set()
        }
        else{
            UIColor.yellow.set()
        }
        path.stroke()
        
        let center = CGPoint(x: path.bounds.midX, y: path.bounds.midY)
        drawCenteredText(at: unitTransform.fromView(viewPoint: center), text: label, textColor: highlighted ? outlineHighlightColor : outlineColor, backgroundColor: UIColor.white)
        
    }
    
    /**
     Draw a text centered at the right of the given location.
     
     **Effects    *: New text appears in the current drawing context
     
     - Parameter locations: Center of node, in model coordinates.
     - Parameter text: the text to display.
     */
    private func drawRightText(at location: CGPoint, text: String, textColor : UIColor? = nil, backgroundColor : UIColor? = nil) {
        
        // Compute view coordinates of center
        let viewLocation = unitTransform.toView(modelPoint: location)
        
        // Use desired color, size, and break at spaces to avoid
        // text that is overly wide.
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        let text = text.replacingOccurrences(of: " ", with: "\n")
        var attrs : [NSAttributedString.Key : Any] =
            [NSAttributedString.Key.font : UIFont.systemFont(ofSize: textSize),
             NSAttributedString.Key.foregroundColor : textColor ?? self.textColor,
             NSAttributedString.Key.paragraphStyle : paragraphStyle]
        
        if let bgColor = backgroundColor {
            attrs[NSAttributedString.Key.backgroundColor] = bgColor
        }
        
        // Compute bounding box for text and then draw it in the box.
        let size = text.size(withAttributes: attrs)
        let boundingBox = CGRect(origin: CGPoint(x: viewLocation.x - size.width/2 + 50,
                                                 y: viewLocation.y - size.height/2),
                                 size: size)
        text.draw(in: boundingBox, withAttributes: attrs)
    }
    
    /**
     Draw a text centered at the given location.
     
     **Effects    *: New text appears in the current drawing context
     
     - Parameter locations: Center of text, in model coordinates.
     - Parameter text: the text to display.
     */
    private func drawCenteredText(at location: CGPoint, text: String, textColor : UIColor? = nil, backgroundColor : UIColor? = nil) {
        
        // Compute view coordinates of center
        let viewLocation = unitTransform.toView(modelPoint: location)
        
        // Use desired color, size, and break at spaces to avoid
        // text that is overly wide.
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        let text = text.replacingOccurrences(of: " ", with: "\n")
        var attrs : [NSAttributedString.Key : Any] =
            [NSAttributedString.Key.font : UIFont.systemFont(ofSize: textSize),
             NSAttributedString.Key.foregroundColor : textColor ?? self.textColor,
             NSAttributedString.Key.paragraphStyle : paragraphStyle]
        
        if let bgColor = backgroundColor {
            attrs[NSAttributedString.Key.backgroundColor] = bgColor
        }
        
        // Compute bounding box for text and then draw it in the box.
        let size = text.size(withAttributes: attrs)
        let boundingBox = CGRect(origin: CGPoint(x: viewLocation.x - size.width/2,
                                                 y: viewLocation.y - size.height / 2),
                                 size: size)
        text.draw(in: boundingBox, withAttributes: attrs)
    }
    
    // MARK: Zooming and Panning
    
    /**
     Change scale of view relative to model.
     
     **Modifies**: self
     
     **Effects**: the transform from model to view coords.
     */
    @IBAction private func pinched(_ sender: UIPinchGestureRecognizer) {
        unitTransform = unitTransform.scale(by: sender.scale)
        sender.scale = 1
    }
    
    
    /**
     Change origin of view relative to model's origin
     
     **Modifies**: self
     
     **Effects**: the transform from model to view coords.
     */
    @IBAction func panned(_ sender: UIPanGestureRecognizer) {
        if sender.state == .changed {
            let translation = sender.translation(in: sender.view)
            unitTransform = unitTransform.shift(by: translation)
            sender.setTranslation(CGPoint.zero, in: sender.view)
        }
    }
    
    /**
     Zoom in as far as possible while still showing all nodes
     and edges in items.
     
     **Modifies**: self
     
     **Effects**: the transform from model to view coords.
     */
    //  @IBAction private func doubleTapped(_ sender: UITapGestureRecognizer) {
    //    zoomToMax()
    //  }
    
    @IBAction func doubleTapped(_ sender: UITapGestureRecognizer) {
        zoomToMax()
    }
    
    
    /// - Returns : all node locatons
    private func nodePoints() -> [CGPoint]{
        var points = [CGPoint]()
        for item in items{
            switch(item) {
            case .node(let loc, _, _):
                points.append(loc)
            case .edge:
                break
            }
        }
        return points
    }
    
    /// - Returns : all node locations and edge start/end locations.
    private func points() -> [CGPoint] {
        var points = [CGPoint]()
        for item in items {
            switch(item) {
            case .node(let loc, _, _):
                points.append(loc)
            case .edge(let src, let dst, _, _, _, _):
                points.append(src)
                points.append(dst)
            }
        }
        return points
    }
    
    /**
     Adjust the zoom scale and panning to show the graph items as zoomed
     in as possible.
     
     **Modifies**: self
     
     **Effects**: changes how the model points are translated into
     view points so that the items are zoomed as much as possible while
     still sitting comfortable in the visible part of the view.
     
     */
    public func zoomToMax() {
        if (items.count > 0) {
            let points = self.points()
            
            // Compute bounding box for all points we know about.  Start with
            // an empty box at the first point, and then extend it to include
            // every other point.
            var modelBounds = CGRect(origin: points[0], size: CGSize(width: 0, height: 0))
            for p in points {
                modelBounds = modelBounds.union(CGRect(origin: p, size: CGSize.zero))
            }
            
            // Don't let the nodes be draw too close to the edge of the view...
            let insetBounds = bounds.insetBy(dx: 2 * nodeRadius, dy: 2 * nodeRadius)
            
            unitTransform = ModelToViewCoordinates(modelBounds: modelBounds,
                                                   viewBounds: insetBounds)
        }
    }
}



extension UIImage {
    
    /**
     Draw the image, scaling and positioning it according to the
     provided unit transform.  The image is assumed to
     be in the model coordinates, with its top-left corner at (0,0).
     The image is scaled/positioned in the view coordinates using the
     unitTransform.
     
     - Note: Methods that scale the entire image without considering
     the bounds of the view area it will be drawn into can be quite
     inefficient if the transformation's scale factor is very large.
     This method avoids high overheads by first cropping the image
     to only the part that will be visible in the view bounds before
     scaling it to exactly fill the provided viewBounds.
     
     - Parameter unitTransform: how to map the image's position
     and size to the view
     
     - Parameter viewBounds: the visible rectangle in view coordinates that
     we should draw into.
     
     */
    func draw(unitTransform : ModelToViewCoordinates, viewBounds: CGRect) {
        let zoomScale = unitTransform.zoomScale
        
        // compute the point in the image that will appear in top-left corner
        // of the view bounds, and also the rectangular area of the image that
        // will be scaled to cover the entire view bounds.
        let topLeftVisiblePoint = unitTransform.fromView(viewPoint: viewBounds.origin)
        let visiblePartOfImage = CGRect(origin: topLeftVisiblePoint,
                                        size: CGSize(width: viewBounds.width/zoomScale,
                                                     height: viewBounds.height/zoomScale))
        
        if let croppedImage = cgImage?.cropping(to: visiblePartOfImage) {
            // grab the part of the image we'll rescale
            let scaledImage = UIImage(cgImage: croppedImage,
                                      scale: 1/zoomScale,
                                      orientation: imageOrientation)
            
            // Since the cropping is clipped to the actual image area, we need
            // to adjust where to draw it when there will be white space to the
            // left or above.
            //
            // So, if the top-left point has, eg, a negative x position in the image
            // then we must shift where the image is drawn by that much.  Same for y.
            let x = topLeftVisiblePoint.x < 0 ? -topLeftVisiblePoint.x * zoomScale : 0
            let y = topLeftVisiblePoint.y < 0 ? -topLeftVisiblePoint.y * zoomScale : 0
            
            scaledImage.draw(at: CGPoint(x:x,y:y))
        }
    }
}
