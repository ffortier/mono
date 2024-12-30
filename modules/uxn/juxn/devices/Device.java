package juxn.devices;

import juxn.UxnCore;

public interface Device {
    default void out(int portOffset, int addr, UxnCore core) {
        throw new UnsupportedOperationException("Output operation not supported at %02x".formatted(addr));
    }

    default void in(int portOffset, int addr, UxnCore core) {
        throw new UnsupportedOperationException("Input operation not supported at %02x".formatted(addr));
    }
}
