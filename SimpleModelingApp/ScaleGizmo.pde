static class ScaleGizmo{ //Allows to Scale shape along main axes
    public Component current;
    public Node ref;
    public Node xAxis, yAxis, zAxis;
    public Node[] axes;
    int[] colors;
    public Vector start;

    public ScaleGizmo(Scene scene){
        ref = new Node();
        ref.tagging = false;
        scene.setVisit(ref, (node) -> {
            this.ref.setWorldPosition(this.current);
            this.ref.setWorldOrientation(this.current.worldOrientation());
        });

        xAxis = new Node(ref);
        yAxis = new Node(ref);
        zAxis = new Node(ref);

        axes = new Node[]{xAxis, yAxis, zAxis};
        colors = new int[]{Scene.pApplet.color(255,0,0), Scene.pApplet.color(0,255,0), Scene.pApplet.color(0,0,255)};

        //Define retained shape
        PApplet pApplet = Scene.pApplet;
        PShape pShape = pApplet.createShape(PConstants.GROUP);
        PShape cylinder = Utils.createCylinder(20,2.5f,30);
        PShape box = Utils.createBox(10);
        box.translate(0,20,0);
        pShape.addChild(cylinder);
        pShape.addChild(box);
        pShape.setStroke(false);

        for(int i = 0; i < axes.length; i++){
            final int idx = i;
            axes[i].setShape((pg) -> {
                pg.hint(PConstants.DISABLE_DEPTH_TEST);
                pg.noLights();
                pShape.setFill(colors[idx]);
                pg.shape(pShape);
                pg.lights();
                pg.hint(PConstants.ENABLE_DEPTH_TEST);
            });
        }

        xAxis.translate(20,0,0);
        yAxis.translate(0,20,0);
        zAxis.translate(0,0,20);
        xAxis.rotate(Vector.plusK, -PConstants.PI/2);
        zAxis.rotate(Vector.plusI, PConstants.PI/2);

        //Define axes interaction
        xAxis.setInteraction((Object[] gestures) -> interact(1, 0, 0)); //First param determines how to scale the current component
        yAxis.setInteraction((Object[] gestures) -> interact(0, 1, 0)); //First param determines how to scale the current component
        zAxis.setInteraction((Object[] gestures) -> interact(0, 0, 1)); //First param determines how to scale the current component
        //Filter translation
        xAxis.setTranslationAxisFilter(new Vector(1,0,0));
        yAxis.setTranslationAxisFilter(new Vector(0,1,0));
        zAxis.setTranslationAxisFilter(new Vector(0,0,1));

        for(Node axis : axes){
            //Disable highlight
            axis.setHighlight(0);
            //Disable scaling, rotation and translation for each axis
            axis.setForbidRotationFilter();
            axis.setForbidScalingFilter();
            axis.setForbidScalingFilter();
        }
    }

    public void attachToComponent(MainArea area, Component component){
        current = component;
        ref.attach();
        ref.setReference(area.reference);
    }

    public void detach(){
        current = null;
        ref.detach();
    }

    public void interact(float dx, float dy, float dz){
        float delta = PApplet.abs(current.mainArea.scene.mouseDX()) >
                PApplet.abs(current.mainArea.scene.mouseDY()) ?
                current.mainArea.scene.mouseDX() : current.mainArea.scene.mouseDY();
        float sx = 1.0f + dx * delta * 0.01f;
        float sy = 1.0f + dy * delta * 0.01f;
        float sz = 1.0f + dz * delta * 0.01f;

        scale(sx, sy, sz);
    }

    public void scale(float x, float y, float z){
        if(current == null) return;
        current.scaleShape(x, y, z);
    }

    //Given a Node determines if belongs to this Tool
    public boolean hasFocus(Node node){
        return node == xAxis || node == yAxis || node == zAxis;
    }
}
