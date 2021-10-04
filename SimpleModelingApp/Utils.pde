/* Based on Scene Method*/
static class Utils{
    enum Shape{
        BOX, SPHERE, CYLINDER, CONE
    }


    static PShape createSphere(float radius){
        return Scene.pApplet.createShape(PConstants.SPHERE, radius);
    }

    static PShape createBox(float l){
        return Scene.pApplet.createShape(PConstants.BOX, l);
    }


    static PShape createCylinder(int detail, float radius, float h){
        PApplet pApplet = Scene.pApplet;
        float px, pz;
        float degrees = 360 / detail;
        PShape group = pApplet.createShape(PApplet.GROUP);

        PShape body = pApplet.createShape();
        body.beginShape(PApplet.QUAD_STRIP);
        for (float i = 0; i < detail + 1; i++) {
            px = (float) Math.cos(PApplet.radians(i * degrees)) * radius;
            pz = (float) Math.sin(PApplet.radians(i * degrees)) * radius;
            body.vertex(px, -h / 2.0f, pz);
            body.vertex(px, h / 2.0f, pz);
        }
        body.endShape();

        PShape top = pApplet.createShape();
        top.beginShape(PApplet.TRIANGLE_FAN);
        top.vertex(0, -h/2.0f, 0);
        for (float i = detail; i > -1; i--) {
            px = (float) Math.cos(PApplet.radians(i * degrees)) * radius;
            pz = (float) Math.sin(PApplet.radians(i * degrees)) * radius;
            top.vertex(px, -h/2.0f, pz);
        }
        top.endShape();

        PShape bottom = pApplet.createShape();
        bottom.beginShape(PApplet.TRIANGLE_FAN);
        bottom.vertex(0, h / 2.0f, 0);
        for (float i = 0; i < detail + 1; i++) {
            px = (float) Math.cos(PApplet.radians(i * degrees)) * radius;
            pz = (float) Math.sin(PApplet.radians(i * degrees)) * radius;
            bottom.vertex(px, h/2.0f, pz);
        }
        bottom.endShape();
        group.addChild(body);
        group.addChild(top);
        group.addChild(bottom);
        return group;
    }


    public static PShape createCone(int detail, float radius, float height) {
        float[] unitConeX = new float[detail + 1];
        float[] unitConeZ = new float[detail + 1];
        for (int i = 0; i <= detail; i++) {
            float a1 = PApplet.TWO_PI * i / detail;
            unitConeX[i] = radius * (float) Math.cos(a1);
            unitConeZ[i] = radius * (float) Math.sin(a1);
        }
        PShape shape = Scene.pApplet.createShape();

        shape.beginShape(PApplet.TRIANGLE_FAN);
        shape.vertex(0, height / 2.0f, 0);
        for (int i = 0; i <= detail; i++) {
            shape.vertex(unitConeX[i], - height / 2.0f, unitConeZ[i]);
        }
        shape.endShape();
        return shape;
    }

    static PShape createArrow(float length, float radius){
        float frac = 0.4f;
        PApplet pApplet = Scene.pApplet;
        PShape group = pApplet.createShape(PConstants.GROUP);
        PShape cone = createCone(20, radius * 1.5f, length * frac);
        cone.setStroke(false);
        cone.translate(0,0.5f * length * (1 - 0.5f * frac), 0);
        PShape cylinder = createCylinder(20,radius, length * (1 - frac));
        cylinder.setStroke(false);
        group.addChild(cylinder);
        group.addChild(cone);

        return group;
    }

    static void drawConnection(PGraphics pg, Node node, int c){
        drawConnection(pg, node.location(node.reference()), c);
    }

    static void drawConnection(PGraphics pg, Vector v, int c){
        pg.push();
        pg.strokeWeight(3);
        pg.stroke(c);
        pg.line(0,0,0, v.x(), v.y(), v.z());
        pg.pop();
    }

    static PShape generateShape(Shape shapeType, float dim, int colour){
        PShape pshape = null;
        switch(shapeType){
            case BOX: {
                pshape = Utils.createBox(dim);
                break;
            }
            case SPHERE: {
                pshape = Utils.createSphere(dim * 0.5f);
                break;
            }
            case CYLINDER: {
                pshape = Utils.createCylinder(20, dim * 0.5f, dim * 0.5f);
                break;
            }
            case CONE: {
                pshape = Utils.createCone(30, dim * 0.5f , dim);
                break;
            }
            default:{
                return null;
            }
        }

        pshape.setStroke(false);
        pshape.setFill(colour);
        return pshape;
    }
}
