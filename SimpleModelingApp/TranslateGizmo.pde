static class TranslateGizmo{ //Allows to Scale shape along main axes
    public Component current;
    public Node ref;
    public Node xAxis, yAxis, zAxis;
    Node axes[];
    int colors[];
    Vector start;

    public TranslateGizmo(Scene scene){
        ref = new Node();
        ref.tagging = false;
        scene.setVisit(ref, (node) -> {
            this.ref.setWorldPosition(this.current);
            this.ref.setWorldOrientation(scene.eye().worldOrientation());
        });

        xAxis = new Node(ref);
        yAxis = new Node(ref);
        zAxis = new Node(ref);

        axes = new Node[]{xAxis, yAxis, zAxis};
        colors = new int[]{Scene.pApplet.color(255,0,0), Scene.pApplet.color(0,255,0), Scene.pApplet.color(0,0,255)};

        //Define retained shape
        PShape arrow = Utils.createArrow(30, 3);

        for(int i = 0; i < axes.length; i++){
            final int idx = i;
            axes[i].setShape((pg) -> {
                pg.hint(PConstants.DISABLE_DEPTH_TEST);
                pg.noLights();
                arrow.setFill(colors[idx]);
                pg.shape(arrow);
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
        xAxis.setInteraction((Object[] gestures) -> interact(xAxis, 1, 0, 0));
        yAxis.setInteraction((Object[] gestures) -> interact(yAxis, 0, 1, 0));
        zAxis.setInteraction((Object[] gestures) -> interact(zAxis, 0, 0, 1));

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

    public  void detach(){
        current = null;
        ref.detach();
    }


    public void interact(Node node, float dx, float dy, float dz){
        BiFunction filter = current.translationFilter();
        Object[] params = current.cacheTranslationParams;
        //current.setTranslationAxisFilter(current.location(node));
        //current.scene.shift(current, 0);
        float vx = dx * current.mainArea.scene.mouseDX();
        float vy = dy * current.mainArea.scene.mouseDY();
        float vz = 0.01f * dz * current.mainArea.scene.mouseDY();
        current.mainArea.scene.shift(current, vx, vy, vz, 0);

        current.setTranslationFilter(filter, params);
    }


    //Given a Node determines if belongs to this Tool
    public boolean hasFocus(Node node){
        return node == xAxis || node == yAxis || node == zAxis;
    }
}
