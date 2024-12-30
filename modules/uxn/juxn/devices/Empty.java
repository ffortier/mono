package juxn.devices;

import java.util.Arrays;

public class Empty implements Device {
    public static Device[] times(int times) {
        final var devices = new Device[times];
        Arrays.fill(devices, new Empty());
        return devices;
    }
}
