import {Alert, Button, Flex, Popover, theme, Typography} from "antd";
import {CalendarSelectionModal} from "../../components/calenderSelectionModal/CalenderSelectionModal.tsx";
import {IconEdit, IconReplace,} from "@tabler/icons-react";
import {useEffect, useState} from "react";
import {useUser} from "../../services/user/UserSlice.ts";
import {syncConfigApi} from "../../services/syncConfig/syncConfigApi.ts";
import {syncConfigActions, useSyncConfig} from "../../services/syncConfig/syncCofigSlice.ts";
import {useDispatch} from "react-redux";

export const SyncConfigComponent = () => {
    const user = useUser();
    const syncConfigList = syncConfigApi.useGetAllQuery();
    const token = theme.useToken().token;
    const [open, setOpen] = useState(false);
    console.log("query", syncConfigList.data);

    const currentSyncConfig = useSyncConfig();
    const dispatch = useDispatch();

    useEffect(() => {
        if (syncConfigList.data) {
            dispatch(syncConfigActions.setSyncConfig(syncConfigList.data[0]));
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

    if (syncConfigList.data?.length === 0) {
        return (
            <Flex vertical style={{gap: 20, padding: "20px 20px"}}>
                <Alert
                    message="Keine Abos vorhanden"
                    description="Füge ein Abo hinzu, um deine Kalender zu synchronisieren"
                    type="info"
                    showIcon
                    action={
                        <Button
                        onClick={() => setOpen(true)}
                        >Neues Abo hinzufügen</Button>
                    }
                />
            </Flex>
        );
    }
    return (
        <Flex vertical style={{gap: 20, padding: "20px 20px", width: "100%"}}>
            <Flex justify={"space-between"} style={{width: "100%"}} gap={10}>
                {/*TODO Edit field*/}
                <Typography.Title level={4} style={{margin: 0}}>{currentSyncConfig?.name}</Typography.Title>
                <Popover placement="bottomRight"
                         title={"Alle Verfügbaren Kalender"}
                         open={open}
                         onOpenChange={(open) => setOpen(open)}
                         styles={{body:{background: "white"}}} content={
                    <Flex vertical gap={10}>
                        {syncConfigList.data?.map((syncConfig) => (
                            <Flex justify={"space-between"} style={{ background: token.colorBgContainer, padding: "10px", borderRadius: 10}} gap={20}>
                                <Typography.Text>{syncConfig.name}</Typography.Text>
                                <Button type={"primary"} size={"small"} onClick={() => {
                                    dispatch(syncConfigActions.setSyncConfig(syncConfig));
                                    setOpen(false)
                                }
                                } icon={<IconEdit size={15}/>}></Button>
                            </Flex>
                        ))}
                    </Flex>
                }>
                    <Button icon={<IconReplace size={20}/>} type={"default"}></Button>
                </Popover>
            </Flex>

                {currentSyncConfig?.sports ?
                    currentSyncConfig?.sports?.map((sport) => (
                    <Flex vertical style={{gap: 10}}>
                        <Typography.Text>{sport.name}</Typography.Text>
                    </Flex>
                ))
                : <Typography.Text>Keine Abos vorhanden</Typography.Text>
                }

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