import {syncConfigApi} from "../../services/syncConfig/syncConfigApi.ts";
import {Button, Col, Flex, Form, Input, Modal, notification, Radio, Row, theme, Typography} from "antd";
import {IconEdit, IconFileSad, IconPlus} from "@tabler/icons-react";
import {useState} from "react";
import {useNavigate} from "react-router-dom";
import {DeleteConfigModal} from "../../sharedComponents/config/DeleteConfigModal.tsx";
import {SyncConfig} from "../../services/syncConfig/entities/syncConfig.ts";
import {track} from "../../utils/analytics.ts";
import {SportConfigCard} from "../../sharedComponents/config/SportConfigCard.tsx";
import {TeamConfigCard} from "../../sharedComponents/config/TeamConfigCard.tsx";
import {EventConfigCard} from "../../sharedComponents/config/EventConfigCard.tsx";
import {MatchupConfigCard} from "../../sharedComponents/config/MatchupConfigCard.tsx";
import {CalendarSelectionModal} from "../../sharedComponents/calenderSelectionModal/CalenderSelectionModal.tsx";
import {VITE_BACKEND_HOST} from "../../../env.ts";
import {syncConfigActions, useSyncConfig} from "../../services/syncConfig/syncCofigSlice.ts";
import {useDispatch} from "react-redux";
import {usePageMeta} from "../../utils/usePageMeta.ts";

/** one card per subscription: full width on phones, 2 / 3 / 4 per row on larger screens */
const CARD_COL = {xs: 24, sm: 12, lg: 8};

export const SyncConfigPage = () => {
    usePageMeta("Meine Abos");
    const syncConfig = syncConfigApi.useGetAllQuery();
    const token = theme.useToken().token;
    const currentSyncConfig = useSyncConfig();
    const dispatch = useDispatch();
    const navigate = useNavigate();

    return (
        <div style={{padding: "var(--page-gutter)", width: "100%", minWidth: 0}}>
            <Row gutter={[20, 20]}>
                {syncConfig?.data?.map((config) => {
                    const active = currentSyncConfig?.id == config.id;
                    return (
                        <Col key={config.id} {...CARD_COL}>
                            <Flex vertical gap={10} style={{
                                background: token.colorBgBase,
                                borderRadius: "20px",
                                padding: "20px",
                                height: "100%",
                                minWidth: 0,
                            }}>
                                <Flex justify={"space-between"} align={"center"} gap={10} style={{minWidth: 0}}>
                                    <Typography.Title level={3} style={{margin: 0, minWidth: 0, overflowWrap: "anywhere"}}>
                                        {config.name}
                                    </Typography.Title>
                                    {/* 44px tall tap target: label + radio */}
                                    <label style={{display: "inline-flex", alignItems: "center", gap: 6, minHeight: 44, cursor: "pointer", flexShrink: 0}}>
                                        <Radio
                                            checked={active}
                                            onChange={() => dispatch(syncConfigActions.setSyncConfig(config))}
                                        />
                                        <Typography.Text type={active ? undefined : "secondary"}>{active ? "Aktiv" : "Aktivieren"}</Typography.Text>
                                    </label>
                                    <EditConfigNameModal config={config} refetch={syncConfig.refetch}/>
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
                                {config.matchups?.map((matchup) => (
                                    <MatchupConfigCard matchup={matchup} config={config} key={`${matchup.teamA.id}:${matchup.teamB.id}`}/>
                                ))}
                                {(config.sports?.length ?? 0) === 0 && (config.teams?.length ?? 0) === 0 && (config.events?.length ?? 0) === 0 && (config.matchups?.length ?? 0) === 0 && (
                                    <Flex vertical align={"center"} justify={"center"} gap={10}
                                          style={{borderRadius: 20, background: token.colorBgContainer, padding: 20, minHeight: 100}}>
                                        <IconFileSad size={40} color={token.colorTextSecondary}/>
                                        <Typography.Text type="secondary">Keine Events</Typography.Text>
                                    </Flex>
                                )}
                                <Flex vertical gap={10} style={{marginTop: "auto"}}>
                                    <Button type="default" icon={<IconPlus size={20}/>} onClick={() => {
                                        dispatch(syncConfigActions.setSyncConfig(config));
                                        navigate("/sport");
                                    }}>
                                        Sportarten hinzufügen
                                    </Button>
                                    <CalendarSelectionModal
                                        url={`${VITE_BACKEND_HOST}/api/calendars/${config.id}/subscribe`}
                                        buttonText="Zu Kalender hinzufügen"
                                        buttonIcon={<i className="fas fa-calendar-plus"></i>}
                                        buttonType="primary"
                                    />
                                    <DeleteConfigModal list={syncConfig.data || []} refetch={syncConfig.refetch} id={config.id} name={config.name}/>
                                </Flex>
                            </Flex>
                        </Col>
                    );
                })}
                <Col {...CARD_COL}>
                    <CreateConfigCard refetch={syncConfig.refetch}/>
                </Col>
            </Row>
        </div>
    );
};

const EditConfigNameModal = ({config, refetch}: { config: SyncConfig, refetch: () => void }) => {
    const [open, setOpen] = useState(false);
    const [form] = Form.useForm();
    const [api, contextHolder] = notification.useNotification();
    const dispatch = useDispatch();
    const [updateSyncConfig, updateSyncConfigStatus] = syncConfigApi.useUpdateMutation();

    const handleSubmit = async (values: { name: string }) => {
        const updatedConfig = await updateSyncConfig({
            id: config.id,
            name: values.name,
            sports: config.sports?.map(s => s.id) || [],
            teams: config.teams || [],
            events: config.events || []
        });
        if (updatedConfig.data) {
            dispatch(syncConfigActions.setSyncConfig(updatedConfig.data));
            api.success({message: "Abo umbenannt", description: "Der Abo-Name wurde erfolgreich geändert", placement: "bottomRight"});
            refetch();
            setOpen(false);
        }
    };

    return (
        <>
            {contextHolder}
            <Button type="text" size="small" aria-label="Abo umbenennen" icon={<IconEdit size={18}/>} onClick={() => {
                setOpen(true);
                form.setFieldsValue({name: config.name});
            }}/>
            <Modal title="Abo umbenennen" open={open} onCancel={() => setOpen(false)} footer={null}>
                <Form form={form} layout="vertical" onFinish={handleSubmit}>
                    <Form.Item label="Abo-Name" name="name" rules={[{required: true, message: "Bitte Abo-Namen eingeben"}]}>
                        <Input placeholder="Abo-Name eingeben"/>
                    </Form.Item>
                    <Form.Item style={{marginBottom: 0}}>
                        <Button type="primary" htmlType="submit" loading={updateSyncConfigStatus.isLoading}>Speichern</Button>
                    </Form.Item>
                </Form>
            </Modal>
        </>
    );
};

const CreateConfigCard = ({refetch}: { refetch: () => void }) => {
    const [open, setOpen] = useState(false);
    const [form] = Form.useForm();
    const [api, contextHolder] = notification.useNotification();
    const dispatch = useDispatch();
    const token = theme.useToken().token;
    const [createSyncConfig, createSyncConfigStatus] = syncConfigApi.useCreateMutation();

    const handleSubmit = async (values: { name: string }) => {
        const response = await createSyncConfig({name: values.name, events: [], teams: [], sports: []});
        if (response.data) {
            dispatch(syncConfigActions.setSyncConfig(response.data));
            track("abo-create");
            api.success({message: "Abo erstellt", description: "Das neue Abo wurde erstellt. Du kannst jetzt deine Events hinzufügen", placement: "bottomRight"});
            form.resetFields();
            refetch();
            setOpen(false);
        }
    };

    return (
        <>
            {contextHolder}
            <Flex vertical align={"center"} justify={"center"} gap={10}
                  onClick={() => setOpen(true)}
                  style={{
                      border: `2px dashed ${token.colorPrimary}`,
                      borderRadius: 20,
                      minHeight: 180,
                      height: "100%",
                      padding: 20,
                      cursor: "pointer",
                      color: token.colorPrimary
                  }}>
                <IconPlus size={40}/>
                <Typography.Text strong style={{color: token.colorPrimary}}>Neues Abo erstellen</Typography.Text>
            </Flex>
            <Modal title="Neues Abo erstellen" open={open} onCancel={() => setOpen(false)} footer={null}>
                <Form form={form} layout="vertical" onFinish={handleSubmit}>
                    <Form.Item label="Abo-Name" name="name" rules={[{required: true, message: "Bitte Abo-Namen eingeben"}]}>
                        <Input placeholder="Abo-Name eingeben"/>
                    </Form.Item>
                    <Form.Item style={{marginBottom: 0}}>
                        <Button type="primary" htmlType="submit" loading={createSyncConfigStatus.isLoading}>Erstellen</Button>
                    </Form.Item>
                </Form>
            </Modal>
        </>
    );
};
