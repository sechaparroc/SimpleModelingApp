static class ShapeSelectionArea implements InteractiveArea{
    //Define custom Interaction actions
    enum ShapeSelectionInteraction { //ADD MORE INTERACTIONS IF REQUIRED
        SELECT, GENERATE
    }

    public Scene scene;
    public Node reference;
    public Node cursor;

    int x, y;
    public Utils.Shape currentShapeType;
    public int fillColor;

    HashMap<Node, Utils.Shape> shapeOptions = new HashMap<>();
    ArrayList<Node> options = new ArrayList<Node>();

    //keep a reference of the main area
    public MainArea mainArea;

    public ShapeSelectionArea(PApplet pApplet, int x, int y, int w, int h){
        this.x = x;
        this.y = y;
        scene = new Scene(pApplet.createGraphics(w, h, PConstants.P3D));
        scene.setBounds(0.5f * h);
        scene.fit(0);
        scene.setType(Scene.Type.ORTHOGRAPHIC);
        reference = new Node();
        generateOptions();
        locateOptions();
        generateCursor();

        Node node = options.get(0);
        scene.tag(node);
        currentShapeType = shapeOptions.get(node);
    }

    public void generateOption(Utils.Shape shapeType, float dim){ //pshape must be in scene dims
        PShape pshape = Utils.generateShape(shapeType, dim, Scene.pApplet.color(100));
        Node option = new Node(reference);
        option.setHighlight(0.5f);
        option.setInteraction(this::interact);
        option.rotate(new Vector(1,1,0), 0.01f, 1);
        option.setShape(pg -> {
            pshape.setFill(fillColor);
            pg.shape(pshape);
            pg.hint(PConstants.DISABLE_DEPTH_TEST);
            Scene.drawAxes(pg, dim);
            pg.hint(PConstants.ENABLE_DEPTH_TEST);
        });

        shapeOptions.put(option, shapeType);
        options.add(option);
    }

    public void locateOptions(){
        float w_step = 1 * scene.radius() * scene.aspectRatio() / shapeOptions.size();
        float x = - scene.radius() * scene.aspectRatio() * 0.5f + w_step * 0.5f;
        for(Node n : options){
            n.translate(x, 0, 0);
            x += w_step;
        }
    }

    public void generateCursor(){
        cursor = new Node();
        cursor.setShape(Utils.createSphere(scene.radius() * 0.05f));
        cursor.tagging = false;
    }

    public void generateOptions(){
        float option_size = 0.5f * min( 0.25f * 1.0f * scene.radius() * scene.aspectRatio() / Utils.Shape.values().length, scene.radius() * 0.8f);
        print(option_size);
        generateOption(Utils.Shape.BOX, option_size);
        generateOption(Utils.Shape.SPHERE, option_size);
        generateOption(Utils.Shape.CYLINDER, option_size);
        generateOption(Utils.Shape.CONE, option_size);
    }

    public void display(int c, int fillColor){
        this.fillColor = fillColor;
        scene.openContext();
        scene.context().ambientLight(102, 102, 102);
        scene.context().lightSpecular(204, 204, 204);
        scene.context().specular(255, 255, 255);
        scene.context().shininess(10);
        scene.context().directionalLight(204, 204, 204, 0, 0, -1);
        scene.context().background(c);
        scene.render(reference);
        scene.closeContext();

        scene.openContext();
        scene.beginHUD();
        scene.context().pushStyle();
        scene.context().noLights();
        scene.context().fill(255);
        scene.context().stroke(255);
        scene.context().textSize(18);
        scene.context().textAlign(CENTER, CENTER);
        String message = "Click over a shape to use it when extruding or Double click to generate it at the origin.";
        scene.context().text(message, scene.width() / 2 , 20);
        scene.context().popStyle();
        scene.endHUD();
        scene.closeContext();

        scene.image(x,y);
    }

    public void interact(Object[] gesture) {
        switch((ShapeSelectionInteraction) gesture[0]){
            case SELECT : {
                currentShapeType = shapeOptions.get(scene.node());
                break;
            }
            case GENERATE: {
                mainArea.generateComponent();
            }
        }
    }


    public void mouseMoved(){

    }

    public void mouseClicked(MouseEvent event){
        scene.updateTag();
        if(event.getCount() == 1) {
            scene.interact(ShapeSelectionInteraction.SELECT);
        } else if(event.getCount() == 2){
            scene.interact(ShapeSelectionInteraction.GENERATE);
        }
    }

    public void mousePressed(){

    }

    public void mouseReleased(){

    }

    public void mouseDragged(){

    }

    public void mouseWheel(MouseEvent event){

    }
}
