import java.io.*;
import net.java.games.input.*;


public class MyController {
	public static void main( String args[]) {
		Controller[] ca = ControllerEnvironment.getDefaultEnvironment().getControllers();

		for(int i =0;i<ca.length;i++){

			/* Get the name of the controller */
			System.out.println(ca[i].getName());
			System.out.println("Type: "+ca[i].getType().toString());

			/* Get this controllers components (buttons and axis) */
			Component[] components = ca[i].getComponents();
			System.out.println("Component Count: "+components.length);
			for(int j=0;j<components.length;j++){

				/* Get the components name */
				System.out.println("Component "+j+": "+components[j].getName());
				System.out.println("    Identifier: "+ components[j].getIdentifier().getName());
				System.out.print("    ComponentType: ");
				if (components[j].isRelative()) {
					System.out.print("Relative");
				} else {
					System.out.print("Absolute");
				}
				if (components[j].isAnalog()) {
					System.out.print(" Analog");
				} else {
					System.out.print(" Digital");
				}
			}
		}

		SerialTest tester = new SerialTest();
		
		
		while(true) {
			Controller[] controllers = ControllerEnvironment.getDefaultEnvironment().getControllers();
			if(controllers.length==0) {
				System.out.println("Found no controllers.");
				System.exit(0);
			}

			for(int i=0;i<controllers.length;i++) {
				controllers[i].poll();
				EventQueue queue = controllers[i].getEventQueue();
				Event event = new Event();
				while(queue.getNextEvent(event)) {
					StringBuffer buffer = new StringBuffer(controllers[i].getName());
					buffer.append(" at ");
					buffer.append(event.getNanos()).append(", ");
					Component comp = event.getComponent();
					buffer.append(comp.getName()).append(" changed to ");
					float value = event.getValue(); 
					if(comp.isAnalog()) {
						buffer.append(value);
					} else {
						if(value==1.0f) {
							buffer.append("On");
						} else {
							buffer.append("Off");
						}
					}
					System.out.println(buffer.toString());
				}
			}

			try {
				Thread.sleep(20);
			} catch (InterruptedException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
		
	}

}
