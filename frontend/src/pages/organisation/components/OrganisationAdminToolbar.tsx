import {Button, Dropdown, Flex, Form, Input, Modal, notification, Popconfirm, Tag, theme} from "antd";
import type {MenuProps} from "antd";
import {IconDotsVertical, IconEdit, IconPlus, IconTrash, IconUsers, IconUsersPlus} from "@tabler/icons-react";
import {useState} from "react";
import {useNavigate} from "react-router-dom";
import {MyOrganisation} from "../../../services/organisation/entities/organisation.ts";
import {organisationApi} from "../../../services/organisation/organisationApi.ts";
import {stringifyApiError} from "../../../services/common/apiHelpers.ts";
import {OrganisationEventFormModal} from "./OrganisationEventFormModal.tsx";
import {CreateGroupModal} from "./CreateGroupModal.tsx";
import {useResponsive} from "../../../utils/useResponsive.ts";

/**
 * Tags for an organisation node plus, for admins, the actions to manage events and groups.
 * On a group node the group itself can be renamed or deleted; its events then move to the organisation.
 * On phones (< sm) everything except "Event erfassen" collapses into a "Verwalten" dropdown.
 */
export const OrganisationAdminToolbar = ({organisation, sportId}: { organisation: MyOrganisation, sportId: string }) => {
    const token = theme.useToken().token;
    const navigate = useNavigate();
    const {isXs} = useResponsive();
    const [api, contextHolder] = notification.useNotification();
    const [eventModalOpen, setEventModalOpen] = useState(false);
    const [groupModalOpen, setGroupModalOpen] = useState(false);
    const [renameOpen, setRenameOpen] = useState(false);
    const [deleteOpen, setDeleteOpen] = useState(false);
    const [renameForm] = Form.useForm<{ name: string }>();
    const [renameGroup, renameStatus] = organisationApi.useUpdateGroupMutation();
    const [deleteGroup, deleteStatus] = organisationApi.useDeleteGroupMutation();

    const isAdmin = organisation.role === "ADMIN";
    const group = organisation.sport.subSports.find((g) => g.id === sportId);

    const handleRename = async (values: { name: string }) => {
        if (!group) return;
        const result = await renameGroup({organisationId: organisation.id, groupId: group.id, name: values.name});
        if (result.error) {
            api.error({message: "Gruppe konnte nicht umbenannt werden", description: stringifyApiError(result.error), placement: "bottomRight"});
            return;
        }
        api.success({message: "Gruppe umbenannt", placement: "bottomRight"});
        setRenameOpen(false);
    };

    const handleDelete = async () => {
        if (!group) return;
        const result = await deleteGroup({organisationId: organisation.id, groupId: group.id});
        setDeleteOpen(false);
        if (result.error) {
            api.error({message: "Gruppe konnte nicht gelöscht werden", description: stringifyApiError(result.error), placement: "bottomRight"});
            return;
        }
        api.info({message: "Gruppe gelöscht", description: "Die Events der Gruppe gehören jetzt zur Organisation.", placement: "bottomRight"});
    };

    const openRename = () => {
        if (!group) return;
        renameForm.setFieldsValue({name: group.label});
        setRenameOpen(true);
    };

    const deleteTitle = group ? `Gruppe "${group.label}" löschen?` : "";
    const deleteDescription = "Die Events der Gruppe bleiben erhalten und gehören danach zur ganzen Organisation.";

    const menuItems: MenuProps["items"] = [
        {key: "group", label: "Gruppe erstellen", icon: <IconUsersPlus size={16}/>, onClick: () => setGroupModalOpen(true)},
        ...(group ? [
            {key: "rename", label: "Gruppe umbenennen", icon: <IconEdit size={16}/>, onClick: openRename},
            {key: "delete", label: "Gruppe löschen", icon: <IconTrash size={16}/>, danger: true, onClick: () => setDeleteOpen(true)},
        ] : []),
        {key: "members", label: "Mitglieder verwalten", icon: <IconUsers size={16}/>, onClick: () => navigate(`/organisationen/${organisation.id}/mitglieder`)},
    ];

    const renderActions = () => {
        if (isXs) {
            return (
                <Flex gap={10} wrap>
                    <Button type={"primary"} icon={<IconPlus size={18}/>} onClick={() => setEventModalOpen(true)}>
                        Event erfassen
                    </Button>
                    <Dropdown menu={{items: menuItems}} trigger={["click"]}>
                        <Button icon={<IconDotsVertical size={18}/>}>Verwalten</Button>
                    </Dropdown>
                </Flex>
            );
        }
        return (
            <Flex gap={10} wrap>
                <Button type={"primary"} icon={<IconPlus size={18}/>} onClick={() => setEventModalOpen(true)}>
                    Event erfassen
                </Button>
                <Button icon={<IconUsersPlus size={18}/>} onClick={() => setGroupModalOpen(true)}>Gruppe erstellen</Button>
                {group &&
                    <>
                        <Button icon={<IconEdit size={18}/>} onClick={openRename}>Gruppe umbenennen</Button>
                        <Popconfirm
                            title={deleteTitle}
                            description={deleteDescription}
                            okText="Löschen" okButtonProps={{danger: true}} cancelText="Abbrechen"
                            onConfirm={handleDelete}
                        >
                            <Button danger icon={<IconTrash size={18}/>} loading={deleteStatus.isLoading}>Gruppe löschen</Button>
                        </Popconfirm>
                    </>}
                <Button icon={<IconUsers size={18}/>} onClick={() => navigate(`/organisationen/${organisation.id}/mitglieder`)}>
                    Mitglieder verwalten
                </Button>
            </Flex>
        );
    };

    return (
        <Flex vertical gap={10}>
            {contextHolder}
            <Flex gap={5} align={"center"} wrap>
                <Tag color={token.colorPrimary}>{isAdmin ? "Admin" : "Mitglied"}</Tag>
                <Tag>{group ? `Gruppe von ${organisation.name}` : "Organisation"}</Tag>
            </Flex>
            {isAdmin &&
                <>
                    {renderActions()}
                    <OrganisationEventFormModal
                        organisation={organisation}
                        open={eventModalOpen}
                        onClose={() => setEventModalOpen(false)}
                        defaultSportId={sportId}
                    />
                    <CreateGroupModal organisationId={organisation.id} open={groupModalOpen} onClose={() => setGroupModalOpen(false)}/>
                    <Modal title="Gruppe umbenennen" open={renameOpen} onCancel={() => setRenameOpen(false)} footer={null}>
                        <Form form={renameForm} layout="vertical" onFinish={handleRename}>
                            <Form.Item
                                label="Gruppenname"
                                name="name"
                                rules={[
                                    {required: true, whitespace: true, message: "Bitte Gruppennamen eingeben"},
                                    {max: 100, message: "Höchstens 100 Zeichen"}
                                ]}
                            >
                                <Input/>
                            </Form.Item>
                            <Form.Item style={{marginBottom: 0}}>
                                <Button type="primary" htmlType="submit" loading={renameStatus.isLoading}>Speichern</Button>
                            </Form.Item>
                        </Form>
                    </Modal>
                    {/* confirmation for the dropdown variant (Popconfirm cannot wrap a menu item) */}
                    <Modal
                        title={deleteTitle}
                        open={deleteOpen}
                        onCancel={() => setDeleteOpen(false)}
                        onOk={handleDelete}
                        okText="Löschen"
                        okButtonProps={{danger: true, loading: deleteStatus.isLoading}}
                        cancelText="Abbrechen"
                    >
                        {deleteDescription}
                    </Modal>
                </>}
        </Flex>
    );
};
