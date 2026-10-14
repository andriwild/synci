import {Badge, Button, Drawer, Tooltip, Typography} from "antd";
import {IconCalendar, IconX} from "@tabler/icons-react";
import {useEffect, useRef, useState} from "react";
import {useSyncConfig} from "../../../services/syncConfig/syncCofigSlice.ts";
import {SyncConfigComponent} from "../desktop/SyncConfigComponent.tsx";
import {useResponsive} from "../../../utils/useResponsive.ts";

/** Number of entries (sports, teams, events) in the active subscription. */
const useSubscriptionCount = () => {
    const syncConfig = useSyncConfig();
    return (syncConfig?.sports?.length ?? 0) + (syncConfig?.teams?.length ?? 0) + (syncConfig?.events?.length ?? 0);
};

/** True for a moment whenever `value` grows, used to play the "added" animation. */
const useBumpOnIncrease = (value: number, durationMs = 700) => {
    const previous = useRef(value);
    const [bump, setBump] = useState(false);
    useEffect(() => {
        const grew = value > previous.current;
        previous.current = value;
        if (!grew) return;
        setBump(true);
        const timeout = setTimeout(() => setBump(false), durationMs);
        return () => clearTimeout(timeout);
    }, [value, durationMs]);
    return bump;
};

/**
 * Floating calendar button (bottom right) with the number of subscribed entries. It opens the
 * subscription panel as an overlay: a floating card on tablet/desktop, a bottom drawer on phones.
 */
export const SyncConfigFab = () => {
    const {isMobile} = useResponsive();
    const [open, setOpen] = useState(false);
    const count = useSubscriptionCount();
    const bump = useBumpOnIncrease(count);
    const panelRef = useRef<HTMLDivElement>(null);
    const buttonRef = useRef<HTMLButtonElement>(null);

    // desktop overlay: Escape closes, focus moves into the panel and back to the button
    useEffect(() => {
        if (!open || isMobile) return;
        panelRef.current?.focus();
        const onKey = (e: KeyboardEvent) => {
            if (e.key === "Escape") setOpen(false);
        };
        window.addEventListener("keydown", onKey);
        return () => window.removeEventListener("keydown", onKey);
    }, [open, isMobile]);

    const close = () => {
        setOpen(false);
        buttonRef.current?.focus();
    };

    return (
        <>
            {!open &&
                <Tooltip title="Mein Abo" placement="left">
                    <Badge count={count} offset={[-6, 6]} color="#FFEE77" style={{color: "#1f1f1f", fontWeight: 700}}
                           className={`sync-fab__badge ${bump ? "sync-fab__badge--bump" : ""}`}>
                        <Button
                            ref={buttonRef}
                            type="primary"
                            shape="circle"
                            className={`sync-fab ${bump ? "sync-fab--bump" : ""}`}
                            icon={<IconCalendar size={26}/>}
                            aria-label={`Mein Abo öffnen, ${count} ${count === 1 ? "Eintrag" : "Einträge"}`}
                            aria-expanded={open}
                            onClick={() => setOpen(true)}
                        />
                    </Badge>
                </Tooltip>}

            {isMobile
                ? <Drawer
                    title="Mein Abo"
                    placement="bottom"
                    height="85vh"
                    open={open}
                    onClose={close}
                    styles={{body: {padding: "0 0 env(safe-area-inset-bottom)"}}}
                >
                    <SyncConfigComponent/>
                </Drawer>
                : open &&
                <div
                    ref={panelRef}
                    className="sync-overlay"
                    role="dialog"
                    aria-modal="false"
                    aria-label="Mein Abo"
                    tabIndex={-1}
                >
                    <div className="sync-overlay__header">
                        <Typography.Text strong>Mein Abo</Typography.Text>
                        <Button type="text" icon={<IconX size={20}/>} aria-label="Schliessen" onClick={close}/>
                    </div>
                    <div className="sync-overlay__body">
                        <SyncConfigComponent/>
                    </div>
                </div>}
        </>
    );
};
