import {Button, Drawer, Typography} from "antd";
import {CalendarBlank} from "@phosphor-icons/react";
import {useUser} from "../../../services/user/UserSlice.ts";
import {useSyncConfig} from "../../../services/syncConfig/syncCofigSlice.ts";
import {SyncConfigComponent} from "../desktop/SyncConfigComponent.tsx";

/** Sticky bar below the tree (phones + tablets) showing the selected subscription and opening the drawer. */
export const SyncConfigBar = ({onOpen}: { onOpen: () => void }) => {
    const user = useUser();
    const syncConfig = useSyncConfig();
    const count = (syncConfig?.sports?.length ?? 0) + (syncConfig?.teams?.length ?? 0) + (syncConfig?.events?.length ?? 0);

    return (
        <div className="sync-config-bar">
            <div className="sync-config-bar__text">
                {user && syncConfig ? (
                    <>
                        <Typography.Text type={"secondary"} style={{fontSize: 12}}>Aktuelles Abo</Typography.Text>
                        <Typography.Text strong ellipsis>{syncConfig.name} · {count} {count === 1 ? "Eintrag" : "Einträge"}</Typography.Text>
                    </>
                ) : (
                    <Typography.Text ellipsis>
                        {user ? "Kein Abo ausgewählt" : "Melde dich an, um dein Abo zu verwalten"}
                    </Typography.Text>
                )}
            </div>
            <Button type={"primary"} icon={<CalendarBlank size={18}/>} onClick={onOpen} style={{flexShrink: 0}}>
                Abo öffnen
            </Button>
        </div>
    );
};

/** Bottom drawer with the full subscription panel (same component as the desktop side panel). */
export const SyncConfigDrawer = ({open, onClose}: { open: boolean, onClose: () => void }) => (
    <Drawer
        title="Mein Abo"
        placement="bottom"
        height="85vh"
        open={open}
        onClose={onClose}
        styles={{body: {padding: "0 0 env(safe-area-inset-bottom)"}}}
    >
        <SyncConfigComponent/>
    </Drawer>
);
