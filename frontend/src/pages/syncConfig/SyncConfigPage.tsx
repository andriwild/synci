import {syncConfigApi} from "../../services/syncConfig/syncConfigApi.ts";
import {Button, Flex, Form, Input, Modal, notification, theme, Typography} from "antd";
import {SportConfigCard} from "../../sharedComponents/config/SportConfigCard.tsx";
import {TeamConfigCard} from "../../sharedComponents/config/TeamConfigCard.tsx";
import {EventConfigCard} from "../../sharedComponents/config/EventConfigCard.tsx";
import {CalendarSelectionModal} from "../../sharedComponents/calenderSelectionModal/CalenderSelectionModal.tsx";
import {DeleteConfigModal} from "../../sharedComponents/config/DeleteConfigModal.tsx";
import {VITE_BACKEND_HOST} from "../../../env.ts";
import {syncConfigActions} from "../../services/syncConfig/syncCofigSlice.ts";
import {IconPlus, IconFileSad, IconEdit} from "@tabler/icons-react";
import {useDispatch} from "react-redux";
import {useNavigate} from "react-router-dom";
import {useState} from "react";
import {SyncConfig} from "../../services/syncConfig/entities/syncConfig.ts";
import {NotificationPlacement} from "antd/es/notification/interface";

export const SyncConfigPage = () => {
    const syncConfig = syncConfigApi.useGetAllQuery();
    const token = theme.useToken().token;
    const dispatch = useDispatch();
    const navigate = useNavigate();

    return (
        <Flex wrap
              gap={20}
              style={{
                  padding: "20px",
                  height: "100%",
                  overflow: "auto",
              }}>
            {syncConfig?.data?.map((config) => (
                <Flex vertical key={config.id} gap={10} style={{
                    background: token.colorBgBase,
                    borderRadius: "20px",
                    maxWidth: "300px",
                    padding: "20px"
                }}>
                    <Flex align="center" justify="space-between" style={{width: "100%"}}>
                        <Typography.Title level={3} style={{margin: 0}}>{config.name}</Typography.Title>
                        <EditConfigNameModal config={config} refetch={syncConfig.refetch} />
                    </Flex>

                    {config.sports && config.sports.map((sport) => (
                        <SportConfigCard sport={sport} config={config} key={sport.id}/>
                    ))}

                    {config.teams && config.teams.map((team) => (
                        <TeamConfigCard team={team} config={config} key={team.id}/>
                    ))}

                    {config.events && config.events.map((event) => (
                        <EventConfigCard event={event} config={config} key={event.id}/>
                    ))}

                    {(!config.sports || config.sports.length === 0) &&
                     (!config.teams || config.teams.length === 0) &&
                     (!config.events || config.events.length === 0) && (
                        <Flex
                            vertical
                            align={"center"}
                            justify={"center"}
                            gap={10}
                            style={{
                                borderRadius: 20,
                                background: token.colorBgContainer,
                                padding: 20,
                                minHeight: "100px"
                            }}>
                            <IconFileSad size={40} color={token.colorTextSecondary}/>
                            <Typography.Text type="secondary">Keine Events</Typography.Text>
                        </Flex>
                    )}

                    <Button
                        type="default"
                        icon={<IconPlus size={20}/>}
                        onClick={() => {
                            dispatch(syncConfigActions.setSyncConfig(config));
                            navigate('/sport');
                        }}
                    >
                        Sportarten hinzufügen
                    </Button>

                    <CalendarSelectionModal
                        url={`${VITE_BACKEND_HOST}/api/calendars/${config.id}/subscribe`}
                        buttonText="Zu Kalender hinzufügen"
                        buttonIcon={<i className="fas fa-calendar-plus"></i>}
                        buttonType="primary"
                    />

                    <DeleteConfigModal
                        list={syncConfig.data || []}
                        refetch={syncConfig.refetch}
                        id={config.id}
                        name={config.name}
                    />
                </Flex>
            ))}

            <CreateConfigCard refetch={syncConfig.refetch} />
        </Flex>
    );
}

const EditConfigNameModal = ({config, refetch}: {
    config: SyncConfig,
    refetch: () => void
}) => {
    const [open, setOpen] = useState(false);
    const [form] = Form.useForm();
    const [api, contextHolder] = notification.useNotification();
    const dispatch = useDispatch();

    const openNotification = (placement: NotificationPlacement) => {
        api.success({
            message: "Abo umbenannt",
            description: "Der Abo-Name wurde erfolgreich geändert",
            placement,
        });
    };

    const [updateSyncConfig, updateSyncConfigStatus] = syncConfigApi.useUpdateMutation();

    const handleSubmit = async (values: { name: string }) => {
        try {
            const updatedConfig = await updateSyncConfig({
                id: config.id,
                name: values.name,
                sports: config.sports?.map(s => s.id) || [],
                teams: config.teams || [],
                events: config.events || []
            });
            dispatch(syncConfigActions.setSyncConfig(updatedConfig.data));
            openNotification("bottomRight");
            refetch();
            setOpen(false);
        } catch (e) {
            console.error(e);
        }
    };

    return (
        <>
            {contextHolder}
            <Button
                type="text"
                size="small"
                icon={<IconEdit size={18}/>}
                onClick={() => {
                    setOpen(true);
                    form.setFieldsValue({name: config.name});
                }}
            />
            <Modal
                title="Abo umbenennen"
                open={open}
                onCancel={() => setOpen(false)}
                footer={null}
            >
                <Flex vertical gap={10}>
                    <Form form={form} layout="vertical" onFinish={handleSubmit}>
                        <Form.Item
                            label="Abo-Name"
                            name="name"
                            rules={[{required: true, message: "Bitte Abo-Namen eingeben"}]}
                        >
                            <Input placeholder="Abo-Name eingeben"/>
                        </Form.Item>
                        <Form.Item>
                            <Button type="primary" htmlType="submit" loading={updateSyncConfigStatus.isLoading}>
                                Speichern
                            </Button>
                        </Form.Item>
                    </Form>
                </Flex>
            </Modal>
        </>
    );
}

const CreateConfigCard = ({refetch}: { refetch: () => void }) => {
    const [open, setOpen] = useState(false);
    const [form] = Form.useForm();
    const [api, contextHolder] = notification.useNotification();
    const dispatch = useDispatch();
    const token = theme.useToken().token;

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
            <Flex
                vertical
                align="center"
                justify="center"
                gap={10}
                style={{
                    background: token.colorBgBase,
                    borderRadius: "20px",
                    maxWidth: "300px",
                    minHeight: "200px",
                    padding: "20px",
                    cursor: "pointer",
                    border: `2px dashed ${token.colorPrimary}`,
                    transition: "all 0.3s ease"
                }}
                onClick={() => setOpen(true)}
            >
                <IconPlus size={60} color={token.colorPrimary}/>
                <Typography.Text style={{color: token.colorPrimary, fontWeight: 500}}>
                    Neues Abo erstellen
                </Typography.Text>
            </Flex>

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
                                Erstellen
                            </Button>
                        </Form.Item>
                    </Form>
                </Flex>
            </Modal>
        </>
    );
}