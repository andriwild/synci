import {useState} from "react";
import {Button, Modal} from "antd";
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
            <div style={{position: "absolute", bottom: "55px", left: "20px", right: "20px"}}
            >
                <Button onClick={showModal} type="primary" icon={<IconCalendar/>} size="large" block
                        style={{border: "1px solid white"}}>
                        <span style={{
                            position: "absolute",
                            right: "-10px",
                            top: "-10px",
                            backgroundColor: "red",
                            borderRadius: "100%",
                            width: "25px",
                            height: "25px",
                            border: "1px solid white"
                        }}>
                            {subscriptionsLength(syncConfig)}
                        </span>
                    Deine Kalender
                </Button>
            </div>


            <Modal
                open={isModalOpen}
                onCancel={handleClose}
                footer={null}
                closable={true}
                styles={{body: {padding: 0}, content: {padding: 0}}}
            >
                <SyncConfigComponent/>
            </Modal>
        </>
    );
};

