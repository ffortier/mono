package juxn;

import juxn.devices.System;
import juxn.devices.*;

public class UxnBuilder {
    private final Device[] devices = Empty.times(16);

    public static UxnCore createDefault() {
        return new UxnBuilder().attachDefaultDevices().build();
    }

    public UxnBuilder attachDevice(int basePort, Device device) {
        if (basePort != (basePort & 0xf0)) {
            throw new IllegalArgumentException("Invalid device base port %x".formatted(basePort));
        }

        this.devices[basePort >> 4] = device;

        return this;
    }

    public UxnBuilder attachDefaultDevices() {
        attachDevice(0x00, new System());
        attachDevice(0x10, new Console());
        attachDevice(0x20, new Screen());

        return this;
    }

    public UxnCore build() {
        return new UxnCore(devices);
    }
}
