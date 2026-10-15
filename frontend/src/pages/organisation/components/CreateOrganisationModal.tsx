import {Button, Flex, Form, Input, Modal, notification, Typography} from "antd";
import {organisationApi} from "../../../services/organisation/organisationApi.ts";
import {stringifyApiError} from "../../../services/common/apiHelpers.ts";
import {Organisation} from "../../../services/organisation/entities/organisation.ts";

export const CreateOrganisationModal = ({open, onClose, onCreated}: {
    open: boolean,
    onClose: () => void,
    onCreated?: (organisation: Organisation) => void
}) => {
    const [form] = Form.useForm();
    const [api, contextHolder] = notification.useNotification();
    const [createOrganisation, createStatus] = organisationApi.useCreateMutation();

    const handleSubmit = async (values: { name: string, description?: string }) => {
        const result = await createOrganisation({name: values.name, description: values.description});
        if (result.error) {
            api.error({message: "Organisation konnte nicht erstellt werden", description: stringifyApiError(result.error), placement: "bottomRight"});
            return;
        }
        api.success({
            message: "Organisation erstellt",
            description: "Du bist jetzt Admin dieser Organisation und kannst Gruppen und Events erfassen.",
            placement: "bottomRight",
        });
        form.resetFields();
        onCreated?.(result.data);
        onClose();
    };

    return (
        <>
            {contextHolder}
            <Modal title="Neue Organisation erstellen" open={open} onCancel={onClose} footer={null}>
                <Flex vertical gap={10}>
                    <Typography.Text>Du wirst automatisch Admin der neuen Organisation.</Typography.Text>
                    <Form form={form} layout="vertical" onFinish={handleSubmit}>
                        <Form.Item
                            label="Name der Organisation"
                            name="name"
                            rules={[
                                {required: true, whitespace: true, message: "Bitte Name der Organisation eingeben"},
                                {max: 100, message: "Höchstens 100 Zeichen"}
                            ]}
                        >
                            <Input placeholder="z.B. FC Beispiel"/>
                        </Form.Item>
                        <Form.Item label="Beschreibung" name="description">
                            <Input.TextArea rows={3} placeholder="Optional: Worum geht es in dieser Organisation?"/>
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
