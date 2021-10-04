static class Component extends Node {
    /**
     * A Component is a Node with common interactions used in the Main Interaction Area:
     * - Extrude: Allows to create a new Component whose reference is this
     * - Change Shape: Allows to define a new PShape related to this component
     * - Scale Shape: Allows to Scale the given PShape along Local Axes
     * - On Changing Ref: Allows to Redefine the reference of the component
     */

    //Define custom Interaction actions
    enum Interaction { //ADD MORE INTERACTIONS IF REQUIRED
        EXTRUDE, CHANGE_SHAPE, SCALE_SHAPE, UPDATE_REF, ON_CHANGING_REF, CANCEL_REF_UPDATE
    }

    public MainArea mainArea; //Main Area in which this component lives

    //Auxiliar drawing attributes
    public static boolean drawReferenceConnection = true;
    Vector changingRef = null;

    //Shape attributes
    //Determines the Type of Shape
    public Utils.Shape shapeType;
    public float dim = 20; //Initial dimension size
    public Vector shapeScale = new Vector(1,1,1);
    public int colour;

    //Copy hack
    static boolean copyComponent = false;

    public Component(MainArea mainArea, Utils.Shape shapeType, float dim) {
        super();
        setup(mainArea);
        this.dim = dim;
        this.colour = mainArea.colorSelectionArea.currentColor;
        this.setShape(shapeType, this.colour);
    }

    public Component(Component reference) {
        super(reference);
        setup(reference.mainArea);
        this.dim = reference.dim;
        this.shapeScale = reference.shapeScale.copy();
        this.colour = reference.colour;
        this.setShape(reference.shapeType, this.colour);
    }

    public void setup(MainArea mainArea) {
        this.mainArea = mainArea;
        this.resetPicking();
        //Important: Only Retained Shape must be used to pick a Component
        this.enablePicking(Node.SHAPE);
        this.setInteraction(this::interact);
        this.setHUD(this::hud);
        this.mainArea.components.add(this);
    }

    public void hud(PGraphics pg) {
        if(this.mainArea.isRenderingAuxiliar) return;
        if(drawReferenceConnection) {
            pg.fill(0);
            pg.text(this.id(), 0, 0);
            //A red line is drawn to easily identify the reference of this node
            Vector displacement = location(reference());
            Vector ref = this.mainArea.scene.screenDisplacement(displacement, this);
            pg.strokeWeight(3);
            pg.stroke(255, 0, 0, 150);
            pg.line(0, 0, ref.x(), ref.y());
        }
        //An auxiliar line is drawn when interacting to change the node reference
        if (changingRef != null) {
            pg.strokeWeight(3);
            pg.stroke(255, 0, 0, 100);
            pg.line(0, 0, changingRef.x(), changingRef.y());
        }
    }

    public void setShape(Utils.Shape shapeType, int colour){
        this.shapeType = shapeType;
        PShape shape = Utils.generateShape(shapeType, this.dim, colour);
        shape.scale(shapeScale.x(), shapeScale.y(), shapeScale.z());
        setShape(shape);
    }

    public PShape shape(){
        return _rmrShape;
    }

    public void scaleShape(float x, float y, float z){
        this.shapeScale._vector[0] *= x;
        this.shapeScale._vector[1] *= y;
        this.shapeScale._vector[2] *= z;
        this.shape().scale(x,y,z);
    }

    //Interaction methods

    //When mouse is released a new Node is put on the scene
    public void extrude() {
        //1. Create a new component based on this one
        Component component = null;
        if(mainArea.extrusionMode == MainArea.ExtrusionMode.DUPLICATE) {
            component = new Component(this);
        } else if(mainArea.extrusionMode == MainArea.ExtrusionMode.CURRENTSHAPE) {
            component = new Component(this.mainArea, this.mainArea.shapeSelectionArea.currentShapeType, 20);
            component.setReference(this);
            component.setPosition(new Vector());
            component.setOrientation(new Quaternion());
        } else if(mainArea.extrusionMode == MainArea.ExtrusionMode.DEEPCLONE){
            copyComponent = true;
            component = (Component) this.copy(true);
            copyComponent = false;
        }
        //Find displacement to properly locate the node
        Vector scrNode = mainArea.scene.screenLocation(component);
        Vector mouse = new Vector(mainArea.scene.mouseX(), mainArea.scene.mouseY(), scrNode.z());
        Vector diff = Vector.subtract(mouse, scrNode);
        Vector displacement = mainArea.scene.displacement(diff, component.reference());
        component.translate(displacement);
        //2. set new node as the scene tagged node
        mainArea.scene.tag(component);
    }

    public void setReference(MainArea area) {
        Node newRef = area.reference;
        //Check if any other component lies at x,y
        for (Component c : area.components) {
            if (!c.isAttached() || c == this) continue;
            if (area.scene.tracks(c, area.scene.mouseX(), area.scene.mouseY())) {
                newRef = c;
            }
        }
        this.setReference(newRef);
    }

    //Overrides copy behavior
    protected Node _copy(Node reference, int hint, boolean attach) {
        if(copyComponent) {
            Component component = new Component(this);
            component.setReference(reference);
            component.setPosition(this.position().copy());
            component.setOrientation(this.orientation().copy());
            component.setMagnitude(this.magnitude());
            return component;
        }
        return super._copy(reference, hint, attach);
    }


    public void interact(Object[] gesture) {
        switch ((Interaction) gesture[0]) {
            case EXTRUDE: {
                extrude();
                break;
            }
            case CHANGE_SHAPE: {
                this.colour = mainArea.colorSelectionArea.currentColor;
                setShape((Utils.Shape) gesture[1], this.colour);
                break;
            }
            case SCALE_SHAPE: {
                shape().scale((float) gesture[1], 1.0f, 1.0f);
                break;
            }
            case ON_CHANGING_REF: {
                Scene scene = (Scene) gesture[1];
                Vector v = new Vector(scene.mouseX(), scene.mouseY());
                v.subtract(scene.screenLocation(this));
                changingRef = v;
                break;
            }

            case CANCEL_REF_UPDATE: {
                changingRef = null;
                break;
            }

            case UPDATE_REF: {
                setReference((MainArea) gesture[1]);
                changingRef = null;
                break;
            }
        }
    }
}
