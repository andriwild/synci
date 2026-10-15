import {Button, Flex, Form, Input, Modal, notification, Typography} from "antd";
import {organisationApi} from "../../../services/organisation/organisationApi.ts";
import {stringifyApiError} from "../../../services/common/apiHelpers.ts";

export const CreateGroupModal = ({organisationId, open, onClose}: {
    organisationId: string,
    open: boolean,
    onClose: () => void
}) => {
    const [form] = Form.useForm();
    const [api, contextHolder] = notification.useNotification();
    const [createGroup, createStatus] = organisationApi.useCreateGroupMutation();

    const handleSubmit = async (values: { name: string }) => {
        const result = await createGroup({organisationId, name: values.name});
        if (result.error) {
            api.error({message: "Gruppe konnte nicht erstellt werden", description: stringifyApiError(result.error), placement: "bottomRight"});
            return;
        }
        api.success({message: "Gruppe erstellt", description: `Die Gruppe "${result.data.label}" wurde erstellt.`, placement: "bottomRight"});
        form.resetFields();
        onClose();
    };

    return (
        <>
            {contextHolder}
            <Modal title="Neue Gruppe erstellen" open={open} onCancel={onClose} footer={null}>
                <Flex vertical gap={10}>
                    <Typography.Text>Gruppen sind z.B. Mannschaften oder Abteilungen. Mitglieder können einzelne Gruppen abonnieren.</Typography.Text>
                    <Form form={form} layout="vertical" onFinish={handleSubmit}>
                        <Form.Item
                            label="Gruppenname"
                            name="name"
                            rules={[
                                {required: true, whitespace: true, message: "Bitte Gruppennamen eingeben"},
                                {max: 100, message: "Höchstens 100 Zeichen"}
                            ]}
                        >
                            <Input placeholder="z.B. 1. Mannschaft"/>
                        </Form.Item>
                        <Form.Item style={{marginBottom: 0}}>
                            <Button type="primary" htmlType="submit" loading={createStatus.isLoading}>
                                Erstellen
                            </Button>
                        </Form.Item>
                    </Form>
                </Flex>
            </Modal>
        </>
    );
};
