import {useState} from "react";
import {Button, Modal, Typography} from "antd";
import {IconCalendar} from "@tabler/icons-react";
import {SyncConfigComponent} from "../desktop/SyncConfigComponent.tsx";
import {useSyncConfig} from "../../../services/syncConfig/syncCofigSlice.ts";
import {SyncConfig} from "../../../services/syncConfig/entities/syncConfig.ts";

export const ShowCalendarsButton = () => {
    const [isModalOpen, setIsModalOpen] = useState(false);

    const syncConfig = useSyncConfig();

    const showModal = () => {
        setIsModalOpen(true);
    };

    const handleClose = () => {
        setIsModalOpen(false);
    };

    function subscriptionsLength(syncConfig?: SyncConfig) {
        if (!syncConfig) return 0;
        return syncConfig.events.length + syncConfig.teams.length + syncConfig.sports.length
    }

    return (
        <>
            <div style={{position: "absolute", bottom: "10px", width: "90%", padding: "10px 0px"}}
            >
                <Button onClick={showModal} type="primary" icon={<IconCalendar/>} size="large" block>
                        <span style={{
                            position: "absolute",
                            right: "-10px",
                            top: "-10px",
                            backgroundColor: "red",
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


            <Modal
                open={isModalOpen}
                onCancel={handleClose}
                footer={null}
                closable={false}
            >
                <SyncConfigComponent/>
            </Modal>
        </>
    );
};

