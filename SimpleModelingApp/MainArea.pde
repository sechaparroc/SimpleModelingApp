static class MainArea implements InteractiveArea{
    //Defines the action that must be performed when a Component (Node) is Clicked
    enum Mode { SHAPESELECTION, SCALING_GIZMO, TRANSLATION_GIZMO, ROTATION_GIZMO }
    //Defines extrude mode
    enum ExtrusionMode { CURRENTSHAPE, DUPLICATE, DEEPCLONE}

    //Defines a main scene and two auxiliar scenes corresponding to the XZ Plane and the YZ plane
    Scene scene, sceneXZ, sceneYZ;
    Scene scenes[];
    String titles[] = new String[]{"Main Scene", "Auxiliar View XZ", "Auxiliar View YZ"};

    Node reference;
    ShapeSelectionArea shapeSelectionArea;
    ColorSelectionArea colorSelectionArea;

    //Click mode
    Mode mode = Mode.SHAPESELECTION;
    ExtrusionMode extrusionMode = ExtrusionMode.DUPLICATE;
    ArrayList<Component> components = new ArrayList<Component>();

    //Define Gizmos
    ScaleGizmo scaleGizmo;
    TranslateGizmo translateGizmo;
    RotateGizmo rotateGizmo;

    boolean isRenderingAuxiliar = false;

    int colors [];
    int x, y, w, h;

    MainArea(PApplet pApplet,
                    ShapeSelectionArea shapeSelectionArea,
                    ColorSelectionArea colorSelectionArea,
                    int x,
                    int y,
                    int w,
                    int h){
        this.x = x;
        this.y = y;
        this.w = w;
        this.h = h;
        this.shapeSelectionArea = shapeSelectionArea;
        this.shapeSelectionArea.mainArea = this;
        this.colorSelectionArea = colorSelectionArea;
        scene = new Scene(pApplet.createGraphics(2 * w / 3, h, P3D));
        sceneXZ = new Scene(pApplet.createGraphics(w / 3, h/2, P3D));
        sceneYZ = new Scene(pApplet.createGraphics(w / 3, h/2, P3D));
        scenes = new Scene[]{scene, sceneXZ, sceneYZ};

        colors = new int[]{Scene.pApplet.color(255),Scene.pApplet.color(200), Scene.pApplet.color(200)};

        for(Scene scene : scenes){
            scene.setBounds(100);
            scene.fit(0);
            scene.setType(Scene.Type.ORTHOGRAPHIC);
        }

        reference = new Node();

        scaleGizmo = new ScaleGizmo(scene);
        translateGizmo = new TranslateGizmo(scene);
        rotateGizmo = new RotateGizmo(scene);
    }

    void display(){
        if(translateGizmo.current != null)translateGizmo.ref.setWorldPosition(translateGizmo.current);
        translateGizmo.ref.setWorldOrientation(scene.eye().worldOrientation());

        sceneXZ.eye().set(scene.eye());
        sceneXZ.eye().orbit(scene.eye().worldDisplacement(new Vector(1,0,0)), PI / 2, 0);
        sceneXZ.eye().setMagnitude(sceneXZ.eye().magnitude() * 2);

        sceneYZ.eye().set(scene.eye());
        sceneYZ.eye().orbit(scene.eye().worldDisplacement(new Vector(0,1,0)), PI / 2, 0);
        sceneYZ.eye().setMagnitude(sceneYZ.eye().magnitude() * 2);

        int c = 0;
        for(Scene scene : scenes){
            boolean cull[] = new boolean[3];
            cull[0] = rotateGizmo.ref.cull;
            cull[1] = translateGizmo.ref.cull;
            cull[2] = scaleGizmo.ref.cull;
            isRenderingAuxiliar = c != 0;
            if(c != 0){
                rotateGizmo.ref.cull = true;
                translateGizmo.ref.cull = true;
                scaleGizmo.ref.cull = true;
            }
            scene.openContext();
            scene.context().ambientLight(102, 102, 102);
            scene.context().lightSpecular(204, 204, 204);
            scene.context().specular(255, 255, 255);
            scene.context().shininess(10);
            scene.context().directionalLight(204, 204, 204, 0, 0, -1);
            scene.context().background(colors[c]);
            scene.drawAxes();
            scene.render(reference);
            scene.closeContext();

            scene.openContext();
            scene.beginHUD();
            scene.context().pushStyle();
            scene.context().noLights();
            scene.context().fill(0);
            scene.context().stroke(0);
            scene.context().textSize(18);
            scene.context().textAlign(CENTER, CENTER);
            scene.context().text(titles[c], scene.width() / 2 , 20);
            if(c == 0){ //show mouse mode
                scene.context().text("Extrusion mode: " + extrusionMode.name(), scene.width() / 2, scene.height() - 20);
            }
            scene.context().popStyle();
            scene.endHUD();
            scene.closeContext();

            rotateGizmo.ref.cull = cull[0];
            translateGizmo.ref.cull = cull[1];
            scaleGizmo.ref.cull = cull[2];
            c++;
        }

        scene.image(x,y);
        sceneXZ.image(x + 2 * w / 3, y);
        sceneYZ.image(x + 2 * w / 3, y + h / 2);
    }

    //Define an initial component
    Component generateComponent(){
        Component component = new Component(this, shapeSelectionArea.currentShapeType, 20);
        component.setReference(reference);
        return component;
    }

    void resetGizmos(){
        scaleGizmo.detach();
        translateGizmo.detach();
        rotateGizmo.detach();
    }

    void savePosture(){
        for(Node node : components){
            node.addKeyFrame();
        }
    }

    void play(){
        for(Node node : Scene.branch(reference)){
            node.animate();
        }
    }


    void mouseMoved() {
        scene.updateTag();
    }

    void mouseClicked(MouseEvent event){
        if (event.getCount() == 1){
            if(event.getButton() == LEFT) {
                switch (mode) {
                    case SHAPESELECTION: {
                        scene.interact(Component.Interaction.CHANGE_SHAPE, shapeSelectionArea.currentShapeType);
                        break;
                    }
                    case SCALING_GIZMO: {
                        if (scene.node() instanceof Component) {
                            scaleGizmo.attachToComponent(this, (Component) scene.node());
                        }
                        break;
                    }
                    case TRANSLATION_GIZMO: {
                        if (scene.node() instanceof Component) {
                            translateGizmo.attachToComponent(this, (Component) scene.node());
                        }
                        break;
                    }
                    case ROTATION_GIZMO: {
                        if (scene.node() instanceof Component) {
                            rotateGizmo.attachToComponent(this, (Component) scene.node());
                        }
                        break;
                    }
                }
            } else {
                if(Scene.pApplet.key == PConstants.CODED &&
                        Scene.pApplet.keyCode == PConstants.ALT){
                    Node node = scene.node();
                    if(node instanceof Component){
                        node.detach();
                    }
                }
            }
        }
        else if (event.getCount() == 2){
            if (event.getButton() == LEFT)
                scene.focus();
            else
                scene.align();
        }
    }
    void mousePressed(){
        if(scaleGizmo.hasFocus(scene.node())){
            scaleGizmo.start = scene.node().position().copy();
        }
        else if(scene.node() != null && Scene.pApplet.mouseButton == PConstants.RIGHT){
            if(Scene.pApplet.keyPressed &&
                    Scene.pApplet.key == PConstants.CODED &&
                    Scene.pApplet.keyCode == PConstants.SHIFT){
                scene.interact(Component.Interaction.EXTRUDE);
            }
        }
    }
    void mouseDragged() {
        if (Scene.pApplet.mouseButton == PConstants.LEFT) {
            scene.spin();
        } else if (Scene.pApplet.mouseButton == PConstants.RIGHT) {
            if(scaleGizmo.hasFocus(scene.node()) || translateGizmo.hasFocus(scene.node()) || rotateGizmo.hasFocus(scene.node())){
                scene.interact();
            } else if(scene.node() != null &&
                    Scene.pApplet.keyPressed &&
                    Scene.pApplet.key == PConstants.CODED &&
                    Scene.pApplet.keyCode == PConstants.CONTROL){
                scene.interact(Component.Interaction.ON_CHANGING_REF, scene);
            } else {
                scene.shift();
            }
        } else
            scene.zoom(Scene.pApplet.mouseX - Scene.pApplet.pmouseX);
    }
    void mouseReleased(){
        if(scaleGizmo.hasFocus(scene.node())){
            scaleGizmo.start = null;
        }
        else if(scene.node() != null &&
                Scene.pApplet.keyPressed &&
                Scene.pApplet.key == PConstants.CODED &&
                Scene.pApplet.keyCode == PConstants.CONTROL){
            scene.interact(Component.Interaction.UPDATE_REF, this);
        } else {
            //Clear auxiliary line
            scene.interact(Component.Interaction.CANCEL_REF_UPDATE, this);
        }
    }
    void mouseWheel(MouseEvent event) {
        scene.moveForward(event.getCount() * 5);
    }
}
