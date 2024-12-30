package juxn.devices;

import juxn.UxnCore;

import java.io.PrintStream;

public class Console implements Device {
    private final PrintStream out;
    private final PrintStream err;

    public Console() {
        this(java.lang.System.out, java.lang.System.err);
    }

    public Console(PrintStream out, PrintStream err) {
        this.out = out;
        this.err = err;
    }

    @Override
    public void out(int portOffset, int addr, UxnCore core) {
        switch (portOffset) {
            case 0x8 -> out.print((char) core.ram().get(addr));
            case 0x9 -> err.print((char) core.ram().get(addr));
            default -> {
                throw new UnsupportedOperationException("Console out function not supported yet %x".formatted(portOffset));
            }
        }
    }
}
