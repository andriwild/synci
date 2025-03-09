import {Alert, Button, Flex, Typography} from "antd";
import {CalendarSelectionModal} from "../../components/calenderSelectionModal/CalenderSelectionModal.tsx";
import {IconReplace,} from "@tabler/icons-react";
import {SyncConfig} from "../../services/config/entities/syncConfig.ts";
import {useEffect, useState} from "react";
import {useUser} from "../../services/user/UserSlice.ts";
import {syncConfigApi} from "../../services/config/syncConfigApi.ts";

export const CalendarComponent = () => {
    const user = useUser();
    const syncConfigList = syncConfigApi.useGetAllQuery();
    console.log(syncConfigList.data);

    const [currentSyncConfig, setCurrentSyncConfig] = useState<SyncConfig | null>(null);



    useEffect(() => {
        if (syncConfigList.data) {
            setCurrentSyncConfig(syncConfigList.data[0]);
        }
    }, [syncConfigList.data]);


    if (!user) {
        return (
        <Flex vertical style={{gap: 20, padding: "20px 20px"}}>
            <Alert
                message="Du bist noch nicht angemeldet"
                description="Melde dich an, um deine Abos zu sehen"
                type="warning"
                showIcon
                action={
                    <Button>Anmelden</Button>
                }
            />
        </Flex>
        );
    }

    return (
        <Flex vertical style={{gap: 20, padding: "20px 20px", width: "100%"}}>
            <Flex justify={"space-between"} style={{width: "100%"}}>
                {/*TODO Edit field*/}
                <Typography.Title level={2} style={{margin: 0}}>{currentSyncConfig?.name}</Typography.Title>
                <Button icon={<IconReplace size={20}/>} type={"default"}></Button>
            </Flex>
                <CalendarSelectionModal
                url="localhost:8080/api/calendar/subscribe/55e8b617-be90-42ed-a75f-89f374ca303c"
                buttonText="Zu Kalender hinzufügen"
                buttonIcon={<i className="fas fa-calendar-plus"></i>}
              buttonType="primary"

        />

</Flex>
)
    ;
}