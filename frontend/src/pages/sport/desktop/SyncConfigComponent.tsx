import {Alert, Button, Flex, Form, Input, Modal, notification, Popover, Typography} from "antd";
import {IconPlus, IconReplace} from "@tabler/icons-react";
import {useEffect, useState} from "react";

import {useDispatch} from "react-redux";
import {NotificationPlacement} from "antd/es/notification/interface";
import {syncConfigActions, useSyncConfig} from "../../../services/syncConfig/syncCofigSlice.ts";
import {syncConfigApi} from "../../../services/syncConfig/syncConfigApi";
import {useUser} from "../../../services/user/UserSlice";
import {SportConfigCard} from "../../../sharedComponents/config/SportConfigCard.tsx";
import {TeamConfigCard} from "../../../sharedComponents/config/TeamConfigCard.tsx";
import {CalendarSelectionModal} from "../../../sharedComponents/calenderSelectionModal/CalenderSelectionModal.tsx";
import {VITE_BACKEND_HOST} from "../../../../env.ts";
import {EventConfigCard} from "../../../sharedComponents/config/EventConfigCard.tsx";
import {track} from "../../../utils/analytics.ts";


export const SyncConfigComponent = () => {
    const user = useUser();
    const syncConfigList = syncConfigApi.useGetAllQuery(undefined, {
        skip: !user, // Skip the API call if user is not logged in
    });
    const [open, setOpen] = useState(false);


    const currentSyncConfig = useSyncConfig();
    const dispatch = useDispatch();

    useEffect(() => {
        if (user && syncConfigList.data) {
            dispatch(syncConfigActions.setSyncConfig(syncConfigList.data[0]));
        }
    }, [user, syncConfigList.data, dispatch]);

    if (!user) {
        return (
            <Flex vertical style={{gap: 20, padding: "20px 20px"}}>
                <Alert
                    message="Du bist noch nicht angemeldet"
                    description="Melde dich an, um deine Abos zu sehen"
                    type="warning"
                    showIcon
                />
            </Flex>
        );
    }
    if (!syncConfigList.data) {
        return (
            <Flex vertical style={{gap: 20, padding: "20px 20px"}}>
                <Typography.Title level={5}>Lade Abos...</Typography.Title>
            </Flex>
        );
    }

    if (syncConfigList.data?.length === 0) {
        return (
            <Flex vertical style={{gap: 20, padding: "20px 20px", width:"100%"}} align={"center"}>
                <Typography.Title level={5}>Keine Abos vorhanden</Typography.Title>
                <CreateConfigModal refetch={syncConfigList.refetch}/>
            </Flex>
        );
    }
    return (
        <Flex
            vertical
            style={{
                gap: 20,
                padding: "20px 20px",
                height: "100%",
                maxHeight: "100%",
                width: "100%",
            }}
        >
            <Flex justify={"space-between"} style={{ width: "100%" }} gap={10}>
                <Typography.Title level={4} style={{ margin: 0 }}>
                    {currentSyncConfig?.name}
                </Typography.Title>

                <Popover
                    placement="bottomRight"
                    title={"Alle verfügbaren Abos"}
                    open={open}
                    onOpenChange={(open) => setOpen(open)}
                    styles={{
                        body: { background: "white", padding: "20px", minWidth: "300px" },
                    }}
                    content={
                        <Flex vertical gap={10}>
                            {syncConfigList.data?.map((syncConfig) => (
                                <Button
                                    key={syncConfig.id}
                                    type={"default"}
                                    style={{ width: "100%", textAlign: "left" }}
                                    onClick={() => {
                                        dispatch(syncConfigActions.setSyncConfig(syncConfig));
                                        setOpen(false);
                                    }}
                                >
                                    {syncConfig.name}
                                </Button>
                            ))}
                            <CreateConfigModal refetch={() => syncConfigList.refetch()} />
                        </Flex>
                    }
                >
                    <Button icon={<IconReplace size={20} />} type={"default"} >
                        Abo wechseln
                    </Button>
                </Popover>
            </Flex>

            <Flex
                vertical
                style={{
                    gap: 20,
                    width: "100%",
                    flex: 1,          // nimmt den restlichen Platz ein
                    minHeight: 0,     // wichtig fuer korrektes Flex-Scrolling
                    overflowY: "auto" // hier wird gescrolled
                }}
            >
                {currentSyncConfig?.sports &&
                    currentSyncConfig?.sports?.map((sport) => (
                        <SportConfigCard key={sport.id} sport={sport} />
                    ))}

                {currentSyncConfig?.events &&
                    currentSyncConfig?.events.map((event) => (
                        <EventConfigCard key={event.id} event={event} />
                    ))}

                {currentSyncConfig?.teams &&
                    currentSyncConfig?.teams.map((team) => (
                        <TeamConfigCard key={team.id} team={team} />
                    ))}

                {currentSyncConfig?.sports?.length === 0 &&
                    currentSyncConfig?.events?.length === 0 &&
                    currentSyncConfig?.teams?.length === 0 && (
                        <>
                            <Typography.Text>
                                Keine Teams / Ligen / Events vorhanden
                            </Typography.Text>
                        </>
                    )}
            </Flex>

                <CalendarSelectionModal
                    url={`${VITE_BACKEND_HOST}/api/calendars/${currentSyncConfig?.id}/subscribe`}
                    buttonText="Zu Kalender hinzufuegen"
                    buttonIcon={<i className="fas fa-calendar-plus"></i>}
                    buttonType="primary"

                />
        </Flex>

    )
        ;
}

const CreateConfigModal = ({refetch}: { refetch: () => void }) => {
    const [open, setOpen] = useState(false);
    const [form] = Form.useForm();
    const dispatch = useDispatch();
    const [api, contextHolder] = notification.useNotification();

    const openNotification = (placement: NotificationPlacement) => {
        api.success({
            message: "Abo erstellt",
            description: "Das neue Abo wurde erfolgreich erstellt. Du kannst jetzt deine Events hinzufügen",
            placement,
        });
    };

    const [createSyncConfig, createSyncConfigStatus] = syncConfigApi.useCreateMutation();

    const handleSubmit = async (values: { name: string }) => {
        try {
            const response = await createSyncConfig({
                name: values.name,
                events: [],
                teams: [],
                sports: []
            });
            dispatch(syncConfigActions.setSyncConfig(response.data));
            if (response.data) {
                track("abo-create");
            }
            openNotification("bottomRight");
            form.resetFields();
            refetch();
            setOpen(false);
        } catch (e) {
            console.error(e);
        }
    };

    return (
        <>
            {contextHolder}
            <Modal
                title="Neues Abo erstellen"
                open={open}
                onCancel={() => setOpen(false)}
                footer={null}
            >
                <Flex vertical gap={10}>
                    <Typography.Text>Hier kannst du ein neues Abo erstellen</Typography.Text>
                    <Form form={form} layout="vertical" onFinish={handleSubmit}>
                        <Form.Item
                            label="Abo-Name"
                            name="name"
                            rules={[{required: true, message: "Bitte Abo-Namen eingeben"}]}
                        >
                            <Input placeholder="Abo-Name eingeben"/>
                        </Form.Item>
                        <Form.Item>
                            <Button type="primary" htmlType="submit" loading={createSyncConfigStatus.isLoading}>
                                Speichern
                            </Button>
                        </Form.Item>
                    </Form>
                </Flex>
            </Modal>
            <Button type="primary" size="middle"
                    icon={<IconPlus size={15}/>}
                    onClick={() => setOpen(true)}
            >
                Neues Abo erstellen
            </Button>
        </>
    );
};

