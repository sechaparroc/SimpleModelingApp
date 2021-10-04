static class ColorSelectionArea  implements InteractiveArea{
    //Define custom Interaction actions
    enum ColorSelectionInteraction { //ADD MORE INTERACTIONS IF REQUIRED
        SELECT
    }

    Scene scene;
    Node reference;

    int x, y;
    int currentColor;

    HashMap<Node, Integer> colorOptions = new HashMap<>();
    ArrayList<Node> options = new ArrayList<>();

    ColorSelectionArea(PApplet pApplet, int x, int y, int w, int h){
        this.x = x;
        this.y = y;
        scene = new Scene(pApplet.createGraphics(w, h, PConstants.P3D));
        scene.setBounds(0.5f * h);
        scene.fit(0);
        scene.setType(Scene.Type.ORTHOGRAPHIC);
        reference = new Node();
        generateOptions();
        locateOptions();

        Node node = options.get(0);
        scene.tag(node);
        currentColor = colorOptions.get(node);
    }

    void generateOption(int colour, float dim){ //pshape must be in scene dims
        PShape pshape = Utils.generateShape( Utils.Shape.SPHERE, dim, colour);
        Node option = new Node(reference);
        option.setHighlight(0.5f);
        option.setInteraction(this::interact);
        option.setShape(pg -> {
            pg.shape(pshape);
        });
        colorOptions.put(option, colour);
        options.add(option);
    }

    void locateOptions(){
        float w_step = 1 * scene.radius() * scene.aspectRatio() / colorOptions.size();
        float x = - scene.radius() * scene.aspectRatio() * 0.5f + w_step * 0.5f;
        for(Node n : options){
            n.translate(x, 0, 0);
            x += w_step;
        }
    }

    void generateOptions(){
        //Define most common color
        int[] colors = new int []{
            Scene.pApplet.color(0,0,0),
            Scene.pApplet.color(255,255,255),
            Scene.pApplet.color(255,0,0),
            Scene.pApplet.color(0,255,0),
            Scene.pApplet.color(0,0,255),
            Scene.pApplet.color(255,255,0),
            Scene.pApplet.color(0,255,255),
            Scene.pApplet.color(255,0,255),
            Scene.pApplet.color(192,192,192),
            Scene.pApplet.color(128,128,128),
            Scene.pApplet.color(128,0,0),
            Scene.pApplet.color(128,128,0),
            Scene.pApplet.color(0,128,0),
            Scene.pApplet.color(128,0,128),
            Scene.pApplet.color(0,128,128),
            Scene.pApplet.color(0,0,128),
            Scene.pApplet.color(139,69,19),
            Scene.pApplet.color(255,20,147),
            Scene.pApplet.color(46,139,87),
            Scene.pApplet.color(138,43,226)
        };
        float option_size = 0.5f * min( 0.25f * 1.0f * scene.radius() * scene.aspectRatio() / Utils.Shape.values().length, scene.radius() * 0.8f);
        for(int c : colors){
            generateOption(c, option_size);
        }
    }

    void display(int c){
        scene.openContext();
        scene.context().directionalLight(102, 102, 102, 0,0, -1);
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
        scene.context().text("Click over a sphere to choose a Color", scene.width() / 2 , 20);
        scene.context().popStyle();
        scene.endHUD();
        scene.closeContext();

        scene.image(x,y);
    }

    void interact(Object[] gesture) {
        switch((ColorSelectionArea.ColorSelectionInteraction) gesture[0]){
            case SELECT : {
                currentColor = colorOptions.get(scene.node());
                break;
            }
        }
    }


    public void mouseMoved(){

    }

    public void mouseClicked(MouseEvent event){
        scene.updateTag();
        scene.interact(ColorSelectionInteraction.SELECT);
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
