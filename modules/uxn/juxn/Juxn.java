package juxn;

import juxn.swing.JScreen;

import javax.swing.*;
import javax.swing.plaf.ComponentUI;
import java.awt.*;
import java.awt.event.WindowAdapter;
import java.awt.event.WindowEvent;
import java.io.IOException;
import java.io.PrintStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Arrays;

public class Juxn extends JFrame {
    private final UxnCore core = UxnBuilder.createDefault();

    public Juxn(byte[] rom) {
        core.load(rom);

        addWindowListener(new WindowAdapter() {
            @Override
            public void windowOpened(WindowEvent e) {
                System.out.println("Eval reset vector");
                core.eval(0x100);
                System.out.flush();
                pack();
            }
        });

        final var panel = new JPanel();

        panel.setBorder(BorderFactory.createEmptyBorder(0, 0, 0, 0));
        panel.setLayout(new BorderLayout());

        add(panel);
        setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        setTitle("Juxn");
        setVisible(true);

        for (final var device : core.devices()) {
            if (device instanceof ComponentUI ui) {
                panel.add(new JScreen(ui), BorderLayout.CENTER);
                pack();
            }
        }
    }

    public static void main(String[] args) throws IOException {
        System.out.println(Arrays.toString(args));

        if (args.length != 1) {
            printUsage(System.err);
            System.err.println("Error missing rom");
            System.exit(1);
        }

        new Juxn(Files.readAllBytes(Path.of(args[0])));
    }

    private static void printUsage(PrintStream ps) {
        ps.println("Usage: juxn <rom>");
    }
}