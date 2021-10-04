# SimpleModelingApp
A quite simple modeling Application

## Color & Shape Selection

To pick a color or a shape you must interact with the upper and lower interactive areas respectively.

Click over a sphere in the upper area to pick a color that will be applied to the shapes to add into the Main interactive area.

![Example](https://github.com/sechaparroc/SimpleModelingApp/blob/main/images/colorArea.gif)

Click over any shape in the lower area to define the type of shape that will be used into the Main area. Double click on any shape to add it at the Main Area's Origin.

![Example](https://github.com/sechaparroc/SimpleModelingApp/blob/main/images/shapeArea.gif)

Once a Shape is selected within the Shape Selection area, you could click over a created Shape into the Main area to modify its appearance.

![Example](https://github.com/sechaparroc/SimpleModelingApp/blob/main/images/clickShape.gif)

## Basic Camera transformations interactions

To interact with the Main area camera drag the mouse without picking any shape:
	- Rotate the camera dragging with the LEFT Mouse button.
	- Translate the camera dragging with the RIGHT Mouse button.
	- Use scroll wheel to Zoom in / Zoom out.

Note that Two Auxiliary Views, corresponding to XZ and YZ planes w.r.t the eye, are displayed at the right side of the Window in order to facilitate the composition visualization.

![Example](https://github.com/sechaparroc/SimpleModelingApp/blob/main/images/camera.gif)	


## Basic shape transformations interaction

Once a shape is added into the Main interactive area it could be translated, rotated and scaled by picking it and doing any of the following actions:

- Drag with the LEFT Mouse button to Rotate the Shape.
- Drag with the RIGHT Mouse button to Translate the Shape.
- Use [Gizmos](https://knowledge.autodesk.com/support/autocad/learn-explore/caas/CloudHelp/cloudhelp/2019/ENU/AutoCAD-Core/files/GUID-7BD066C9-31BA-4D47-8064-2F9CF268FA15-htm.html) to translate, rotate or scale a given shape along a specific Axis dragging with the LEFT Mouse button. To do so, you must first select the Shape of interest clicking over it in the Main Area.
	- Press '2' to Enable the Scaling Gizmo
	- Press '3' to Enable the Translation Gizmo. 
	- Press '4' to Enable the Rotation Gizmo. 
	- Press '1' to Disable all Gizmos and allowing to update the appearance of a Shape when mouse is clicked.


