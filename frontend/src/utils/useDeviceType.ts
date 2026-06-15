import {useMemo} from "react";

export type DeviceType = "ios" | "android" | "desktop";

export const useDeviceType = (): DeviceType => {
    return useMemo(() => {
        const userAgent = navigator.userAgent;

        if (/Android/i.test(userAgent)) {
            return "android";
        }

        const isIpadOs = navigator.platform === "MacIntel" && navigator.maxTouchPoints > 1;
        if (/iPhone|iPad|iPod/i.test(userAgent) || isIpadOs) {
            return "ios";
        }

        return "desktop";
    }, []);
}
