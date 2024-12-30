package juxn.devices;

import juxn.UxnCore;

public class System implements Device {
    @Override
    public void out(int portOffset, int addr, UxnCore core) {
        switch (portOffset) {
            case 0x8, 0xa, 0xc -> {
                final var r = Short.toUnsignedInt(core.ram().getShort((addr & 0xf0) + 0x8));
                final var g = Short.toUnsignedInt(core.ram().getShort((addr & 0xf0) + 0xa));
                final var b = Short.toUnsignedInt(core.ram().getShort((addr & 0xf0) + 0xc));

                for (final var device : core.devices()) {
                    if (device instanceof Screen screen) {
                        screen.updatePalette(r, g, b);
                    }
                }
            }
            default -> throw new UnsupportedOperationException("%02x".formatted(addr));
        }
    }
}
