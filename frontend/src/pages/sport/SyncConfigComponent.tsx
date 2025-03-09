import {Alert, Button, Flex, Popover, theme, Typography} from "antd";
import {CalendarSelectionModal} from "../../components/calenderSelectionModal/CalenderSelectionModal.tsx";
import {IconEdit, IconReplace,} from "@tabler/icons-react";
import {SyncConfig} from "../../services/config/entities/syncConfig.ts";
import {useEffect, useState} from "react";
import {useUser} from "../../services/user/UserSlice.ts";
import {syncConfigApi} from "../../services/config/syncConfigApi.ts";

export const SyncConfigComponent = () => {
    const user = useUser();
    const syncConfigList = syncConfigApi.useGetAllQuery();
    const token = theme.useToken().token;
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
            <Flex justify={"space-between"} style={{width: "100%"}} gap={10}>
                {/*TODO Edit field*/}
                <Typography.Title level={2} style={{margin: 0}}>{currentSyncConfig?.name}</Typography.Title>
                <Popover placement="bottomRight" title={"Alle Verfügbaren Kalender"} styles={{body:{background: "white"}}} content={
                    <Flex gap={10} style={{background: token.colorBgContainer, padding: "10px", borderRadius: 10}}>
                        {syncConfigList.data?.map((syncConfig) => (
                            <Flex justify={"space-between"} style={{width: "100%"}}>
                                <Typography.Text>{syncConfig.name}</Typography.Text>
                                <Button type={"primary"} size={"small"} onClick={() => setCurrentSyncConfig(syncConfig)} icon={<IconEdit size={15}/>}></Button>
                            </Flex>
                        ))}
                    </Flex>
                }>
                    <Button icon={<IconReplace size={20}/>} type={"default"}></Button>
                </Popover>

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