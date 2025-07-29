import {Alert, Button, Flex, Form, Input, Modal, notification, Popover, theme, Typography} from "antd";
import {CalendarSelectionModal} from "../../sharedComponents/calenderSelectionModal/CalenderSelectionModal.tsx";
import {IconEdit, IconPlus, IconReplace, IconTrash,} from "@tabler/icons-react";
import {useEffect, useState} from "react";
import {syncConfigApi} from "../../services/syncConfig/syncConfigApi.ts";
import {syncConfigActions, useSyncConfig} from "../../services/syncConfig/syncCofigSlice.ts";
import {useDispatch} from "react-redux";
import {NotificationPlacement} from "antd/es/notification/interface";
import {SportConfigCard} from "../../sharedComponents/config/SportConfigCard.tsx";
import {VITE_BACKEND_HOST} from "../../../env.ts";
import {SyncConfig} from "../../services/syncConfig/entities/syncConfig.ts";
import {EventConfigCard} from "../../sharedComponents/config/EventConfigCard.tsx";
import {TeamConfigCard} from "../../sharedComponents/config/TeamConfigCard.tsx";
import {useUser} from "../../services/user/UserSlice.ts";

export const SyncConfigComponent = () => {
    const syncConfigList = syncConfigApi.useGetAllQuery();
    const token = theme.useToken().token;
    const [open, setOpen] = useState(false);
    const user = useUser();

    const currentSyncConfig = useSyncConfig();
    const dispatch = useDispatch();

    useEffect(() => {
        syncConfigList.refetch();
        if (syncConfigList.data) {
            dispatch(syncConfigActions.setSyncConfig(syncConfigList.data[0]));
        }
    }, [user]);

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
            <Flex vertical style={{gap: 20, padding: "20px 20px", width: "100%"}} align={"center"}>
                <Typography.Title level={5}>Keine Abos vorhanden</Typography.Title>
             <CreateConfigModal refetch={syncConfigList.refetch}/>
            </Flex>
        );
    }
    return (
        <Flex vertical style={{gap: 20, padding: "20px 20px", width: "100%"}}>
            <Flex justify={"space-between"} style={{width: "100%"}} gap={10}>
                {/*TODO Edit field*/}
                <Typography.Title level={4} style={{margin: 0}}>{currentSyncConfig?.name}</Typography.Title>
                <Popover placement="bottomRight"
                         title={"Alle verfügbaren Abos"}
                         open={open}
                         onOpenChange={(open) => setOpen(open)}
                         styles={{body: {background: "white", padding: "20px", minWidth: "300px"}}} content={
                    <Flex vertical gap={20}>
                        {syncConfigList.data?.map((syncConfig) => (
                            <Flex justify={"space-between"} align={"center"}
                                  style={{background: token.colorBgContainer, padding: "10px", borderRadius: 10}}
                                  gap={20} key={syncConfig.id}>
                                <Typography.Text>{syncConfig.name}</Typography.Text>
                                <Flex gap={10} align={"center"}>
                                    <Button type={"primary"} size={"small"} onClick={() => {
                                        dispatch(syncConfigActions.setSyncConfig(syncConfig));
                                        setOpen(false)
                                    }
                                    } icon={<IconEdit size={15}/>}></Button>
                                    <DeleteConfigModal list={syncConfigList.data || []} refetch={syncConfigList.refetch} id={syncConfig.id}
                                                       name={syncConfig.name}/>
                                </Flex>
                            </Flex>

                        ))}
                        <CreateConfigModal refetch={() => syncConfigList.refetch()}/>
                    </Flex>
                }>
                    <Button icon={<IconReplace size={20}/>} type={"default"}></Button>
                </Popover>
            </Flex>

            {(currentSyncConfig?.sports &&
                currentSyncConfig?.sports?.map((sport) => (
                    <SportConfigCard key={sport.id} sport={sport}/>
                ))
            )}
            {currentSyncConfig?.events &&
            currentSyncConfig?.events.map((event) => (
                <EventConfigCard key={event.id} event={event}/>
            ))}
            {currentSyncConfig?.teams &&
            currentSyncConfig?.teams.map((team) => (
                <TeamConfigCard key={team.id} team={team}/>
            ))}
            {currentSyncConfig?.sports?.length === 0 &&
            currentSyncConfig?.events?.length === 0 &&
            currentSyncConfig?.teams?.length === 0 &&
                <>
                    <Typography.Text>Keine Abos vorhanden</Typography.Text>
                    <CreateConfigModal refetch={() => syncConfigList.refetch()}/>
                </>
            }

            <CalendarSelectionModal
                url={ `${VITE_BACKEND_HOST}/api/calendars/${currentSyncConfig?.id}/subscribe`}
                buttonText="Zu Kalender hinzufügen"
                buttonIcon={<i className="fas fa-calendar-plus"></i>}
                buttonType="primary"
            />

        </Flex>
    )
        ;
}

const DeleteConfigModal = ({list, refetch, id, name}: {
    list: SyncConfig[],
    refetch: () => void,
    id: string,
    name: string }) => {
    const [open, setOpen] = useState(false);
    const [form] = Form.useForm();
    const [api, contextHolder] = notification.useNotification();
    const dispatch = useDispatch();
    const syncConfig = useSyncConfig();

    const openNotification = (placement: NotificationPlacement) => {
        api.info({
            message: "Abo gelöscht",
            description: "Das Abo wurde erfolgreich gelöscht",
            placement,
        });
    };

    const [deleteSyncConfig, deleteSyncConfigStatus] = syncConfigApi.useDeleteMutation();

    const handleSubmit = async () => {
        try {
            await deleteSyncConfig(id);
            openNotification("bottomRight");
            if (id == syncConfig?.id) {
                list.filter((config) => config.id !== id);
            dispatch(syncConfigActions.setSyncConfig(list.filter((config) => config.id !== id)[0]));
            }
            refetch();
        } catch (e) {
            console.error(e);
        }
    };

    return (
        <>
            {contextHolder}
            <Button type="default" size="small"
                    icon={<IconTrash size={15}/>}
                    onClick={() => setOpen(true)}
            >
            </Button>
            <Modal
                title={`Abo ${name} löschen`}
                open={open}
                onCancel={() => setOpen(false)}
                footer={null}
            >
                <Flex vertical gap={10}>
                    <Typography.Text>Willst du das Abo wirklich löschen?</Typography.Text>
                    <Form form={form} layout="vertical" onFinish={handleSubmit}>
                        <Form.Item>
                            <Button type="primary" htmlType="submit" loading={deleteSyncConfigStatus.isLoading}>
                                Löschen
                            </Button>
                        </Form.Item>
                    </Form>
                </Flex>
            </Modal>
        </>
    );
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

