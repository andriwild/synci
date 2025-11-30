import {Button, Flex, Form, Modal, notification, Typography} from "antd";
import {IconTrash} from "@tabler/icons-react";
import {useState} from "react";
import {useDispatch} from "react-redux";
import {NotificationPlacement} from "antd/es/notification/interface";
import {syncConfigApi} from "../../services/syncConfig/syncConfigApi.ts";
import {syncConfigActions, useSyncConfig} from "../../services/syncConfig/syncCofigSlice.ts";
import {SyncConfig} from "../../services/syncConfig/entities/syncConfig.ts";

export const DeleteConfigModal = ({list, refetch, id, name, compact = false}: {
    list: SyncConfig[],
    refetch: () => void,
    id: string,
    name: string,
    compact?: boolean
}) => {
    const [open, setOpen] = useState(false);
    const [form] = Form.useForm();
    const [api, contextHolder] = notification.useNotification();
    const dispatch = useDispatch();
    const currentSyncConfig = useSyncConfig();

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
            if (id === currentSyncConfig?.id) {
                const remainingConfigs = list.filter((config) => config.id !== id);
                if (remainingConfigs.length > 0) {
                    dispatch(syncConfigActions.setSyncConfig(remainingConfigs[0]));
                }
            }
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
                danger
                type={compact ? "default" : "primary"}
                size={compact ? "small" : "middle"}
                icon={<IconTrash size={compact ? 15 : 20}/>}
                onClick={() => setOpen(true)}
            >
                {!compact && "Kalender löschen"}
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
                            <Button danger type="primary" htmlType="submit" loading={deleteSyncConfigStatus.isLoading}>
                                Löschen
                            </Button>
                        </Form.Item>
                    </Form>
                </Flex>
            </Modal>
        </>
    );
}