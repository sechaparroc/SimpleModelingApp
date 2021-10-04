static class RotateGizmo{ //Allows to Scale shape along main axes
    Component current;
    Node ref;
    Node xAxis, yAxis, zAxis;
    Node[] axes;

    RotateGizmo(Scene scene){
        ref = new Node();
        scene.setVisit(ref, (node) -> {
            this.ref.setWorldPosition(this.current);
            this.ref.setWorldOrientation(scene.eye().worldOrientation());
        });
        ref.tagging = false;
        xAxis = new Node(ref);
        yAxis = new Node(ref);
        zAxis = new Node(ref);
        axes = new Node[]{xAxis, yAxis, zAxis};
        //Define immediate mode shape
        xAxis.setShape((pg) -> {
            pg.push();
            pg.hint(PConstants.DISABLE_DEPTH_TEST);
            pg.noFill();
            pg.stroke(255,0,0, 100);
            pg.strokeWeight(8);
            pg.rotateY(PConstants.HALF_PI);
            pg.circle(0,0,50);
            pg.hint(PConstants.ENABLE_DEPTH_TEST);
            pg.pop();
        });
        yAxis.setShape((pg) -> {
            pg.push();
            //pg.hint(PConstants.DISABLE_DEPTH_TEST);
            pg.rotateX(PConstants.HALF_PI);
            pg.noFill();
            pg.stroke(0,255,0, 100);
            pg.strokeWeight(8);
            pg.circle(0,0,50);
            //pg.hint(PConstants.ENABLE_DEPTH_TEST);
            pg.pop();
        });
        zAxis.setShape((pg) -> {
            pg.push();
            //pg.hint(PConstants.DISABLE_DEPTH_TEST);
            pg.noFill();
            pg.stroke(0,0,255, 100);
            pg.strokeWeight(8);
            pg.circle(0,0,50);
            //pg.hint(PConstants.ENABLE_DEPTH_TEST);
            pg.pop();
        });

        //Define axes interaction
        xAxis.setInteraction((Object[] gestures) -> interact(new Vector(1,0,0)));
        yAxis.setInteraction((Object[] gestures) -> interact(new Vector(0,1,0)));
        zAxis.setInteraction((Object[] gestures) -> interact(new Vector(0,0,1)));

        for(Node axis : axes){
            //Disable highlight
            axis.setHighlight(0);
            //Disable scaling, rotation and translation for each axis
            axis.setForbidRotationFilter();
            axis.setForbidScalingFilter();
            axis.setForbidScalingFilter();
        }
    }

    void attachToComponent(MainArea area, Component component){
        current = component;
        ref.attach();
        ref.setReference(area.reference);
    }

    void detach(){
        current = null;
        ref.detach();
    }


    void interact(Vector vector){
        BiFunction filter = current.rotationFilter();
        Object[] params = current.cacheRotationParams;
        current.setRotationAxisFilter(current.displacement(vector, ref));
        current.mainArea.scene.spin(current, 0);
        current.setRotationFilter(filter, params);
    }

    //Given a Node determines if belongs to this Tool
    boolean hasFocus(Node node){
        return node == xAxis || node == yAxis || node == zAxis;
    }
}
