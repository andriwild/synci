import {useState} from "react";
import {Button, Drawer, Typography} from "antd";
import {IconCalendar} from "@tabler/icons-react";
import {SyncConfigComponent} from "../desktop/SyncConfigComponent.tsx";
import {useSyncConfig} from "../../../services/syncConfig/syncCofigSlice.ts";
import {SyncConfig} from "../../../services/syncConfig/entities/syncConfig.ts";

export const ShowCalendarsButton = () => {
    const syncConfig = useSyncConfig();

    const [open, setOpen] = useState(false);

    const showDrawer = () => {
        setOpen(true);
    };

    const onClose = () => {
        setOpen(false);
    };


    function subscriptionsLength(syncConfig?: SyncConfig) {
        if (!syncConfig) return 0;
        return syncConfig.events.length + syncConfig.teams.length + syncConfig.sports.length
    }

    return (
        <>
            <div style={{position: "fixed", bottom: "10px", left: "5%", width: "90%", padding: "10px 0px", zIndex: 100}}
            >
                <Button onClick={showDrawer} type="primary" icon={<IconCalendar/>} size="large" block>
                        <span style={{
                            position: "absolute",
                            right: "-10px",
                            top: "-10px",
                            backgroundColor: "#f8e06d",
                            color: "black",
                            borderRadius: "50%",
                            height: "25px",
                            fontSize: "12px",
                            fontWeight: "bold",
                            padding: "3px 8px",
                        }}>
                            {subscriptionsLength(syncConfig)}
                        </span>
                    <Typography.Text style={{color: 'white'}}>
                        Kalender anzeigen
                    </Typography.Text>
                </Button>
            </div>


            <Drawer
                placement={"bottom"}
                size={"default"}
                closable={true}
                footer={null}
                height={"70%"}
                headerStyle={{ display: "none" }}
                bodyStyle={{ overflow: "hidden" }}
                onClose={onClose}
                open={open}
                styles={{ body: { padding: 0 } }}
            >
                <div     style={{
                    width: "90%",
                    height: "90%",
                }}>
                <SyncConfigComponent/>
                </div>
            </Drawer>
        </>
    );
};

