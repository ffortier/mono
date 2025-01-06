package juxn.swing;

import javax.swing.*;
import javax.swing.plaf.ComponentUI;

public class JScreen extends JComponent {
    public JScreen(ComponentUI ui) {
        setUI(ui);
    }
}