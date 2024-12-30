package juxn.devices;

import juxn.UxnCore;

import javax.swing.*;
import javax.swing.plaf.ComponentUI;
import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.image.BufferedImage;
import java.nio.ByteBuffer;

public class Screen extends ComponentUI implements Device {
    private static final int[][] BLENDING = {
            {0, 0, 0, 0, 1, 0, 1, 1, 2, 2, 0, 2, 3, 3, 3, 0},
            {0, 1, 2, 3, 0, 1, 2, 3, 0, 1, 2, 3, 0, 1, 2, 3},
            {1, 2, 3, 1, 1, 2, 3, 1, 1, 2, 3, 1, 1, 2, 3, 1},
            {2, 3, 1, 2, 2, 3, 1, 2, 2, 3, 1, 2, 2, 3, 1, 2},
    };
    private final int DEFAULT_WIDTH = 512;
    private final int DEFAULT_HEIGHT = 320;
    private BufferedImage bgImage = new BufferedImage(DEFAULT_WIDTH, DEFAULT_HEIGHT, BufferedImage.TYPE_INT_ARGB);
    private BufferedImage fgImage = new BufferedImage(DEFAULT_WIDTH, DEFAULT_HEIGHT, BufferedImage.TYPE_INT_ARGB);
    private int width = DEFAULT_WIDTH;
    private int height = DEFAULT_HEIGHT;
    private JComponent component = null;
    private Runnable screenCallback = () -> {
    };
    private Color[] palette = {
            Color.WHITE,
            Color.RED,
            Color.GREEN,
            Color.BLUE,
    };

    private void animate(ActionEvent actionEvent) {
        try {
            screenCallback.run();
            component.repaint();
            timer.restart();
        } catch (Exception e) {
            e.printStackTrace();
            java.lang.System.exit(1);
        }
    }

    private void setWidth(int w) {
        this.width = w;
        bgImage = new BufferedImage(width, height, BufferedImage.TYPE_INT_ARGB);
        fgImage = new BufferedImage(width, height, BufferedImage.TYPE_INT_ARGB);
        this.blankScreen();
        component.setPreferredSize(new Dimension(width, height));
    }

    private void setHeight(int h) {
        this.height = h;
        bgImage = new BufferedImage(width, height, BufferedImage.TYPE_INT_ARGB);
        fgImage = new BufferedImage(width, height, BufferedImage.TYPE_INT_ARGB);
        this.blankScreen();
        component.setPreferredSize(new Dimension(width, height));
    }

    private void blankScreen() {
        final var bgGraphics = bgImage.createGraphics();
        bgGraphics.setColor(palette[0]);
        bgGraphics.fillRect(0, 0, width, height);
        bgGraphics.dispose();

        final var fgGraphics = fgImage.createGraphics();
        fgGraphics.setComposite(AlphaComposite.Clear);
        fgGraphics.fillRect(0, 0, width, height);
        fgGraphics.dispose();
    }

    @Override
    public void paint(Graphics g, JComponent c) {
        g.drawImage(bgImage, 0, 0, width, height, null);
        g.drawImage(fgImage, 0, 0, width, height, null);
    }

    @Override
    public void installUI(JComponent c) {
        component = c;

        c.setPreferredSize(new Dimension(width, height));
        c.validate();

        timer.start();
    }

    @Override
    public void uninstallUI(JComponent c) {
        timer.stop();
    }

    @Override
    public void out(int portOffset, int addr, UxnCore core) {
        switch (portOffset) {
            case 0x0 -> registerVector(core.ram().getShort(addr), core);
            case 0x2 -> setWidth(core.ram().getShort(addr));
            case 0x4 -> setHeight(core.ram().getShort(addr));
            case 0xe -> drawPixel(
                    core.ram().getShort((addr & 0xf0) + 0x8),
                    core.ram().getShort((addr & 0xf0) + 0xa),
                    core.ram().get((addr & 0xf0) + 0x6),
                    core.ram().get((addr & 0xf0) + 0xe));
            case 0xf -> drawSprite(
                    core.ram().getShort((addr & 0xf0) + 0x8),
                    core.ram().getShort((addr & 0xf0) + 0xa),
                    core.ram().get((addr & 0xf0) + 0x6),
                    core.ram().get((addr & 0xf0) + 0xf),
                    core.ram().getShort((addr & 0xf0) + 0xc),
                    core.ram());
        }
    }

    public void updatePalette(int r, int g, int b) {
        for (int i = 0; i < 4; i++) {
            final var red = (r >> ((3 - i) * 4)) & 0xf;
            final var green = (g >> ((3 - i) * 4)) & 0xf;
            final var blue = (b >> ((3 - i) * 4)) & 0xf;
            this.palette[i] = new Color(red << 4 | red, green << 4 | green, blue << 4 | blue);
        }
    }

    private void drawSprite(short x, short y, byte move, byte ctrl, short ptr, ByteBuffer ram) {
        final var twobpp = (ctrl & 0x80);
        final var length = move >> 4;
        final var ctx = (ctrl & 0x40) != 0 ? this.fgImage : this.bgImage;
        final var color = ctrl & 0xf;
        final var opaque = color % 5;
        final var flipx = (ctrl & 0x10) != 0;
        final var fx = flipx ? -1 : 1;
        final var flipy = (ctrl & 0x20) != 0;
        final var fy = flipy ? -1 : 1;
        final var dx = (move & 0x1) << 3;
        final var dxy = dx * fy;
        final var dy = (move & 0x2) << 2;
        final var dyx = dy * fx;
        final var addr_incr = (move & 0x4) << (1 + twobpp);
        for (var i = 0; i <= length; i++) {
            var x1 = x + dyx * i;
            var y1 = y + dxy * i;
            if (x1 >= 0x8000) x1 = -(0x10000 - x1);
            if (y1 >= 0x8000) y1 = -(0x10000 - y1);
            for (var v = 0; v < 8; v++) {
                var c = ram.get((ptr + v) & 0xffff) | (twobpp != 0 ? (ram.get((ptr + v + 8) & 0xffff) << 8) : 0);
                var v1 = (flipy ? 7 - v : v);
                for (var h = 7; h >= 0; --h, c >>= 1) {
                    var ch = (c & 1) | ((c >> 7) & 2);
                    if (opaque != 0 || ch != 0) {
                        final var b = BLENDING[ch][color];
                        final var pixelCcolor = this.palette[b];
                        ctx.setRGB(x1 + h, y1 + v1, pixelCcolor.getRGB());
                    }
                }
            }
            ptr += addr_incr;
        }
        if ((move & 0x1) != 0) {
            ram.putShort(0x28, (short) (x + dx * fx));
        }
        if ((move & 0x2) != 0) {
            ram.putShort(0x2a, (short) (y + dy * fy));
        }
        if ((move & 0x4) != 0) {
            ram.putShort(0x2c, ptr);
        }
    }

    private void drawPixel(short x, short y, byte move, byte ctrl) {
    }

    private void registerVector(short vector, UxnCore core) {
        screenCallback = () -> core.eval(vector);
    }

    private final Timer timer = new Timer((int) (1000.0 / 60.0), this::animate);


}
